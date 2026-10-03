<!-- TEACHER MODE -->
<template>
  <div id="teacherApp" ref="localizedRoot" class="teacher-app" :class="{ 'board-mode': page === 'board' }">
    <template v-if="page !== 'board'">
      <header class="teacher-header">
        <a class="teacher-logo" href="/teacher" @click.prevent="page = 'groups'">
          <span class="teacher-logo-mark">T</span><span>Tasnim</span>
        </a>
        <nav class="teacher-nav" aria-label="O'qituvchi menyusi">
          <button v-for="item in navigation" :key="item.id" :class="{ active: page === item.id }" @click="page = item.id">
            <component :is="item.icon" :size="17" :stroke-width="1.8" />{{ item.label }}
          </button>
        </nav>
        <button class="portal-language-switch" :aria-label="locale === 'uz' ? 'Русский' : 'O‘zbekcha'" @click="toggleLanguage">{{ locale.toUpperCase() }}</button>
        <div class="teacher-profile-menu" @click.stop>
          <button class="teacher-avatar-button" aria-label="Profil menyusi" :aria-expanded="profileMenuOpen" @click="profileMenuOpen = !profileMenuOpen">
            <span>{{ initials }}</span><i></i>
          </button>
          <section v-if="profileMenuOpen" class="teacher-popover">
            <div class="popover-person"><span class="popover-avatar">{{ initials }}</span><div><b>{{ profile.full_name }}</b><small>O'qituvchi</small></div></div>
            <div class="popover-divider"></div>
            <button @click="showBadge"><IdCard :size="16" /> Mening beyjigim</button>
            <button @click="telegramNotice"><Send :size="16" /> Telegramga ulanish</button>
            <button class="popover-logout" @click="emit('logout')"><LogOut :size="16" /> Chiqish</button>
          </section>
        </div>
      </header>

      <main class="teacher-main">
        <div v-if="loadError" class="teacher-state error-state" role="alert">
          <CircleAlert :size="20" /><span>{{ loadError }}</span><button @click="loadData">Qayta urinish</button>
        </div>
        <div v-else-if="loading" class="teacher-state"><LoaderCircle class="spin" :size="20" />Ma'lumotlar yuklanmoqda...</div>

        <template v-else-if="page === 'groups'">
          <div class="teacher-page-title"><div><span class="eyebrow">O'QITUVCHI PANELI</span><h1>Xush kelibsiz, {{ profile.full_name }}</h1></div><div class="today-chip"><CalendarDays :size="15" />{{ currentDateLabel }}</div></div>
          <div class="dashboard-layout">
            <aside class="teacher-sidebar">
              <section class="panel-card teacher-info-card">
                <div class="panel-title"><UserRound :size="17" /><h2>Mening ma'lumotlarim</h2></div>
                <div class="teacher-info-avatar">{{ initials }}</div>
                <div class="teacher-info-name">{{ profile.full_name }}</div>
                <div class="info-list">
                  <div><span>Ro'yxatdan o'tgan sana</span><b>{{ formatDate(profile.registered_at) }}</b></div>
                  <div><span>Filial</span><b>{{ profile.branch_name || 'Filial biriktirilmagan' }}</b></div>
                  <div><span>O'qitayotgan kurslar</span><b>{{ courseNames || 'Kurs biriktirilmagan' }}</b></div>
                  <div><span>Faol guruhlar</span><b>{{ activeGroups.length }}</b></div>
                  <div><span>Faol o'quvchilar soni</span><b>{{ activeStudentCount }}</b></div>
                  <div><span>Kontakt</span><b>{{ profile.phone }}</b></div>
                </div>
              </section>
              <section class="panel-card queue-card">
                <div class="panel-title"><ClipboardCheck :size="17" /><h2>Ish navbati</h2><span class="small-count">{{ pendingChecks }}</span></div>
                <p>{{ pendingChecks ? `${pendingChecks} ta vazifa tekshirilishi kerak` : 'Tekshiriladigan vazifalar yo‘q' }}</p>
                <button class="text-link" @click="page = 'tasks'">Vazifalarni ko'rish <ArrowRight :size="14" /></button>
              </section>
            </aside>

            <section class="teacher-content-column">
              <section class="attention-card">
                <div class="attention-icon"><BellRing :size="17" /></div>
                <div><h2>Diqqat talab qiladi</h2><p>{{ attentionSummary }}</p></div>
                <span class="attention-count">{{ attentionCount }}</span>
              </section>
              <div class="section-heading"><div><h2>Guruhlar</h2><p>Siz biriktirilgan faol guruhlar</p></div><label class="archive-toggle"><input v-model="showArchived" type="checkbox" />Arxiv</label></div>
              <div v-if="visibleGroups.length" class="group-grid">
                <article v-for="group in visibleGroups" :key="group.id" class="group-card">
                  <div class="group-card-head"><div class="course-mark"><BookOpenCheck :size="18" /></div><span class="group-status" :class="group.status">{{ group.status === 'active' ? 'Faol' : group.status === 'archived' ? 'Arxiv' : group.status === 'frozen' ? 'Muzlatilgan' : 'Tugatilgan' }}</span></div>
                  <h3>{{ group.name }}</h3><p class="group-course">{{ group.course_name }}</p>
                  <div class="group-meta"><span><Clock3 :size="14" />{{ timeRange(group) }}</span><span><UsersRound :size="14" />{{ group.student_count }} o'quvchi</span></div>
                  <div class="group-days"><span v-for="day in formatDays(group.lesson_days)" :key="day">{{ day }}</span></div>
                  <div class="group-footer"><span>{{ formatDate(group.start_date) }} <i>→</i> {{ formatDate(group.end_date) }}</span><button :aria-label="`${group.name} guruhini ochish`" @click="openGroup(group)"><ArrowUpRight :size="16" /></button></div>
                </article>
              </div>
              <div v-else class="teacher-empty"><UsersRound :size="24" /><b>Guruhlar mavjud emas</b><span>Sizga hozircha faol guruh biriktirilmagan.</span></div>
            </section>
          </div>
        </template>

        <template v-else-if="page === 'tasks'">
          <div class="teacher-page-title"><div><span class="eyebrow">O'QITUVCHI PANELI</span><h1>Vazifalar</h1></div><div class="task-summary"><ClipboardList :size="16" />{{ taskRows.length }} o'quvchi</div></div>
          <section class="panel-card tasks-panel">
            <div class="tasks-toolbar"><label class="task-search"><Search :size="16" /><input v-model="taskSearch" type="search" placeholder="O'quvchini qidirish" /></label><label class="teacher-group-filter"><span class="sr-only">Guruh filtri</span><select v-model="taskGroupFilter"><option value="">Barcha guruhlar</option><option v-for="group in groups" :key="group.id" :value="group.id">{{ group.name }}</option></select><ChevronDown :size="15" /></label></div>
            <div v-if="taskRows.length" class="table-scroll"><table class="teacher-table"><thead><tr><th>Tartib</th><th>O'quvchi nomi</th><th>Guruh</th><th>Telefon</th><th>Jami vazifalar</th><th>Topshirilgan</th><th>Tekshirilmagan</th><th>O'rtacha ball</th><th>Amallar</th></tr></thead><tbody><tr v-for="(row, index) in filteredTaskRows" :key="`${row.groupId}-${row.studentId}`"><td>{{ index + 1 }}</td><td><b>{{ row.student.full_name }}</b></td><td><span class="table-group-chip">{{ row.group.name }}</span></td><td>{{ row.student.phone }}</td><td>{{ row.total }}</td><td>{{ row.submitted }}</td><td><span :class="row.unchecked ? 'unchecked-count' : 'checked-count'">{{ row.unchecked }}</span></td><td>{{ row.averageScore }}</td><td><button class="table-action" :disabled="!row.total" @click="focusGroupTasks(row.group)">Ko'rish</button></td></tr></tbody></table></div>
            <div v-else class="teacher-empty compact-empty"><ClipboardList :size="23" /><b>{{ groups.length ? 'O‘quvchilar topilmadi' : 'Guruhlar mavjud emas' }}</b><span>{{ groups.length ? 'Tanlangan guruhlarda o‘quvchi ro‘yxati yo‘q.' : 'Vazifalar o‘qituvchiga biriktirilgan guruhlar bo‘yicha ko‘rsatiladi.' }}</span></div>
          </section>
        </template>
      </main>

      <section v-if="page === 'board'" class="board-screen">
        <header class="board-toolbar"><button class="board-home" aria-label="Guruhlarga qaytish" @click="page = 'groups'"><Home :size="18" /></button><div class="board-title"><Presentation :size="18" /><b>Elektron doska</b></div><div class="board-tools"><label class="board-color"><span>Rang</span><input v-model="brushColor" type="color" /></label><label class="board-size"><span>Qalam</span><input v-model.number="brushSize" type="range" min="1" max="20" /></label><button aria-label="O'chirg'ich" :class="{ selected: erasing }" @click="erasing = !erasing"><Eraser :size="17" /></button><button aria-label="Tozalash" @click="clearBoard"><Trash2 :size="17" /></button></div></header>
        <div class="board-canvas-wrap"><canvas ref="canvas" class="teacher-canvas" @pointerdown="startDrawing" @pointermove="draw" @pointerup="stopDrawing" @pointercancel="stopDrawing" @pointerleave="stopDrawing"></canvas></div>
      </section>

      <div v-if="profileMenuOpen && page === 'board'" class="sr-only">Profil menyusi</div>
      <div v-if="badgeOpen" class="teacher-modal-backdrop" @click.self="badgeOpen = false">
        <section class="badge-modal" role="dialog" aria-modal="true" aria-labelledby="badge-title"><header><h2 id="badge-title">Mening beyjigim</h2><button aria-label="Yopish" @click="badgeOpen = false"><X :size="18" /></button></header><div class="badge-side-switch"><button :class="{ active: badgeSide === 'front' }" @click="badgeSide = 'front'">Old tomoni</button><button :class="{ active: badgeSide === 'back' }" @click="badgeSide = 'back'">Orqa tomoni</button></div><article class="teacher-badge" :class="badgeSide"><div class="badge-brand">TASNIM <span>EDUCATION</span></div><template v-if="badgeSide === 'front'"><div class="badge-avatar">{{ initials }}</div><h3>{{ profile.full_name }}</h3><p>O'QITUVCHI</p><span class="badge-branch">{{ profile.branch_name }}</span></template><template v-else><div class="badge-back-mark">T</div><p>{{ profile.phone }}</p><p>{{ profile.branch_name }}</p><small>O'qituvchi ID: {{ profile.id.slice(0, 8) }}</small></template></article><footer><button class="badge-print" @click="printBadge"><Printer :size="16" /> Chop etish / PDF</button></footer></section>
      </div>
    </template>

    <div v-if="toast" class="teacher-toast" role="status">{{ toast }}</div>
  </div>
</template>

<script setup>
/* TEACHER MODE */
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import {
  ArrowRight, ArrowUpRight, BellRing, BookOpenCheck, CalendarDays, Check,
  ChevronDown, CircleAlert, ClipboardCheck, ClipboardList, Clock3, Eraser,
  GraduationCap, Home, IdCard, LoaderCircle, LogOut, UsersRound, Presentation,
  Printer, Search, Send, Trash2, UserRound, X,
} from 'lucide-vue-next'
import { loadTeacherData } from './teacherService.js'
import { locale, setLocale, useLocalizedDOM } from '../locale.js'

const props = defineProps({
  session: { type: Object, required: true },
  demo: { type: Boolean, default: false },
})
const emit = defineEmits(['logout'])
const localizedRoot = ref(null)
useLocalizedDOM(localizedRoot)
function toggleLanguage() {
  setLocale(locale.value === 'uz' ? 'ru' : 'uz')
}
const navigation = [
  { id: 'groups', label: 'Guruhlar', icon: UsersRound },
  { id: 'tasks', label: 'Vazifalar', icon: ClipboardList },
  { id: 'board', label: 'Elektron doska', icon: Presentation },
]
const page = ref('groups')
const loading = ref(true)
const loadError = ref('')
const data = ref({ profile: props.session.profile, groups: [], memberships: [], students: [], tasks: [], submissions: [], attendance: [] })
const profileMenuOpen = ref(false)
const badgeOpen = ref(false)
const badgeSide = ref('front')
const showArchived = ref(false)
const taskSearch = ref('')
const taskGroupFilter = ref('')
const toast = ref('')
const canvas = ref(null)
const brushColor = ref('#202333')
const brushSize = ref(4)
const erasing = ref(false)
let toastTimer
let drawing = false
let canvasResizeObserver

const profile = computed(() => data.value.profile ?? props.session.profile)
const groups = computed(() => data.value.groups)
const activeGroups = computed(() => groups.value.filter((group) => group.status === 'active'))
const visibleGroups = computed(() => groups.value.filter((group) => showArchived.value ? group.status === 'archived' : group.status !== 'archived'))
const initials = computed(() => profile.value.full_name.split(/\s+/).map((part) => part[0]).slice(0, 2).join('').toUpperCase())
const currentDateLabel = computed(() => new Intl.DateTimeFormat(locale.value === 'ru' ? 'ru-RU' : 'uz-UZ', { dateStyle: 'long' }).format(new Date()))
const courseNames = computed(() => [...new Set(activeGroups.value.map((group) => group.course_name).filter(Boolean))].join(', '))
const activeStudentCount = computed(() => new Set(data.value.memberships.filter((membership) => activeGroups.value.some((group) => group.id === membership.group_id)).map((membership) => membership.student_id)).size)
const pendingChecks = computed(() => data.value.submissions.filter((submission) => submission.status === 'submitted').length)
const overdueTasks = computed(() => data.value.tasks.filter((task) => task.due_at && new Date(task.due_at) < new Date()).length)
const attentionCount = computed(() => pendingChecks.value + overdueTasks.value)
const attentionSummary = computed(() => attentionCount.value ? `${pendingChecks.value} ta tekshirilmagan ish, ${overdueTasks.value} ta muddati o'tgan vazifa` : "Hozircha alohida e'tibor talab qiladigan ish yo'q.")
const taskRows = computed(() => {
  const studentById = new Map(data.value.students.map((student) => [student.id, student]))
  const submissionsByTaskStudent = new Map(data.value.submissions.map((submission) => [`${submission.task_id}:${submission.student_id}`, submission]))
  const tasksByGroup = new Map()
  for (const task of data.value.tasks) {
    const list = tasksByGroup.get(task.group_id) ?? []
    list.push(task)
    tasksByGroup.set(task.group_id, list)
  }
  const groupById = new Map(groups.value.map((group) => [group.id, group]))
  return data.value.memberships.flatMap((membership) => {
    const group = groupById.get(membership.group_id)
    const student = studentById.get(membership.student_id)
    if (!group || !student) return []
    const groupTasks = tasksByGroup.get(group.id) ?? []
    const studentSubmissions = groupTasks.map((task) => submissionsByTaskStudent.get(`${task.id}:${student.id}`)).filter(Boolean)
    const submitted = studentSubmissions.filter((submission) => ['submitted', 'checked', 'returned'].includes(submission.status)).length
    const unchecked = studentSubmissions.filter((submission) => submission.status === 'submitted').length
    const scores = studentSubmissions.filter((submission) => submission.status === 'checked' && Number.isFinite(Number(submission.score))).map((submission) => Number(submission.score))
    return [{
      groupId: group.id,
      studentId: student.id,
      group,
      student,
      total: groupTasks.length,
      submitted,
      unchecked,
      averageScore: scores.length ? (scores.reduce((sum, score) => sum + score, 0) / scores.length).toFixed(1) : '—',
    }]
  })
})
const filteredTaskRows = computed(() => {
  const query = taskSearch.value.trim().toLocaleLowerCase('uz-UZ')
  return taskRows.value.filter((row) =>
    (!taskGroupFilter.value || row.groupId === taskGroupFilter.value)
    && (!query || `${row.student.full_name} ${row.student.phone} ${row.group.name}`.toLocaleLowerCase('uz-UZ').includes(query)),
  )
})

onMounted(() => {
  loadData()
  window.addEventListener('pointerup', stopDrawing)
})
onBeforeUnmount(() => {
  window.clearTimeout(toastTimer)
  window.removeEventListener('pointerup', stopDrawing)
  canvasResizeObserver?.disconnect()
})
watch(page, async (value) => {
  profileMenuOpen.value = false
  if (value === 'board') {
    await nextTick()
    setupCanvas()
  } else {
    canvasResizeObserver?.disconnect()
  }
})

async function loadData() {
  loading.value = true
  loadError.value = ''
  try {
    if (!props.demo) data.value = await loadTeacherData(profile.value.id)
  } catch (error) {
    loadError.value = error.message || "Ma'lumotlarni yuklashda xatolik yuz berdi."
  } finally {
    loading.value = false
  }
}

function formatDate(value) {
  if (!value) return '—'
  return new Intl.DateTimeFormat(locale.value === 'ru' ? 'ru-RU' : 'uz-UZ', { dateStyle: 'medium', timeZone: 'UTC' }).format(new Date(`${value}T00:00:00Z`))
}
function formatDays(days = []) {
  const names = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya']
  return days.map((day) => names[Number(day) - 1] ?? String(day))
}
function timeRange(group) {
  if (!group.lesson_start || !group.lesson_end) return 'Vaqt belgilanmagan'
  return `${group.lesson_start.slice(0, 5)}–${group.lesson_end.slice(0, 5)}`
}
function openGroup(group) {
  taskGroupFilter.value = group.id
  page.value = 'tasks'
}
function focusGroupTasks(group) {
  openGroup(group)
}
function notify(message) {
  toast.value = message
  window.clearTimeout(toastTimer)
  toastTimer = window.setTimeout(() => { toast.value = '' }, 2400)
}
function telegramNotice() {
  profileMenuOpen.value = false
  notify('Telegram ulanishi hali sozlanmagan.')
}
function showBadge() {
  profileMenuOpen.value = false
  badgeSide.value = 'front'
  badgeOpen.value = true
}
async function printBadge() {
  await nextTick()
  window.print()
}

function setupCanvas() {
  const element = canvas.value
  if (!element) return
  const resize = () => {
    const rect = element.getBoundingClientRect()
    const ratio = window.devicePixelRatio || 1
    element.width = Math.max(1, Math.floor(rect.width * ratio))
    element.height = Math.max(1, Math.floor(rect.height * ratio))
    const context = element.getContext('2d')
    context.setTransform(ratio, 0, 0, ratio, 0, 0)
    context.lineCap = 'round'
    context.lineJoin = 'round'
  }
  canvasResizeObserver?.disconnect()
  canvasResizeObserver = new ResizeObserver(resize)
  canvasResizeObserver.observe(element)
  resize()
}
function pointerPoint(event) {
  const bounds = canvas.value.getBoundingClientRect()
  return { x: event.clientX - bounds.left, y: event.clientY - bounds.top }
}
function startDrawing(event) {
  if (!canvas.value) return
  drawing = true
  canvas.value.setPointerCapture(event.pointerId)
  const point = pointerPoint(event)
  const context = canvas.value.getContext('2d')
  context.beginPath()
  context.moveTo(point.x, point.y)
}
function draw(event) {
  if (!drawing || !canvas.value) return
  const context = canvas.value.getContext('2d')
  const point = pointerPoint(event)
  context.globalCompositeOperation = erasing.value ? 'destination-out' : 'source-over'
  context.strokeStyle = brushColor.value
  context.lineWidth = brushSize.value
  context.lineTo(point.x, point.y)
  context.stroke()
}
function stopDrawing() {
  drawing = false
}
function clearBoard() {
  const context = canvas.value?.getContext('2d')
  if (!context || !canvas.value) return
  context.clearRect(0, 0, canvas.value.width, canvas.value.height)
}
</script>

<style scoped>
#teacherApp {
  --t-accent: #6366f1;
  --t-accent-soft: #eef0ff;
  --t-bg: var(--bg, #f6f7fb);
  --t-surface: var(--surface, #fff);
  --t-ink: var(--ink, #202333);
  --t-muted: var(--ink-soft, #777e90);
  --t-line: var(--line, #e4e6ef);
  --t-green: #16834c;
  min-height: 100vh;
  background: var(--t-bg);
  color: var(--t-ink);
  font-family: Inter, system-ui, sans-serif;
  font-size: 13px;
}

#teacherApp *, #teacherApp *::before, #teacherApp *::after { box-sizing: border-box; }
.teacher-header { position: sticky; top: 0; z-index: 40; display: flex; height: 62px; align-items: center; gap: 30px; padding: 0 30px; border-bottom: 1px solid var(--t-line); background: var(--t-surface); }
.portal-language-switch { flex: 0 0 auto; padding: 6px 9px; border: 1px solid var(--t-line); border-radius: 7px; background: var(--t-surface); color: var(--t-ink); cursor: pointer; font: inherit; font-size: 11px; font-weight: 700; }
.teacher-logo { display: inline-flex; flex: 0 0 auto; align-items: center; gap: 9px; color: var(--t-ink); font-size: 16px; font-weight: 700; text-decoration: none; }
.teacher-logo-mark { display: grid; width: 31px; height: 31px; place-items: center; border-radius: 9px; background: var(--t-accent); color: #fff; font-weight: 700; }
.teacher-nav { display: flex; height: 100%; flex: 1; align-items: center; gap: 7px; }
.teacher-nav button { display: inline-flex; height: 38px; align-items: center; gap: 8px; padding: 0 13px; border: 0; border-radius: 8px; background: transparent; color: var(--t-muted); cursor: pointer; font: inherit; font-size: 12px; font-weight: 600; white-space: nowrap; }
.teacher-nav button:hover { background: color-mix(in srgb, var(--t-accent) 7%, var(--t-surface)); color: var(--t-accent); }
.teacher-nav button.active { background: var(--t-accent); color: #fff; }
.teacher-profile-menu { position: relative; }
.teacher-avatar-button { position: relative; display: grid; width: 36px; height: 36px; place-items: center; border: 1px solid var(--t-line); border-radius: 50%; background: var(--t-accent-soft); color: var(--t-accent); cursor: pointer; font-size: 12px; font-weight: 700; }
.teacher-avatar-button i { position: absolute; right: 0; bottom: 0; width: 9px; height: 9px; border: 2px solid var(--t-surface); border-radius: 50%; background: #28b463; }
.teacher-popover { position: absolute; top: 44px; right: 0; z-index: 70; width: 230px; padding: 10px; border: 1px solid var(--t-line); border-radius: 10px; background: var(--t-surface); box-shadow: 0 12px 32px rgb(20 28 48 / 14%); }
.popover-person { display: flex; align-items: center; gap: 10px; padding: 7px 6px 10px; }
.popover-avatar { display: grid; width: 36px; height: 36px; place-items: center; border-radius: 50%; background: var(--t-accent-soft); color: var(--t-accent); font-weight: 700; }
.popover-person b, .popover-person small { display: block; }
.popover-person b { color: var(--t-ink); font-size: 12px; }
.popover-person small { margin-top: 2px; color: var(--t-muted); font-size: 10px; }
.popover-divider { height: 1px; margin: 3px 0 7px; background: var(--t-line); }
.teacher-popover > button { display: flex; width: 100%; min-height: 35px; align-items: center; gap: 9px; padding: 0 8px; border: 0; border-radius: 6px; background: transparent; color: var(--t-ink); cursor: pointer; font: inherit; font-size: 11px; text-align: left; }
.teacher-popover > button:hover { background: var(--t-bg); }
.teacher-popover > button.popover-logout { color: #cf4350; }
.teacher-main { width: min(1160px, calc(100% - 48px)); margin: 0 auto; padding: 27px 0 44px; }
.teacher-page-title { display: flex; align-items: flex-end; justify-content: space-between; gap: 18px; margin-bottom: 20px; }
.eyebrow { color: var(--t-accent); font-size: 9px; font-weight: 700; letter-spacing: 1px; }
.teacher-page-title h1 { margin: 5px 0 0; color: var(--t-ink); font-size: 23px; font-weight: 650; }
.today-chip, .task-summary { display: inline-flex; align-items: center; gap: 7px; color: var(--t-muted); font-size: 11px; }
.dashboard-layout { display: grid; grid-template-columns: 270px minmax(0, 1fr); align-items: start; gap: 18px; }
.teacher-sidebar { display: flex; flex-direction: column; gap: 14px; }
.panel-card { border: 1px solid var(--t-line); border-radius: 10px; background: var(--t-surface); box-shadow: 0 3px 12px rgb(22 31 54 / 4%); }
.teacher-info-card { padding: 15px; }
.panel-title { display: flex; align-items: center; gap: 8px; color: var(--t-accent); }
.panel-title h2 { margin: 0; color: var(--t-ink); font-size: 13px; font-weight: 650; }
.teacher-info-avatar { display: grid; width: 52px; height: 52px; place-items: center; margin: 19px auto 8px; border-radius: 14px; background: var(--t-accent-soft); color: var(--t-accent); font-size: 17px; font-weight: 700; }
.teacher-info-name { margin-bottom: 15px; color: var(--t-ink); font-size: 15px; font-weight: 650; text-align: center; }
.info-list { display: flex; flex-direction: column; gap: 11px; padding-top: 12px; border-top: 1px solid var(--t-line); }
.info-list div { display: flex; flex-direction: column; gap: 3px; }
.info-list span { color: var(--t-muted); font-size: 9px; }
.info-list b { overflow-wrap: anywhere; color: var(--t-ink); font-size: 11px; font-weight: 550; }
.queue-card { padding: 14px; }
.queue-card p { margin: 11px 0; color: var(--t-muted); font-size: 11px; line-height: 1.45; }
.small-count { display: grid; min-width: 20px; height: 20px; place-items: center; margin-left: auto; border-radius: 50%; background: var(--t-accent-soft); color: var(--t-accent); font-size: 10px; font-weight: 700; }
.text-link { display: inline-flex; align-items: center; gap: 5px; padding: 0; border: 0; background: transparent; color: var(--t-accent); cursor: pointer; font: inherit; font-size: 10px; font-weight: 650; }
.teacher-content-column { min-width: 0; }
.attention-card { display: flex; min-height: 69px; align-items: center; gap: 11px; margin-bottom: 20px; padding: 12px 15px; border: 1px solid #efdba9; border-radius: 9px; background: color-mix(in srgb, #f8e7bc 22%, var(--t-surface)); }
.attention-icon { display: grid; width: 34px; height: 34px; flex: 0 0 auto; place-items: center; border-radius: 9px; background: color-mix(in srgb, #f2c868 22%, var(--t-surface)); color: #b67b18; }
.attention-card h2 { margin: 0 0 3px; color: var(--t-ink); font-size: 12px; }
.attention-card p { margin: 0; color: var(--t-muted); font-size: 10px; }
.attention-count { display: grid; width: 24px; height: 24px; flex: 0 0 auto; place-items: center; margin-left: auto; border-radius: 50%; background: #f5d990; color: #885c0c; font-size: 10px; font-weight: 700; }
.section-heading { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 11px; }
.section-heading h2 { margin: 0; color: var(--t-ink); font-size: 16px; font-weight: 650; }
.section-heading p { margin: 3px 0 0; color: var(--t-muted); font-size: 10px; }
.archive-toggle { display: inline-flex; align-items: center; gap: 6px; color: var(--t-muted); cursor: pointer; font-size: 10px; }
.archive-toggle input { accent-color: var(--t-accent); }
.group-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; }
.group-card { min-width: 0; padding: 14px; border: 1px solid var(--t-line); border-radius: 9px; background: var(--t-surface); }
.group-card-head { display: flex; align-items: center; justify-content: space-between; }
.course-mark { display: grid; width: 32px; height: 32px; place-items: center; border-radius: 9px; background: var(--t-accent-soft); color: var(--t-accent); }
.group-status { padding: 4px 8px; border-radius: 999px; background: #e5f5eb; color: #16834c; font-size: 9px; font-weight: 650; }
.group-status.frozen { background: #fff2d9; color: #a66b0c; }
.group-status.finished, .group-status.archived { background: var(--t-bg); color: var(--t-muted); }
.group-card h3 { margin: 13px 0 3px; color: var(--t-ink); font-size: 15px; font-weight: 650; }
.group-course { min-height: 15px; margin: 0; color: var(--t-muted); font-size: 10px; }
.group-meta { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 13px; color: var(--t-muted); font-size: 9px; }
.group-meta span { display: inline-flex; align-items: center; gap: 5px; }
.group-meta svg { color: var(--t-accent); }
.group-days { display: flex; flex-wrap: wrap; gap: 5px; margin-top: 12px; }
.group-days span { padding: 4px 7px; border-radius: 999px; background: var(--t-bg); color: var(--t-muted); font-size: 8px; }
.group-footer { display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-top: 13px; padding-top: 10px; border-top: 1px solid var(--t-line); color: var(--t-muted); font-size: 9px; }
.group-footer i { padding: 0 3px; color: var(--t-accent); font-style: normal; }
.group-footer button { display: grid; width: 27px; height: 27px; place-items: center; border: 1px solid var(--t-line); border-radius: 7px; background: var(--t-surface); color: var(--t-accent); cursor: pointer; }
.teacher-empty { display: flex; min-height: 230px; flex-direction: column; align-items: center; justify-content: center; gap: 8px; padding: 26px; border: 1px dashed var(--t-line); border-radius: 10px; color: var(--t-muted); text-align: center; }
.teacher-empty > svg { margin-bottom: 3px; color: #a0a5b3; }
.teacher-empty b { color: var(--t-ink); font-size: 13px; }
.teacher-empty span { max-width: 310px; font-size: 10px; line-height: 1.45; }
.compact-empty { min-height: 190px; }
.teacher-state { display: flex; min-height: 220px; align-items: center; justify-content: center; gap: 10px; color: var(--t-muted); font-size: 12px; }
.error-state { flex-wrap: wrap; color: #c13d4a; }
.error-state button { padding: 7px 10px; border: 1px solid var(--t-line); border-radius: 6px; background: var(--t-surface); color: var(--t-accent); cursor: pointer; font: inherit; font-size: 10px; }
#teacherApp .spin { animation: teacher-spin 1s linear infinite; }
@keyframes teacher-spin { to { transform: rotate(360deg); } }
.tasks-panel { overflow: hidden; }
.tasks-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 13px; border-bottom: 1px solid var(--t-line); }
.task-search, .teacher-group-filter { display: flex; height: 36px; align-items: center; gap: 7px; padding: 0 10px; border: 1px solid var(--t-line); border-radius: 7px; background: var(--t-surface); color: var(--t-muted); }
.task-search { width: min(100%, 320px); }
.task-search input { width: 100%; border: 0; outline: 0; background: transparent; color: var(--t-ink); font: inherit; font-size: 11px; }
.teacher-group-filter { position: relative; min-width: 160px; }
.teacher-group-filter select { width: 100%; appearance: none; border: 0; outline: 0; background: transparent; color: var(--t-ink); font: inherit; font-size: 10px; }
.teacher-group-filter svg { pointer-events: none; }
.table-scroll { overflow-x: auto; }
.teacher-table { width: 100%; min-width: 960px; border-collapse: collapse; text-align: left; white-space: nowrap; }
.teacher-table th { height: 39px; padding: 0 12px; border-bottom: 1px solid var(--t-line); background: color-mix(in srgb, var(--t-bg) 55%, var(--t-surface)); color: var(--t-muted); font-size: 9px; font-weight: 650; }
.teacher-table td { height: 46px; padding: 0 12px; border-bottom: 1px solid var(--t-line); color: var(--t-ink); font-size: 10px; }
.teacher-table td b { font-weight: 600; }
.table-group-chip { padding: 4px 7px; border-radius: 5px; background: var(--t-accent-soft); color: var(--t-accent); font-size: 9px; }
.unchecked-count { color: #bd7e13; font-weight: 700; }
.checked-count { color: var(--t-green); }
.table-action { padding: 5px 8px; border: 1px solid var(--t-line); border-radius: 6px; background: var(--t-surface); color: var(--t-accent); cursor: pointer; font: inherit; font-size: 9px; }
.table-action:disabled { cursor: not-allowed; opacity: .45; }
.teacher-board { display: flex; min-height: 100dvh; flex-direction: column; background: var(--t-bg); }
.board-toolbar { display: flex; min-height: 58px; align-items: center; gap: 14px; padding: 0 20px; border-bottom: 1px solid var(--t-line); background: var(--t-surface); }
.board-home, .board-tools > button { display: grid; width: 34px; height: 34px; flex: 0 0 auto; place-items: center; border: 1px solid var(--t-line); border-radius: 8px; background: var(--t-surface); color: var(--t-ink); cursor: pointer; }
.board-home:hover, .board-tools > button:hover, .board-tools > button.selected { border-color: var(--t-accent); color: var(--t-accent); }
.board-title { display: flex; align-items: center; gap: 8px; color: var(--t-ink); font-size: 13px; }
.board-title svg { color: var(--t-accent); }
.board-tools { display: flex; align-items: center; gap: 9px; margin-left: auto; }
.board-color, .board-size { display: flex; align-items: center; gap: 6px; color: var(--t-muted); font-size: 10px; }
.board-color input { width: 28px; height: 26px; padding: 1px; border: 1px solid var(--t-line); border-radius: 5px; background: var(--t-surface); }
.board-size input { width: 90px; accent-color: var(--t-accent); }
.board-canvas-wrap { position: relative; flex: 1; min-height: calc(100dvh - 58px); overflow: hidden; background-color: var(--t-surface); background-image: radial-gradient(var(--t-line) .75px, transparent .75px); background-size: 22px 22px; }
.teacher-canvas { display: block; width: 100%; height: 100%; min-height: calc(100dvh - 58px); touch-action: none; cursor: crosshair; }
.teacher-modal-backdrop { position: fixed; inset: 0; z-index: 90; display: grid; place-items: center; padding: 20px; background: rgb(12 16 29 / 48%); }
.badge-modal { width: min(100%, 370px); padding: 18px; border: 1px solid var(--t-line); border-radius: 12px; background: var(--t-surface); box-shadow: 0 18px 48px rgb(0 0 0 / 18%); }
.badge-modal > header { display: flex; align-items: center; justify-content: space-between; }
.badge-modal h2 { margin: 0; color: var(--t-ink); font-size: 15px; }
.badge-modal > header button { display: grid; width: 29px; height: 29px; place-items: center; border: 0; border-radius: 6px; background: transparent; color: var(--t-muted); cursor: pointer; }
.badge-side-switch { display: flex; gap: 4px; margin: 14px 0; padding: 3px; border-radius: 8px; background: var(--t-bg); }
.badge-side-switch button { flex: 1; height: 29px; border: 0; border-radius: 6px; background: transparent; color: var(--t-muted); cursor: pointer; font: inherit; font-size: 10px; }
.badge-side-switch button.active { background: var(--t-surface); color: var(--t-accent); box-shadow: 0 1px 4px rgb(15 24 48 / 10%); }
.teacher-badge { display: flex; min-height: 230px; flex-direction: column; align-items: center; justify-content: center; overflow: hidden; border: 1px solid var(--t-line); border-radius: 10px; background: linear-gradient(145deg, #6767eb, #4548bf); color: #fff; text-align: center; }
.teacher-badge.back { background: var(--t-bg); color: var(--t-ink); }
.badge-brand { margin-bottom: 12px; font-size: 10px; font-weight: 800; letter-spacing: 1px; }
.badge-brand span { display: block; margin-top: 2px; font-size: 7px; font-weight: 500; letter-spacing: 2px; }
.badge-avatar { display: grid; width: 58px; height: 58px; place-items: center; border: 2px solid rgb(255 255 255 / 75%); border-radius: 50%; background: rgb(255 255 255 / 17%); font-size: 19px; font-weight: 700; }
.teacher-badge h3 { margin: 10px 0 3px; font-size: 17px; }
.teacher-badge p { margin: 4px 0; font-size: 9px; font-weight: 650; letter-spacing: 1px; }
.badge-branch { margin-top: 7px; font-size: 9px; opacity: .8; }
.badge-back-mark { display: grid; width: 46px; height: 46px; place-items: center; border-radius: 11px; background: var(--t-accent); color: #fff; font-size: 23px; font-weight: 700; }
.teacher-badge small { color: var(--t-muted); font-size: 9px; }
.badge-modal footer { display: flex; justify-content: flex-end; margin-top: 14px; }
.badge-print { display: inline-flex; min-height: 34px; align-items: center; gap: 7px; padding: 0 11px; border: 0; border-radius: 7px; background: var(--t-accent); color: #fff; cursor: pointer; font: inherit; font-size: 10px; font-weight: 650; }
.teacher-toast { position: fixed; right: 20px; bottom: 20px; z-index: 100; padding: 10px 14px; border: 1px solid var(--t-line); border-radius: 8px; background: var(--t-surface); color: var(--t-ink); box-shadow: 0 8px 28px rgb(0 0 0 / 13%); font-size: 11px; }
.teacher-app-error { min-height: 100dvh; display: grid; place-items: center; padding: 20px; color: var(--t-muted, #737b8a); font: 13px Inter, system-ui, sans-serif; text-align: center; }
#teacherApp .sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0; }

@media (max-width: 800px) {
  .teacher-header { height: auto; min-height: 60px; flex-wrap: wrap; gap: 8px; padding: 10px 14px; }
  .teacher-nav { order: 3; width: 100%; height: 38px; overflow-x: auto; }
  .teacher-nav button { flex: 0 0 auto; }
  .teacher-profile-menu { margin-left: auto; }
  .teacher-main { width: calc(100% - 28px); padding-top: 20px; }
  .dashboard-layout { grid-template-columns: 1fr; }
  .teacher-sidebar { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); align-items: start; }
  .teacher-info-card { grid-row: span 2; }
  .group-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .teacher-page-title h1 { font-size: 20px; }
}
@media (max-width: 520px) {
  .teacher-sidebar { grid-template-columns: 1fr; }
  .teacher-info-card { grid-row: auto; }
  .group-grid { grid-template-columns: 1fr; }
  .teacher-page-title { align-items: flex-start; flex-direction: column; }
  .tasks-toolbar { align-items: stretch; flex-direction: column; }
  .task-search, .teacher-group-filter { width: 100%; }
  .board-toolbar { flex-wrap: wrap; padding: 10px; }
  .board-title { flex: 1; }
  .board-tools { width: 100%; margin-left: 0; justify-content: flex-end; }
  .board-size input { width: 70px; }
  .teacher-badge { min-height: 210px; }
}
</style>
