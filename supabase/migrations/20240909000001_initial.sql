-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Activities table
create table public.activities (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  color text not null default '#000000',
  position int not null default 0,
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_activities_user_id on public.activities(user_id);

-- Time entries table
create table public.time_entries (
  id uuid primary key default uuid_generate_v4(),
  activity_id uuid not null references public.activities(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  duration_minutes int not null check (duration_minutes > 0),
  date date not null default current_date,
  note text,
  created_at timestamptz not null default now()
);

create index idx_time_entries_user_id on public.time_entries(user_id);
create index idx_time_entries_activity_id on public.time_entries(activity_id);
create index idx_time_entries_user_date on public.time_entries(user_id, date);

-- Updated_at trigger
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger activities_updated_at
  before update on public.activities
  for each row execute function public.set_updated_at();

-- RLS policies
alter table public.activities enable row level security;
alter table public.time_entries enable row level security;

-- Activities: users can only access their own
create policy "Users can select own activities"
  on public.activities for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own activities"
  on public.activities for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update own activities"
  on public.activities for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own activities"
  on public.activities for delete
  to authenticated
  using (auth.uid() = user_id);

-- Time entries: users can only access their own
create policy "Users can select own time_entries"
  on public.time_entries for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own time_entries"
  on public.time_entries for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update own time_entries"
  on public.time_entries for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own time_entries"
  on public.time_entries for delete
  to authenticated
  using (auth.uid() = user_id);

-- RPC: delete anonymous user data
create or replace function public.delete_anonymous_data()
returns void as $$
declare
  v_is_anonymous boolean;
begin
  v_is_anonymous := coalesce(
    (current_setting('request.jwt.claims', true)::jsonb ->> 'is_anonymous')::boolean,
    false
  );

  if not v_is_anonymous then
    raise exception 'Only anonymous users can call this function';
  end if;

  delete from public.time_entries where user_id = auth.uid();
  delete from public.activities where user_id = auth.uid();
end;
$$ language plpgsql security definer;

-- RPC: merge anonymous data to permanent account
create or replace function public.merge_anonymous_to_account(p_target_user_id uuid)
returns void as $$
declare
  v_is_anonymous boolean;
begin
  v_is_anonymous := coalesce(
    (current_setting('request.jwt.claims', true)::jsonb ->> 'is_anonymous')::boolean,
    false
  );

  if not v_is_anonymous then
    raise exception 'Only anonymous users can call this function';
  end if;

  update public.activities set user_id = p_target_user_id where user_id = auth.uid();
  update public.time_entries set user_id = p_target_user_id where user_id = auth.uid();
end;
$$ language plpgsql security definer;
