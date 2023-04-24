-- domain: sales

create table sales_clients (
  id         integer primary key,
  org_id     integer not null,
  created_at text not null,
  updated_at text,
  user_id    integer,
  name       text not null,
  email      text not null,
  phone      text,


  -- json
  profile text,
  meta   text,

  foreign key (org_id)  references organizations (id),
  foreign key (user_id) references users (id),

  check(json_valid(profile) and json_type(profile) = "object"),
  check(json_valid(meta)   and json_type(meta)   = "object")
);

create unique index idx_uniq_clients_email on sales_clients (email collate nocase);

create index idx_clients_created on sales_clients (created_at);
create index idx_clients_updated on sales_clients (updated_at);
create index idx_clients_name    on sales_clients (name collate nocase);
create index idx_clients_phone   on sales_clients (phone);

--

create table sales_services (
  id          integer primary key,
  org_id     integer not null,
  is_active   integer not null default 1,
  created_at  text not null,
  updated_at  text,
  title       text not null,
  price       integer not null default 0,
  description text,

  -- json
  meta text,

  foreign key (org_id) references organizations (id),

  check(is_active in (0, 1)),
  check(price >= 0),
  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_products (
  id          integer primary key,
  org_id     integer not null,
  is_active   integer not null default 1,
  created_at  text not null,
  updated_at  text,
  title       text not null,
  price       integer not null default 0,
  description text,

  -- json
  meta text,

  foreign key (org_id) references organizations (id),

  check(is_active in (0, 1)),
  check(price >= 0),
  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_bundles (
  id          integer primary key,
  org_id      integer not null,
  is_active   integer not null default 1,
  created_at  text not null,
  updated_at  text,
  title       text not null,
  price       integer not null default 0,
  description text,

  -- json
  meta text,

  foreign key (org_id) references organizations (id),

  check(is_active in (0, 1)),
  check(price >= 0),
  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_bundle_items (
  id integer primary key,
  created_at text not null,
  updated_at text,
  bundle_id  integer not null,
  -- type int (product: 1, service: 2)
  type       integer not null,
  product_id integer,
  service_id integer,
  quantity   integer not null default 1,

  meta text,

  foreign key (bundle_id)  references sales_bundles (id),
  foreign key (product_id) references sales_products (id),
  foreign key (service_id) references sales_services (id),

  check(type in (1, 2)),
  check(
    (type = 1 and product_id IS NOT NULL) -- if product, requires product_id
    or
    (type = 2 and service_id IS NOT NULL) -- if service, requires service_id
  ),
  check(quantity >= 1),
  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_categories (
  id         integer primary key,
  org_id     integer not null,
  is_active  integer not null default 1,
  created_at text not null,
  updated_at text,
  parent_id  integer,
  title      text not null,

  -- json
  meta text,

  foreign key (org_id)    references organizations (id),
  foreign key (parent_id) references sales_categories (id),

  check(is_active in (0, 1)),
  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_mtm_categories_products (
  category_id integer not null,
  product_id  integer not null,
  created_at  text not null,

  -- json
  meta text,

  primary key (category_id, product_id),
  foreign key (category_id) references sales_categories(id),
  foreign key (product_id)  references sales_products(id),

  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_mtm_categories_services (
  category_id integer not null,
  service_id  integer not null,
  created_at  text not null,

  -- json
  meta text,

  primary key (category_id, service_id),
  foreign key (category_id) references sales_categories(id),
  foreign key (service_id)  references sales_services(id),

  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_sessions (
  id           integer primary key,
  org_id       integer not null,
  created_at   text not null,
  updated_at   text,
  user_id      integer not null,
  client_id    integer not null,
  attendant_id integer,
  -- status (canceled: 0, open: 1, closed: 2)
  status       integer not null default 1,
  notes        text,

  -- json
  meta text,

  foreign key (org_id)       references organizations (id),
  foreign key (user_id)      references users (id),
  foreign key (client_id)    references sales_clients (id),
  foreign key (attendant_id) references users (id),

  check(status in (0, 1, 2)),
  check(json_valid(meta) and json_type(meta) = "object")
);

create unique index idx_uniq_sess_org_client on sales_sessions (org_id, client_id)
  where status in (1);

create index idx_sess_created   on sales_sessions (created_at);
create index idx_sess_user      on sales_sessions (user_id);
create index idx_sess_attendant on sales_sessions (attendant_id);

--

create table sales_orders (
  id         integer primary key,
  created_at text not null,
  updated_at text,
  session_id integer not null,
  -- status (canceled: 0, completed: 1, estimate: 2, ordering: 3, ordered: 4, ongoing: 5, ready: 6)
  status     integer not null default 2,
  notes      text,

  -- json
  meta text,

  foreign key (session_id) references sales_sessions (id),
  
  check(status in (0, 1, 2, 3, 4, 5, 6)),
  check(json_valid(meta) and json_type(meta) = "object")
);

create index idx_orders_created on sales_orders (created_at);
create index idx_orders_status  on sales_orders (status);

--

create table sales_order_items (
  id         integer primary key,
  created_at text not null,
  updated_at text,
  order_id   integer not null,
  -- type int (product: 1, service: 2, bundle: 3)
  type       integer not null,
  product_id integer,
  service_id integer,
  bundle_id  integer,
  quantity   integer not null default 1,
  price      integer,
  notes      text,

  -- json
  meta text,

  foreign key (order_id)   references sales_orders (id),
  foreign key (product_id) references sales_products (id),
  foreign key (service_id) references sales_services (id),
  foreign key (bundle_id)  references sales_bundles (id),

  check(type in (1, 2, 3)),
  check(quantity >= 1),
  check(price >= 0),
  -- type constraint
  check(
    (type = 1 and product_id IS NOT NULL) -- if product, requires product_id
    or
    (type = 2 and service_id IS NOT NULL) -- if service, requires service_id
    or
    (type = 3 and bundle_id IS NOT NULL) -- if bundle, requires bundle_id
  ),
  check(json_valid(meta) and json_type(meta) = "object")
);

create index idx_order_items_order_type on sales_order_items (order_id, type);