-- ============================================================
-- PÓRTICO — Segurança da lista de apps (versão 2)
--
-- O que muda: a tabela portico_estado deixa de ser aberta a
-- qualquer pessoa. Só o login do Bispo (função eh_dono, criada
-- pelo script das Despesas) lê e grava a lista.
--
-- Cole no SQL Editor do Supabase e clique em RUN. Pode rodar de novo.
-- A lista atual de apps é mantida.
-- ============================================================
create table if not exists public.portico_estado (
  id text primary key,
  dados jsonb not null,
  carimbo bigint not null default 0
);

alter table public.portico_estado enable row level security;

do $$
declare p record;
begin
  for p in select policyname from pg_policies
           where schemaname = 'public' and tablename = 'portico_estado'
  loop
    execute format('drop policy %I on public.portico_estado', p.policyname);
  end loop;
end $$;

revoke all on public.portico_estado from anon, authenticated;
grant select, insert, update, delete on public.portico_estado to authenticated;

create policy "portico_dono" on public.portico_estado
  for all to authenticated
  using (public.eh_dono()) with check (public.eh_dono());

-- Conferência: deve mostrar a linha "principal" com a sua lista
select id, jsonb_array_length(dados->'apps') as apps, carimbo from public.portico_estado;
