-- Move tracking type from activity to entry level
-- Any activity can have both time and count entries

-- 1. Add entry_type to time_entries
alter table public.time_entries
  add column entry_type text not null default 'time'
  check (entry_type in ('time', 'count'));

-- 2. Drop tracking_type from activities (no longer needed)
alter table public.activities
  drop column tracking_type;

-- 3. Update subtree RPC to use entry_type instead of activity tracking_type
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
    coalesce(sum(case when te.entry_type = 'time' then te.value else 0 end), 0) as time_total,
    coalesce(sum(case when te.entry_type = 'count' then te.value else 0 end), 0) as count_total
  from subtree s
  left join public.time_entries te
    on te.activity_id = s.id
    and te.date >= p_from
    and te.date <= p_to;
end;
$$ language plpgsql security definer;
