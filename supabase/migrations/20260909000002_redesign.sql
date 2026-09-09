-- Redesign migration: hierarchy, tracking types, user preferences

-- 1. Activities: add parent_id for hierarchy
alter table public.activities
  add column parent_id uuid references public.activities(id) on delete cascade;

create index idx_activities_parent_id on public.activities(parent_id);

-- 2. Activities: add tracking_type
alter table public.activities
  add column tracking_type text not null default 'time'
  check (tracking_type in ('time', 'count'));

-- 3. Time entries: add universal value column
alter table public.time_entries
  add column value numeric not null default 0;

-- Backfill value from duration_minutes
update public.time_entries set value = duration_minutes;

-- Make duration_minutes nullable, drop old CHECK
alter table public.time_entries
  alter column duration_minutes drop not null;

alter table public.time_entries
  drop constraint time_entries_duration_minutes_check;

-- Add CHECK on value
alter table public.time_entries
  add constraint time_entries_value_check check (value > 0);

-- 4. User preferences table
create table public.user_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  theme text not null default 'system',
  locale text not null default 'system',
  view_mode text not null default 'list',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_preferences_user_id_unique unique (user_id)
);

create trigger user_preferences_updated_at
  before update on public.user_preferences
  for each row execute function public.set_updated_at();

-- RLS for user_preferences
alter table public.user_preferences enable row level security;

create policy "Users can select own preferences"
  on public.user_preferences for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own preferences"
  on public.user_preferences for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update own preferences"
  on public.user_preferences for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own preferences"
  on public.user_preferences for delete
  to authenticated
  using (auth.uid() = user_id);

-- 5. RPC: get subtree total (recursive CTE)
create or replace function public.get_activity_subtree_total(
  p_activity_id uuid,
  p_from date,
  p_to date
)
returns table(time_total numeric, count_total numeric) as $$
begin
  return query
  with recursive subtree as (
    select id, tracking_type from public.activities
    where id = p_activity_id and user_id = auth.uid()
    union all
    select a.id, a.tracking_type from public.activities a
    inner join subtree s on a.parent_id = s.id
  )
  select
    coalesce(sum(case when s.tracking_type = 'time' then te.value else 0 end), 0) as time_total,
    coalesce(sum(case when s.tracking_type = 'count' then te.value else 0 end), 0) as count_total
  from subtree s
  left join public.time_entries te
    on te.activity_id = s.id
    and te.date >= p_from
    and te.date <= p_to;
end;
$$ language plpgsql security definer;

-- 6. RPC: get activity children
create or replace function public.get_activity_children(p_parent_id uuid)
returns setof public.activities as $$
begin
  return query
  select * from public.activities
  where parent_id = p_parent_id
    and user_id = auth.uid()
    and archived = false
  order by position, created_at;
end;
$$ language plpgsql security definer;
