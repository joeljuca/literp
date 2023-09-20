.PHONY: db.create db.drop db.reset db.create_migration db.up db.down

# this is a comment

db.create:
	sqlite3 database.sqlite 'select 1'

db.drop:
	rm database.sqlite

db.reset:
	make db.drop
	make db.create
	make db.up

db.create_migration:
	migrate create -ext sql -dir migrations "$(name)"

db.up:
	migrate -source "file://migrations" -database "sqlite://database.sqlite" up

db.down:
	migrate -source "file://migrations" -database "sqlite://database.sqlite" down
