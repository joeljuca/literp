create table users (
  id         integer primary key,
  is_active  integer not null default 1,
  created_at text not null,
  updated_at text,
  email      text not null,
  name       text not null,
  phone      text,
  profile_id integer,

  -- json
  meta text,

  foreign key (profile_id) references profiles (id),

  check(is_active in (0, 1)),
  check(json_valid(meta) and json_type(meta) = "object")
);

create unique index idx_uniq_users_email on users (email collate nocase);
create unique index idx_uniq_users_phone on users (phone);

create index        idx_users_created    on users (created_at);
create index        idx_users_name       on users (name  collate nocase);

--

create profiles (
  id         integer primary key,
  created_at text not null,
  updated_at text,
  name       text not null,

  -- json
  profile text,
  meta    text,

  check(json_valid(profile) and json_type(profile) = "object"),
  check(json_valid(meta)    and json_type(meta)    = "object")
);

create index idx_profiles_created on profiles (created_at);
create index idx_profiles_updated on profiles (updated_at);
