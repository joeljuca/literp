create table accounts (
  id integer primary key,
  created_at text not null,
  updated_at text not null,

  is_active integer not null default 1,
  name text not null,
  email text not null,
  phone text,

  -- json
  profile text,
  attributes text
);

create index idx_acc_uniq_name on accounts (name);
create unique index idx_acc_uniq_email on accounts (email collate nocase);
create unique index idx_acc_uniq_phone on accounts (phone);
