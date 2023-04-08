create table organizations (
  id int primary key,
  created_at text not null,
  updated_at text not null,

  is_active int not null default 1,
  title text not null,

  attributes text
) strict;

create index idx_org_title on organizations (is_active, title);

create table organizations_accounts (
  organization_id int not null,
  account_id int not null,
  attributes text
) strict;

create unique index idx_uniq_org_acc on organizations_accounts (organization_id, account_id);
