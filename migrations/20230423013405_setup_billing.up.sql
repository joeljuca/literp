create table sales_bills (
  id         integer primary key,
  created_at text not null,
  updated_at text,
  is_active  integer not null default 1,
  client_id  integer not null,
  session_id integer not null,
  price      integer not null,
  -- status (canceled: 0, completed: 1, pending: 2)
  status     integer not null default 2,

  -- json
  meta text,

  foreign key (client_id)  references sales_clients (id),
  foreign key (session_id) references sales_sessions (id),

  check(is_active in (0, 1)),
  check(price >= 0),
  check(status in (0, 1, 2)),
  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_payment_methods (
  id         integer primary key,
  created_at text not null,
  is_active  integer not null default 1,
  client_id  integer not null,
  -- type (credit_card: 1, debit_card: 2)
  type       integer not null default 1,

  -- json
  details text not null,
  meta    text,

  foreign key (client_id) references sales_clients (id),

  check(is_active in (0, 1)),
  check(type in (1, 2)),
  check(json_valid(details) and json_type(details) = "object")
  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_payments (
  id                integer primary key,
  created_at        text not null,
  updated_at        text,
  bill_id           integer not null,
  -- type (cash: 1, bank_transfer: 2, payment_method: 3)
  type              integer not null,
  payment_method_id integer,
  amount            integer not null,
  -- status (canceled: 0, completed: 1, processing: 2)
  status            integer not null default 1,

  -- json
  payment_proof text,
  meta          text,

  foreign key (bill_id)           references sales_bills (id),
  foreign key (payment_method_id) references sales_payment_methods (id),

  check(type in (1, 2, 3)),
  check(type in (1, 2) or payment_method_id is not null),
  check(amount >= 0),
  check(status in (0, 1, 2)),
  check(json_valid(meta) and json_type(meta) = "object")
);

--

create table sales_payment_proofs (
  id         integer primary key,
  created_at text not null,
  payment_id integer not null,
  file_id    integer not null,

  -- json
  meta text,

  foreign key (payment_id) references payments (id),
  foreign key (file_id)    references files (id),

  check(json_valid(meta) and json_type(meta) = "object")
);

create unique index idx_payprf_file on sales_payment_proofs (file_id);

create index idx_payprf_payment on sales_payment_proofs (payment_id);
