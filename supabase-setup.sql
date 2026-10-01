-- Einmalig im Supabase-Dashboard unter SQL Editor ausführen.
-- Ändere '7453' unten an BEIDEN Stellen, wenn du eine andere Boss-PIN willst.

create table if not exists public.boss_data (
  id int primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

insert into public.boss_data (id, data)
values (1, '{"ranking":["","","","","","","","","","","",""],"farm":[]}')
on conflict (id) do nothing;

-- Alle dürfen lesen, niemand darf direkt schreiben.
alter table public.boss_data enable row level security;
drop policy if exists "alle duerfen lesen" on public.boss_data;
create policy "alle duerfen lesen" on public.boss_data for select using (true);

-- Geschrieben wird nur über diese Funktion, und nur mit der richtigen PIN.
create or replace function public.save_boss_data(pin text, payload jsonb)
returns void language plpgsql security definer set search_path = public as $$
begin
  if pin is distinct from '7453' then
    raise exception 'falsche pin';
  end if;
  update public.boss_data set data = payload, updated_at = now() where id = 1;
end;
$$;

create or replace function public.check_boss_pin(pin text)
returns boolean language sql security definer set search_path = public as $$
  select pin = '7453';
$$;

grant execute on function public.save_boss_data(text, jsonb) to anon;
grant execute on function public.check_boss_pin(text) to anon;
