/* TEACHER MODE */
import { isSupabaseConfigured, supabase } from './supabaseClient.js'

function requireSupabase() {
  if (!isSupabaseConfigured || !supabase) {
    throw new Error('Supabase ulanishi sozlanmagan. .env faylini to‘ldiring.')
  }
}

function normalizePhone(value) {
  const digits = value.replace(/\D/g, '')
  if (digits.startsWith('998')) return `+${digits}`
  if (digits.length === 9) return `+998${digits}`
  return `+${digits}`
}

async function getPortalProfile(userId) {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, full_name, phone, role, branch_id, registered_at')
    .eq('id', userId)
    .maybeSingle()

  if (error) throw error
  if (!data || !['teacher', 'student'].includes(data.role)) {
    await supabase.auth.signOut()
    throw new Error('Bu hisob panelga kirish huquqiga ega emas.')
  }
  return data
}

export async function signInPortal(phone, password) {
  requireSupabase()
  const { data, error } = await supabase.auth.signInWithPassword({
    phone: normalizePhone(phone),
    password,
  })
  if (error) throw new Error('Telefon yoki parol noto‘g‘ri.')

  try {
    const profile = await getPortalProfile(data.user.id)
    return { user: data.user, profile }
  } catch (profileError) {
    await supabase.auth.signOut()
    throw profileError
  }
}

export async function getPortalSession() {
  requireSupabase()
  const { data, error } = await supabase.auth.getSession()
  if (error) throw error
  if (!data.session) return null

  try {
    const { data: userData, error: userError } = await supabase.auth.getUser()
    if (userError || !userData.user) {
      await supabase.auth.signOut()
      return null
    }
    const profile = await getPortalProfile(userData.user.id)
    return { user: userData.user, profile }
  } catch {
    await supabase.auth.signOut()
    return null
  }
}

export async function signOutPortal() {
  requireSupabase()
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

export async function loadStudentData(userId) {
  requireSupabase()

  const { data: student, error: studentError } = await supabase
    .from('students')
    .select('id, full_name, phone, birth_date, gender, source, status, balance, rating, app_active')
    .eq('auth_user_id', userId)
    .single()
  if (studentError) throw studentError

  const { data: memberships, error: membershipsError } = await supabase
    .from('group_students')
    .select('group_id, status, joined_at, left_at')
    .eq('student_id', student.id)
    .order('joined_at', { ascending: false })
    .limit(100)
  if (membershipsError) throw membershipsError

  const groupIds = [...new Set((memberships ?? []).map((membership) => membership.group_id))]
  if (!groupIds.length) {
    return { student, memberships: [], groups: [], payments: [], coins: [], products: [], materials: [], exams: [], results: [], support: [] }
  }

  const [groupsResult, paymentsResult, coinsResult, productsResult, materialsResult, examsResult, supportResult] = await Promise.all([
    supabase.from('groups')
      .select('id, name, course_id, branch_id, teacher_id, lesson_start, lesson_end, lesson_days, start_date, end_date, monthly_price, next_payment_date, status')
      .in('id', groupIds)
      .limit(100),
    supabase.from('payments')
      .select('id, group_id, payment_date, payment_type, amount, refunded_amount, bonus, payment_method, comment, created_at')
      .eq('student_id', student.id)
      .order('payment_date', { ascending: false })
      .limit(100),
    supabase.from('coin_transactions')
      .select('id, amount, reason, source, created_at')
      .eq('student_id', student.id)
      .order('created_at', { ascending: false })
      .limit(100),
    supabase.from('coin_products')
      .select('id, name, image_url, coin_price, category')
      .eq('is_active', true)
      .order('coin_price')
      .limit(100),
    supabase.from('study_materials')
      .select('id, group_id, title, topic, file_url, created_at')
      .in('group_id', groupIds)
      .order('created_at', { ascending: false })
      .limit(200),
    supabase.from('exams')
      .select('id, group_id, title, exam_type, scheduled_at, exam_results(score, max_score, comment)')
      .in('group_id', groupIds)
      .order('scheduled_at', { ascending: false })
      .limit(100),
    supabase.from('support_sessions')
      .select('id, group_id, teacher_id, starts_at, ends_at, status, comment')
      .eq('student_id', student.id)
      .order('starts_at', { ascending: false })
      .limit(100),
  ])

  for (const result of [groupsResult, paymentsResult, coinsResult, productsResult, materialsResult, examsResult, supportResult]) {
    if (result.error) throw result.error
  }

  const groupRows = groupsResult.data ?? []
  const teachersById = new Map()
  const courseIds = [...new Set(groupRows.map((group) => group.course_id).filter(Boolean))]
  const teacherIds = [...new Set(groupRows.map((group) => group.teacher_id))]
  if (courseIds.length || teacherIds.length) {
    const [coursesResult, teachersResult] = await Promise.all([
      courseIds.length ? supabase.from('courses').select('id, name').in('id', courseIds) : Promise.resolve({ data: [], error: null }),
      teacherIds.length ? supabase.from('profiles').select('id, full_name').in('id', teacherIds) : Promise.resolve({ data: [], error: null }),
    ])
    if (coursesResult.error) throw coursesResult.error
    if (teachersResult.error) throw teachersResult.error
    const coursesById = new Map((coursesResult.data ?? []).map((course) => [course.id, course.name]))
    for (const teacher of teachersResult.data ?? []) teachersById.set(teacher.id, teacher.full_name)
    for (const group of groupRows) {
      group.course_name = coursesById.get(group.course_id) ?? 'Kurs biriktirilmagan'
      group.teacher_name = teachersById.get(group.teacher_id) ?? 'O‘qituvchi'
    }
  }

  const exams = examsResult.data ?? []
  const examIds = exams.map((exam) => exam.id)
  let results = []
  if (examIds.length) {
    const { data, error } = await supabase
      .from('exam_results')
      .select('id, exam_id, score, max_score, comment, exams(title, exam_type, scheduled_at)')
      .eq('student_id', student.id)
      .in('exam_id', examIds)
      .limit(100)
    if (error) throw error
    results = data ?? []
  }

  return {
    student,
    memberships: memberships ?? [],
    groups: groupRows,
    payments: paymentsResult.data ?? [],
    coins: coinsResult.data ?? [],
    products: productsResult.data ?? [],
    materials: materialsResult.data ?? [],
    exams,
    results,
    support: supportResult.data ?? [],
  }
}

export async function loadTeacherData(userId) {
  requireSupabase()

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('id, full_name, phone, role, branch_id, registered_at')
    .eq('id', userId)
    .eq('role', 'teacher')
    .single()
  if (profileError) throw profileError

  const { data: groups, error: groupsError } = await supabase
    .from('groups')
    .select('id, name, course_id, branch_id, teacher_id, lesson_start, lesson_end, lesson_days, start_date, end_date, status')
    .eq('teacher_id', userId)
    .order('name')
    .limit(100)
  if (groupsError) throw groupsError

  if (!groups.length) {
    return { profile, groups: [], memberships: [], students: [], tasks: [], submissions: [], attendance: [] }
  }

  const groupIds = groups.map((group) => group.id)
  const [membershipsResult, tasksResult, attendanceResult, coursesResult, branchesResult] = await Promise.all([
    supabase.from('group_students')
      .select('group_id, student_id, status')
      .in('group_id', groupIds)
      .eq('status', 'active')
      .limit(2000),
    supabase.from('tasks')
      .select('id, group_id, title, description, due_at, created_at')
      .in('group_id', groupIds)
      .order('due_at', { ascending: true })
      .limit(500),
    supabase.from('attendance')
      .select('group_id, student_id, lesson_date, status')
      .in('group_id', groupIds)
      .gte('lesson_date', new Date(Date.now() - 90 * 86400000).toISOString().slice(0, 10))
      .limit(5000),
    supabase.from('courses').select('id, name').eq('is_active', true).limit(500),
    supabase.from('branches').select('id, name').limit(500),
  ])

  for (const result of [membershipsResult, tasksResult, attendanceResult, coursesResult, branchesResult]) {
    if (result.error) throw result.error
  }

  const memberships = membershipsResult.data ?? []
  const studentIds = [...new Set(memberships.map((membership) => membership.student_id))]
  let students = []
  if (studentIds.length) {
    const { data, error } = await supabase
      .from('students')
      .select('id, full_name, phone, status')
      .in('id', studentIds)
      .limit(2000)
    if (error) throw error
    students = data ?? []
  }

  const tasks = tasksResult.data ?? []
  const taskIds = tasks.map((task) => task.id)
  let submissions = []
  if (taskIds.length) {
    const { data, error } = await supabase
      .from('task_submissions')
      .select('id, task_id, student_id, status, score')
      .in('task_id', taskIds)
      .limit(10000)
    if (error) throw error
    submissions = data ?? []
  }

  const coursesById = new Map((coursesResult.data ?? []).map((course) => [course.id, course.name]))
  const branchesById = new Map((branchesResult.data ?? []).map((branch) => [branch.id, branch.name]))
  const studentCountByGroup = new Map()
  for (const membership of memberships) {
    studentCountByGroup.set(membership.group_id, (studentCountByGroup.get(membership.group_id) ?? 0) + 1)
  }

  return {
    profile: {
      ...profile,
      branch_name: branchesById.get(profile.branch_id) ?? 'Filial biriktirilmagan',
    },
    groups: groups.map((group) => ({
      ...group,
      course_name: coursesById.get(group.course_id) ?? 'Kurs biriktirilmagan',
      branch_name: branchesById.get(group.branch_id) ?? 'Filial biriktirilmagan',
      student_count: studentCountByGroup.get(group.id) ?? 0,
    })),
    memberships,
    students,
    tasks,
    submissions,
    attendance: attendanceResult.data ?? [],
  }
}
