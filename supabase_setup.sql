-- ============================================================
-- TMC Global Health 2026 — Supabase setup
-- Run this once in the Supabase Dashboard → SQL Editor.
-- Project: https://tabtlieieayvmvmzhiky.supabase.co
-- ============================================================

-- One row per company. The full company object (contact, notes,
-- activity, follow-ups, files) is stored as-is in the jsonb "data"
-- column, so the app's data model stays exactly the same.
create table if not exists public.tmc_companies (
  id         text primary key,
  position   integer not null default 0,          -- preserves list order
  data       jsonb not null,                      -- the complete company object
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Keep updated_at current on every change.
create or replace function public.tmc_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists tmc_companies_set_updated_at on public.tmc_companies;
create trigger tmc_companies_set_updated_at
  before update on public.tmc_companies
  for each row
  execute function public.tmc_set_updated_at();

-- ------------------------------------------------------------
-- Row Level Security
-- The app currently runs WITHOUT authentication, so the anon
-- (publishable) key needs full read/write access. When you add
-- authentication later, replace these policies with user-scoped
-- ones (e.g. using auth.uid()).
-- ------------------------------------------------------------
alter table public.tmc_companies enable row level security;

drop policy if exists "tmc_companies anon select" on public.tmc_companies;
create policy "tmc_companies anon select"
  on public.tmc_companies for select
  to anon, authenticated
  using (true);

drop policy if exists "tmc_companies anon insert" on public.tmc_companies;
create policy "tmc_companies anon insert"
  on public.tmc_companies for insert
  to anon, authenticated
  with check (true);

drop policy if exists "tmc_companies anon update" on public.tmc_companies;
create policy "tmc_companies anon update"
  on public.tmc_companies for update
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "tmc_companies anon delete" on public.tmc_companies;
create policy "tmc_companies anon delete"
  on public.tmc_companies for delete
  to anon, authenticated
  using (true);
