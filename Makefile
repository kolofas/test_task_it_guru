.PHONY: run dev down db logs

run:
	uvicorn app.main:app --host 0.0.0.0 --port 8000

dev:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

up:
	docker compose up -d

down:
	docker compose down

db:
	docker compose up -d db

logs:
	docker compose logs -f
