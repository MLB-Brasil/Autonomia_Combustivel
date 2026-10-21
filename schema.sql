-- Schema completo (instalação do zero). Execute no SQL Editor do Supabase.

create table if not exists public.fuel_vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nome_veiculo text not null,
  capacidade_tanque numeric(6,2) not null check (capacidade_tanque > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.fuel_refuels (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  vehicle_id uuid references public.fuel_vehicles(id) on delete cascade,
  data date not null,
  combustivel text not null check (combustivel in ('Gasolina Comum', 'Gasolina Aditivada', 'Etanol', 'Diesel')),
  valor_total numeric(10,2) not null check (valor_total > 0),
  preco_litro numeric(6,3) check (preco_litro is null or preco_litro > 0),
  litros numeric(8,3) check (litros is null or litros > 0),
  odometro integer not null check (odometro >= 0),
  created_at timestamptz not null default now()
);

create index if not exists fuel_refuels_vehicle_odo on public.fuel_refuels (vehicle_id, odometro);

alter table public.fuel_vehicles enable row level security;
alter table public.fuel_refuels enable row level security;

drop policy if exists "fuel_vehicles_own" on public.fuel_vehicles;
create policy "fuel_vehicles_own" on public.fuel_vehicles
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "fuel_refuels_own" on public.fuel_refuels;
create policy "fuel_refuels_own" on public.fuel_refuels
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Migração para bancos criados na versão de veículo único (rode uma vez, nesta ordem):
-- create table if not exists public.fuel_vehicles (...);             -- ver definição acima
-- alter table public.fuel_vehicles enable row level security;
-- insert into public.fuel_vehicles (user_id, nome_veiculo, capacidade_tanque)
--   select p.user_id, p.nome_veiculo, p.capacidade_tanque from public.fuel_profiles p
--   where not exists (select 1 from public.fuel_vehicles v where v.user_id = p.user_id);
-- alter table public.fuel_refuels add column if not exists vehicle_id uuid references public.fuel_vehicles(id) on delete cascade;
-- update public.fuel_refuels r set vehicle_id = v.id from public.fuel_vehicles v
--   where v.user_id = r.user_id and r.vehicle_id is null;
-- create index if not exists fuel_refuels_vehicle_odo on public.fuel_refuels (vehicle_id, odometro);
