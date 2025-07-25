.PHONY: start setup

start:
	@iex -S mix phx.server

setup:
	docker 	run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres

init:
	@docker start postgres
