-- PROFILES
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  timezone text default 'Asia/Karachi',
  created_at timestamptz default now()
);

-- HABIT MODULES
create table if not exists habit_modules (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  habit_name text not null,
  goal_description text,
  why_it_matters text,
  blockers text[],
  daily_plan jsonb,
  obstacle_playbook jsonb,
  env_design_tips text[],
  phase int default 1,
  status text default 'active',
  streak_count int default 0,
  start_date date default current_date,
  created_at timestamptz default now()
);

-- DAILY LOGS
create table if not exists daily_logs (
  id uuid default gen_random_uuid() primary key,
  module_id uuid references habit_modules(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  log_date date not null,
  completed boolean default false,
  note text,
  created_at timestamptz default now(),
  unique(module_id, log_date)
);

-- REMINDERS
create table if not exists reminders (
  id uuid default gen_random_uuid() primary key,
  module_id uuid references habit_modules(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  scheduled_at timestamptz not null,
  content text not null,
  phase int,
  delivered boolean default false,
  snoozed boolean default false,
  snooze_count int default 0,
  created_at timestamptz default now()
);

-- CHECKINS
create table if not exists checkins (
  id uuid default gen_random_uuid() primary key,
  module_id uuid references habit_modules(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  checkin_day int,
  user_response text,
  ai_decision text,
  ai_message text,
  created_at timestamptz default now()
);

-- CHAT MESSAGES
create table if not exists chat_messages (
  id uuid default gen_random_uuid() primary key,
  module_id uuid references habit_modules(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  role text not null,
  content text not null,
  created_at timestamptz default now()
);
