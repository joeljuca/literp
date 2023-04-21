create table files (
  id integer primary key,
  created_at text not null,
  updated_at text not null,
  deleted_at text,
  account_id integer not null,

  name text not null,
  size integer not null default 0,
  mime text,
  url text,

  meta text,

  foreign key (account_id) references accounts (id),
  check(json_type(meta) = "object")
);

create index idx_files_created on files (created_at);
create index idx_files_updated on files (updated_at);
create index idx_files_deleted on files (deleted_at) where deleted_at IS NOT NULL;
create index idx_files_account on files (account_id, mime, created_at);
create index idx_files_size on files (size);
