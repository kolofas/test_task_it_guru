-- ============================================================
-- 2.1 Сумма товаров, заказанных под каждого клиента
-- (client_name, total_amount)
-- ============================================================
SELECT
  c.name AS customer_name,
  COALESCE(SUM(oi.qty * p.price), 0) AS total_amount
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
LEFT JOIN order_items oi ON oi.order_id = o.id
LEFT JOIN products p ON p.id = oi.product_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;


-- ============================================================
-- 2.2 Количество дочерних элементов первого уровня вложенности
-- для категорий (прямые дети)
-- ============================================================
SELECT
  parent.id,
  parent.name,
  COUNT(child.id) AS children_count
FROM categories parent
LEFT JOIN categories child ON child.parent_id = parent.id
GROUP BY parent.id, parent.name
ORDER BY parent.id;


-- ============================================================
-- 2.3.1 VIEW: Топ-5 самых покупаемых товаров за последний месяц
-- (по количеству штук в заказах)
-- В отчете: Наименование товара, Категория 1-го уровня, Общее количество
-- ============================================================
CREATE OR REPLACE VIEW top5_products_last_month AS
WITH RECURSIVE cat_tree AS (
  -- корневые категории = 1-й уровень
  SELECT
    c.id AS category_id,
    c.parent_id,
    c.name AS category_name,
    c.id AS root_id,
    c.name AS root_name
  FROM categories c
  WHERE c.parent_id IS NULL

  UNION ALL

  SELECT
    c.id AS category_id,
    c.parent_id,
    c.name AS category_name,
    ct.root_id,
    ct.root_name
  FROM categories c
  JOIN cat_tree ct ON c.parent_id = ct.category_id
),
sales_last_month AS (
  SELECT
    oi.product_id,
    SUM(oi.qty) AS sold_qty
  FROM order_items oi
  JOIN orders o ON o.id = oi.order_id
  WHERE o.created_at >= (NOW() - INTERVAL '1 month')
  GROUP BY oi.product_id
)
SELECT
  p.name AS product_name,
  ct.root_name AS category_level1,
  slm.sold_qty AS total_sold_qty
FROM sales_last_month slm
JOIN products p ON p.id = slm.product_id
JOIN cat_tree ct ON ct.category_id = p.category_id
ORDER BY slm.sold_qty DESC, p.id
LIMIT 5;



-- 2.3.2 Оптимизация (идеи)
-- 1) Индексы (у нас уже есть created_at, customer_id, product_id, category_id):
--    - orders(created_at) критично для фильтра "последний месяц"
--    - order_items(product_id) критично для агрегации продаж по товару
--    - products(category_id) для присоединения категории
--
-- 2) Убрать рекурсивный CTE из горячего запроса:
--    Вариант А: денормализовать в products поле root_category_id (категория 1-го уровня)
--    и поддерживать его при изменении category_id / дерева.
--    Тогда VIEW не будет строить cat_tree каждый раз.
--
-- 3) Предагрегация:
--    Таблица-агрегат (product_sales_daily):
--    (day, product_id, sold_qty) с ежедневным пересчетом.
--    Топ-5 за месяц = sum за 30 дней по этой таблице.
--
-- 4) Materialized view:
--    если отчёт читают часто, а обновлять можно раз в N минут/час.
--
-- 5) Партиционирование orders по created_at (месяц/день),
--    если реально "тысячи заказов в день" и исторические данные копятся годами.
