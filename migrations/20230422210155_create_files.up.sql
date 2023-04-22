create table files (
  id         integer primary key,
  org_id     integer not null,
  created_at text not null,
  deleted_at text,
  user_id    integer not null,
  name       text not null,
  size       integer not null default 0,
  mime       text,
  url        text not null,

  -- json
  meta text,

  foreign key (org_id)  references organizations (id),
  foreign key (user_id) references users (id),

  check(size >= 0),
  check(json_valid(meta) and json_type(meta) = "object")
) strict;

create index idx_files_org     on files (org_id, user_id);
create index idx_files_created on files (created_at);
create index idx_files_deleted on files (deleted_at) where deleted_at IS NOT NULL;
create index idx_files_size    on files (size);