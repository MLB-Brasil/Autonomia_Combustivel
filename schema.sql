-- Execute no SQL Editor do Supabase (uma vez).

create table if not exists public.fuel_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nome_veiculo text not null,
  capacidade_tanque numeric(6,2) not null check (capacidade_tanque > 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.fuel_refuels (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  data date not null,
  combustivel text not null check (combustivel in ('Gasolina', 'Etanol', 'Diesel')),
  valor_total numeric(10,2) not null check (valor_total > 0),
  preco_litro numeric(6,3) not null check (preco_litro > 0),
  litros numeric(8,3) not null check (litros > 0),
  odometro integer not null check (odometro >= 0),
  created_at timestamptz not null default now()
);

create index if not exists fuel_refuels_user_odo on public.fuel_refuels (user_id, odometro);

alter table public.fuel_profiles enable row level security;
alter table public.fuel_refuels enable row level security;

drop policy if exists "fuel_profiles_own" on public.fuel_profiles;
create policy "fuel_profiles_own" on public.fuel_profiles
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "fuel_refuels_own" on public.fuel_refuels;
create policy "fuel_refuels_own" on public.fuel_refuels
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
