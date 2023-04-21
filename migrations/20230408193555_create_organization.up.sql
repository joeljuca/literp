create table organizations (
  id integer primary key,
  created_at text not null,
  updated_at text not null,

  is_active integer not null default 1,
  title text not null,

  attributes text
);

create index idx_org_title on organizations (is_active, title);

create table organizations_accounts (
  organization_id integer not null,
  account_id integer not null,
  attributes text
);

create unique index idx_uniq_org_acc on organizations_accounts (organization_id, account_id);
