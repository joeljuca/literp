create table organizations (
  id         integer primary key,
  created_at text not null,
  updated_at text,
  is_active  integer not null default 1,
  name       text not null,

  -- json
  meta text,

  check(is_active in (0, 1)),
  check(json_valid(meta) and json_type(meta) = "object")
);

create index idx_orgs_created on organizations (created_at);
create index idx_orgs_name    on organizations (is_active, name collate nocase);

--

create table mtm_organizations_users (
  org_id     integer not null,
  user_id    integer not null,
  created_at text not null,

  -- json
  meta text,

  primary key (org_id, user_id),
  foreign key (org_id)  references organizations (id),
  foreign key (user_id) references users (id),

  check(json_valid(meta) and json_type(meta) = "object")
);