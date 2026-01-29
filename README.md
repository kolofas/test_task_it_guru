# Test Task — Backend (Python / FastAPI / PostgreSQL)

## Описание

В рамках тестового задания реализованы:

1. **Даталогическая схема данных** (PostgreSQL, реляционная модель):
   - номенклатура товаров
   - дерево категорий с неограниченным уровнем вложенности
   - клиенты
   - заказы покупателей
   - позиции заказов (many-to-many)

2. **SQL-запросы (пункт 2 задания)**:
   - сумма заказанных товаров по каждому клиенту
   - количество дочерних категорий первого уровня
   - отчёт *«Топ-5 самых покупаемых товаров за последний месяц»* (VIEW)
   - предложения по оптимизации структуры данных

3. **REST API сервис (пункт 3 задания)**:
   - добавление товара в заказ
   - увеличение количества товара, если позиция уже существует
   - проверка остатка товара на складе
   - корректное уменьшение остатка при добавлении в заказ

---

## Технологии
- Python 3.12
- FastAPI
- SQLAlchemy 2.x (async)
- PostgreSQL 16
- Alembic
- Docker / Docker Compose

## Запуск проекта локально

### 1. Клонировать репозиторий

```bash
git clone <repository_url>
cd test_task
```

### 2. Создать .env файл
```dotenv
POSTGRES_DB=test_task
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
```

### 3. Запустить PostgreSQL в Docker

```bash
docker compose up -d
```

### 4. Установить зависимости
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 5. Применить миграции
```bash
alembic upgrade head
```

### 6. Запустить сервис
```bash
make dev
```

## SQL-запросы (пункт 2)
Все SQl-запросы находятся в файле
```dotenv
sql/queries.sql
```

### Для выполнения
```bash
docker exec -i test_task-db-1 psql -U postgres -d test_task < sql/queries.sql
```
