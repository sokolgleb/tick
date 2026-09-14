-- RPC: delete user account (non-anonymous only)
create or replace function public.delete_user_account()
returns void as $$
declare
  v_is_anonymous boolean;
  v_uid uuid;
begin
  v_uid := auth.uid();

  v_is_anonymous := coalesce(
    (current_setting('request.jwt.claims', true)::jsonb ->> 'is_anonymous')::boolean,
    false
  );

  if v_is_anonymous then
    raise exception 'Anonymous users cannot delete their account';
  end if;

  delete from public.time_entries where user_id = v_uid;
  delete from public.activities where user_id = v_uid;
  delete from auth.users where id = v_uid;
end;
$$ language plpgsql security definer;
