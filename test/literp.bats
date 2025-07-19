#!/usr/bin/env bats

dbname="database.sqlite"

# Utils

function datetime_iso8601 {
  TZ=UTC date "+%Y-%m-%dT%H:%M:%SZ"
}

function random_md5 {
  head /dev/random | md5
}

# Fake builders

function fake_created_at {
  datetime_iso8601
}

function fake_email {
  echo "u-$(random_md5 | cut -c 1-12)@localhost"
}

function fake_name {
  echo "John $(random_md5 | cut -c 1-8) Smith"
}

# Tests

function setup {
  make db.drop >/dev/null 2>&1
  make db.create
  make db.up
}

@test "SQLite is available" {
  which sqlite3 >/dev/null 2>&1
}

@test "database.sqlite exists" {
  ls $dbname >/dev/null 2>&1
}

@test "table users exists" {
  sqlite3 "$dbname" "select 1 from users"
}

@test "[users] required fields: created_at, email, name" {
  local q

  q="INSERT INTO users (email, name) VALUES ('$(fake_email)', '$(fake_name)')"
  run sqlite3 $dbname "$q"

  [[ "$status" != "0" ]]
  [[ "$output" == *"created_at"* ]]

  q="INSERT INTO users (created_at, name) VALUES ('$(fake_created_at)', '$(fake_name)')"
  run sqlite3 $dbname "$q"

  [[ "$status" != "0" ]]
  [[ "$output" == *"email"* ]]

  q="INSERT INTO users (created_at, email) VALUES ('$(fake_created_at)', '$(fake_email)')"
  run sqlite3 $dbname "$q"

  [[ "$status" != "0" ]]
  [[ "$output" == *"name"* ]]

  q="INSERT INTO users (created_at, email, name) VALUES ('$(fake_created_at)', '$(fake_email)', '$(fake_name)')"
  run sqlite3 $dbname "$q"

  [[  "$status" -eq "0" ]]
}

@test "[users] is_active is o or 1" {
  local q

  for i in $(seq 2 10); do
    q="INSERT INTO users (is_active, created_at, email, name)"
    q="$q VALUES ($i, '$(fake_created_at)', '$(fake_email)', '$(fake_name)')"
    run sqlite3 $dbname "$q"

    [[  "$status" != "0" ]]
  done

  for i in 0 1; do
    q="INSERT INTO users (is_active, created_at, email, name)"
    q="$q VALUES ($i, '$(fake_created_at)', '$(fake_email)', '$(fake_name)')"
    run sqlite3 $dbname "$q"

    [[  "$status" -eq "0" ]]
  done
}

@test "[users] profile_id must be a valid profile" {
  local q

  q="INSERT INTO profiles (created_at, name)"
  q="$q VALUES ($i, '$(fake_created_at)', '$(fake_name)')"
  run sqlite3 $dbname "$q"

  q="INSERT INTO users (created_at, email, name, profile_id)"
  q="$q VALUES ('$(fake_created_at)', '$(fake_email)', '$(fake_name)', 123)"
  run sqlite3 $dbname "$q"

  [[  "$status" != "0" ]]
  [[  "$output" == *"profile_id"* ]]

  # q="INSERT INTO users (created_at, email, name, profile_id)"
  # q="$q VALUES (1, '$(fake_created_at)', '$(fake_email)', '$(fake_name)', 1)"
  # run sqlite3 $dbname "$q"

  # [[  "$status" == "0" ]]
}
