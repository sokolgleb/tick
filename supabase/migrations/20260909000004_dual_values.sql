-- Each entry can have both time (value) and count (count_value)

-- 1. Add count_value column
alter table public.time_entries
  add column count_value numeric not null default 0;

-- 2. Drop entry_type (no longer needed)
alter table public.time_entries
  drop column entry_type;

-- 3. Update CHECK: at least one must be > 0
alter table public.time_entries
  drop constraint time_entries_value_check;

alter table public.time_entries
  add constraint time_entries_value_check
  check (value > 0 or count_value > 0);

-- 4. Update subtree RPC
create or replace function public.get_activity_subtree_total(
  p_activity_id uuid,
  p_from date,
  p_to date
)
returns table(time_total numeric, count_total numeric) as $$
begin
  return query
  with recursive subtree as (
    select id from public.activities
    where id = p_activity_id and user_id = auth.uid()
    union all
    select a.id from public.activities a
    inner join subtree s on a.parent_id = s.id
  )
  select
    coalesce(sum(te.value), 0) as time_total,
    coalesce(sum(te.count_value), 0) as count_total
  from subtree s
  left join public.time_entries te
    on te.activity_id = s.id
    and te.date >= p_from
    and te.date <= p_to;
end;
$$ language plpgsql security definer;
