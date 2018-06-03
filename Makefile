.PHONY: all
all: build-deps build-test

ALL_PACKAGES= $(shell go list ./...)
UNIT_TEST_PACKAGES= $(shell go list ./...)

DB_NAME= "todo_dev"
DB_PORT= 5432

TEST_DB_NAME= "todo_test"
TEST_DB_PORT= 5432

APP_EXECUTABLE= "out/todo"

setup: 
	go get -u github.com/golang/dep/cmd/dep

build: build-deps fmt vet compile

build-deps: 
	dep ensure

fmt: 
	go fmt ./...

vet: 
	go vet ./...

compile:
	mkdir -p out
	go build -o $(APP_EXECUTABLE)

db.setup: db.drop db.create db.migrate

db.drop:
	dropdb -p $(DB_PORT) --if-exists -Upostgres $(DB_NAME)

db.create:
	createdb -p $(DB_PORT) -Opostgres -Eutf8 $(DB_NAME)

db.migrate:
	$(DB_NAME) migrate

db.rollback:
	$(APP_EXECUTABLE) rollback

test: testdb.setup
	ENVIRONMENT=test go test $(UNIT_TEST_PACKAGES)

testdb.setup: testdb.drop testdb.create testdb.migrate

testdb.drop:
	dropdb -p $(TEST_DB_PORT) --if-exists -Upostgres $(TEST_DB_NAME)

testdb.create:
	createdb -p $(TEST_DB_PORT) -Opostgres -Eutf8 $(TEST_DB_NAME)

testdb.migrate:
	ENVIRONMENT=test $(APP_EXECUTABLE) migrate

testdb.rollback:
	ENVIRONMENT=test $(APP_EXECUTABLE) rollback