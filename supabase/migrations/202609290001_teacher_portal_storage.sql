-- Phase 1: shared storage model for the teacher panel.
-- Passwords belong only to Supabase Auth; never copy them into public tables.

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  phone text not null unique,
  role text not null check (role in ('admin', 'ceo', 'manager', 'cashier', 'teacher', 'student')),
  branch_id uuid references public.branches (id) on delete set null,
  registered_at date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  course_id uuid references public.courses (id) on delete set null,
  branch_id uuid references public.branches (id) on delete set null,
  teacher_id uuid not null references public.profiles (id) on delete restrict,
  lesson_start time,
  lesson_end time,
  lesson_days smallint[] not null default '{}'::smallint[],
  start_date date,
  end_date date,
  monthly_price numeric(12, 2) not null default 0 check (monthly_price >= 0),
  next_payment_date date,
  status text not null default 'active' check (status in ('active', 'frozen', 'finished', 'archived')),
  created_at timestamptz not null default now(),
  unique (branch_id, name)
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique references auth.users (id) on delete set null,
  full_name text not null,
  phone text not null unique,
  birth_date date,
  gender text,
  source text,
  status text not null default 'active',
  balance numeric(12, 2) not null default 0,
  rating numeric(8, 2) not null default 0,
  app_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.group_students (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  student_id uuid not null references public.students (id) on delete cascade,
  status text not null default 'active' check (status in ('active', 'paused', 'left', 'archived')),
  joined_at date not null default current_date,
  left_at date,
  unique (group_id, student_id)
);

create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  student_id uuid not null references public.students (id) on delete cascade,
  lesson_date date not null,
  status text not null check (status in ('came', 'absent', 'excused', 'not_done', 'pending')),
  comment text,
  marked_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  unique (group_id, student_id, lesson_date)
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  title text not null,
  description text,
  due_at timestamptz,
  created_by uuid not null references public.profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.task_submissions (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks (id) on delete cascade,
  student_id uuid not null references public.students (id) on delete cascade,
  status text not null default 'not_submitted' check (status in ('not_submitted', 'submitted', 'checked', 'returned')),
  submitted_at timestamptz,
  score numeric(8, 2),
  feedback text,
  checked_by uuid references public.profiles (id) on delete set null,
  checked_at timestamptz,
  created_at timestamptz not null default now(),
  unique (task_id, student_id)
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students (id) on delete restrict,
  group_id uuid references public.groups (id) on delete set null,
  payment_date date not null default current_date,
  payment_type text not null check (payment_type in ('debt', 'paid', 'refund')),
  amount numeric(12, 2) not null check (amount >= 0),
  refunded_amount numeric(12, 2) not null default 0 check (refunded_amount >= 0),
  bonus numeric(12, 2) not null default 0 check (bonus >= 0),
  payment_method text,
  comment text,
  received_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.coin_transactions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students (id) on delete cascade,
  amount integer not null check (amount <> 0),
  reason text not null,
  source text not null default 'manual' check (source in ('manual', 'attendance', 'homework', 'test', 'purchase', 'adjustment')),
  awarded_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.coin_products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  image_url text,
  coin_price integer not null check (coin_price >= 0),
  category text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.coin_orders (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students (id) on delete cascade,
  product_id uuid not null references public.coin_products (id) on delete restrict,
  coin_price integer not null check (coin_price >= 0),
  status text not null default 'requested' check (status in ('requested', 'approved', 'rejected', 'fulfilled')),
  created_at timestamptz not null default now(),
  handled_by uuid references public.profiles (id) on delete set null
);

create table if not exists public.study_materials (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  title text not null,
  topic text,
  file_url text not null,
  created_by uuid not null references public.profiles (id) on delete restrict,
  created_at timestamptz not null default now()
);

create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  title text not null,
  exam_type text not null default 'group' check (exam_type in ('group', 'mock', 'test')),
  scheduled_at timestamptz,
  created_by uuid not null references public.profiles (id) on delete restrict,
  created_at timestamptz not null default now()
);

create table if not exists public.exam_results (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams (id) on delete cascade,
  student_id uuid not null references public.students (id) on delete cascade,
  score numeric(8, 2),
  max_score numeric(8, 2),
  comment text,
  recorded_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  unique (exam_id, student_id)
);

create table if not exists public.support_sessions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  student_id uuid not null references public.students (id) on delete cascade,
  teacher_id uuid not null references public.profiles (id) on delete restrict,
  starts_at timestamptz,
  ends_at timestamptz,
  status text not null default 'scheduled' check (status in ('scheduled', 'completed', 'cancelled')),
  comment text,
  created_at timestamptz not null default now()
);

create index if not exists groups_teacher_status_idx on public.groups (teacher_id, status);
create index if not exists group_students_student_status_idx on public.group_students (student_id, status);
create index if not exists attendance_group_date_idx on public.attendance (group_id, lesson_date desc);
create index if not exists attendance_student_date_idx on public.attendance (student_id, lesson_date desc);
create index if not exists tasks_group_due_idx on public.tasks (group_id, due_at);
create index if not exists submissions_student_status_idx on public.task_submissions (student_id, status);
create index if not exists payments_student_date_idx on public.payments (student_id, payment_date desc);
create index if not exists coin_transactions_student_date_idx on public.coin_transactions (student_id, created_at desc);
create index if not exists study_materials_group_created_idx on public.study_materials (group_id, created_at desc);
create index if not exists exams_group_date_idx on public.exams (group_id, scheduled_at);
create index if not exists support_teacher_start_idx on public.support_sessions (teacher_id, starts_at);

create or replace function public.current_profile_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select p.role from public.profiles p where p.id = (select auth.uid())
$$;

create or replace function public.is_admin_user()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(public.current_profile_role() in ('admin', 'ceo', 'manager', 'cashier'), false)
$$;

create or replace function public.is_teacher_of_group(target_group_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.groups g
    where g.id = target_group_id and g.teacher_id = (select auth.uid())
  )
$$;

create or replace function public.is_student_owner(target_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.students s
    where s.id = target_student_id and s.auth_user_id = (select auth.uid())
  )
$$;

create or replace function public.is_student_in_group(target_group_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.group_students gs
    join public.students s on s.id = gs.student_id
    where gs.group_id = target_group_id and s.auth_user_id = (select auth.uid())
  )
$$;

create or replace function public.is_teacher_of_task(target_task_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.tasks t
    join public.groups g on g.id = t.group_id
    where t.id = target_task_id and g.teacher_id = (select auth.uid())
  )
$$;

alter table public.branches enable row level security;
alter table public.courses enable row level security;
alter table public.profiles enable row level security;
alter table public.groups enable row level security;
alter table public.students enable row level security;
alter table public.group_students enable row level security;
alter table public.attendance enable row level security;
alter table public.tasks enable row level security;
alter table public.task_submissions enable row level security;
alter table public.payments enable row level security;
alter table public.coin_transactions enable row level security;
alter table public.coin_products enable row level security;
alter table public.coin_orders enable row level security;
alter table public.study_materials enable row level security;
alter table public.exams enable row level security;
alter table public.exam_results enable row level security;
alter table public.support_sessions enable row level security;

grant select, insert, update, delete on
  public.branches, public.courses, public.profiles, public.groups,
  public.students, public.group_students, public.attendance, public.tasks,
  public.task_submissions, public.payments, public.coin_transactions,
  public.coin_products, public.coin_orders, public.study_materials,
  public.exams, public.exam_results, public.support_sessions
  to authenticated;

create policy branches_read_authenticated on public.branches
  for select to authenticated using (true);
create policy branches_admin_manage on public.branches
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy courses_read_authenticated on public.courses
  for select to authenticated using (true);
create policy courses_admin_manage on public.courses
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy profiles_read_self_or_admin on public.profiles
  for select to authenticated using (id = (select auth.uid()) or public.is_admin_user());
create policy profiles_admin_manage on public.profiles
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy groups_read_assigned on public.groups
  for select to authenticated using (
    public.is_admin_user()
    or teacher_id = (select auth.uid())
    or public.is_student_in_group(id)
  );
create policy groups_admin_manage on public.groups
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy students_read_related on public.students
  for select to authenticated using (
    public.is_admin_user()
    or auth_user_id = (select auth.uid())
    or exists (
      select 1 from public.group_students gs
      join public.groups g on g.id = gs.group_id
      where gs.student_id = id and g.teacher_id = (select auth.uid())
    )
  );
create policy students_admin_manage on public.students
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy group_students_read_related on public.group_students
  for select to authenticated using (
    public.is_admin_user()
    or public.is_teacher_of_group(group_id)
    or public.is_student_owner(student_id)
  );
create policy group_students_admin_manage on public.group_students
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy attendance_read_related on public.attendance
  for select to authenticated using (
    public.is_admin_user()
    or public.is_teacher_of_group(group_id)
    or public.is_student_owner(student_id)
  );
create policy attendance_teacher_mark on public.attendance
  for all to authenticated using (
    public.is_admin_user() or public.is_teacher_of_group(group_id)
  ) with check (
    public.is_admin_user() or public.is_teacher_of_group(group_id)
  );

create policy tasks_read_related on public.tasks
  for select to authenticated using (
    public.is_admin_user()
    or public.is_teacher_of_group(group_id)
    or public.is_student_in_group(group_id)
  );
create policy tasks_teacher_manage on public.tasks
  for all to authenticated using (
    public.is_admin_user() or public.is_teacher_of_group(group_id)
  ) with check (
    public.is_admin_user() or public.is_teacher_of_group(group_id)
  );

create policy submissions_read_related on public.task_submissions
  for select to authenticated using (
    public.is_admin_user()
    or public.is_teacher_of_task(task_id)
    or public.is_student_owner(student_id)
  );
create policy submissions_teacher_grade on public.task_submissions
  for update to authenticated using (
    public.is_admin_user() or public.is_teacher_of_task(task_id)
  ) with check (
    public.is_admin_user() or public.is_teacher_of_task(task_id)
  );
create policy submissions_student_submit on public.task_submissions
  for insert to authenticated with check (public.is_student_owner(student_id));

create policy payments_read_admin_or_owner on public.payments
  for select to authenticated using (
    public.is_admin_user() or public.is_student_owner(student_id)
  );
create policy payments_admin_manage on public.payments
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy coins_read_admin_or_owner on public.coin_transactions
  for select to authenticated using (
    public.is_admin_user() or public.is_student_owner(student_id)
  );
create policy coins_admin_manage on public.coin_transactions
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy products_read_active on public.coin_products
  for select to authenticated using (is_active or public.is_admin_user());
create policy products_admin_manage on public.coin_products
  for all to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy coin_orders_read_admin_or_owner on public.coin_orders
  for select to authenticated using (
    public.is_admin_user() or public.is_student_owner(student_id)
  );
create policy coin_orders_student_request on public.coin_orders
  for insert to authenticated with check (public.is_student_owner(student_id));
create policy coin_orders_admin_manage on public.coin_orders
  for update to authenticated using (public.is_admin_user()) with check (public.is_admin_user());

create policy materials_read_related on public.study_materials
  for select to authenticated using (
    public.is_admin_user()
    or public.is_teacher_of_group(group_id)
    or public.is_student_in_group(group_id)
  );
create policy materials_teacher_manage on public.study_materials
  for all to authenticated using (
    public.is_admin_user() or public.is_teacher_of_group(group_id)
  ) with check (
    public.is_admin_user() or public.is_teacher_of_group(group_id)
  );

create policy exams_read_related on public.exams
  for select to authenticated using (
    public.is_admin_user()
    or public.is_teacher_of_group(group_id)
    or public.is_student_in_group(group_id)
  );
create policy exams_teacher_manage on public.exams
  for all to authenticated using (
    public.is_admin_user() or public.is_teacher_of_group(group_id)
  ) with check (
    public.is_admin_user() or public.is_teacher_of_group(group_id)
  );

create policy exam_results_read_related on public.exam_results
  for select to authenticated using (
    public.is_admin_user()
    or public.is_student_owner(student_id)
    or exists (
      select 1 from public.exams e
      join public.groups g on g.id = e.group_id
      where e.id = exam_id and g.teacher_id = (select auth.uid())
    )
  );
create policy exam_results_teacher_manage on public.exam_results
  for all to authenticated using (
    public.is_admin_user()
    or exists (
      select 1 from public.exams e
      join public.groups g on g.id = e.group_id
      where e.id = exam_id and g.teacher_id = (select auth.uid())
    )
  ) with check (
    public.is_admin_user()
    or exists (
      select 1 from public.exams e
      join public.groups g on g.id = e.group_id
      where e.id = exam_id and g.teacher_id = (select auth.uid())
    )
  );

create policy support_read_related on public.support_sessions
  for select to authenticated using (
    public.is_admin_user()
    or teacher_id = (select auth.uid())
    or public.is_student_owner(student_id)
  );
create policy support_teacher_manage on public.support_sessions
  for all to authenticated using (
    public.is_admin_user() or teacher_id = (select auth.uid())
  ) with check (
    public.is_admin_user() or teacher_id = (select auth.uid())
  );
