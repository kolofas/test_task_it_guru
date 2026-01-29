-- =========================
-- CLEAN (опционально)
-- =========================
TRUNCATE TABLE order_items RESTART IDENTITY CASCADE;
TRUNCATE TABLE orders RESTART IDENTITY CASCADE;
TRUNCATE TABLE products RESTART IDENTITY CASCADE;
TRUNCATE TABLE customers RESTART IDENTITY CASCADE;
TRUNCATE TABLE categories RESTART IDENTITY CASCADE;

-- =========================
-- CATEGORIES (дерево)
-- 1-й уровень: Electronics, Food
-- 2-й уровень: Phones, Laptops, Snacks
-- 3-й уровень: Android, iPhone
-- =========================
INSERT INTO categories (id, name, parent_id) VALUES
  (1, 'Electronics', NULL),
  (2, 'Food', NULL),
  (3, 'Phones', 1),
  (4, 'Laptops', 1),
  (5, 'Snacks', 2),
  (6, 'Android', 3),
  (7, 'iPhone', 3);

-- =========================
-- CUSTOMERS
-- =========================
INSERT INTO customers (id, name, address) VALUES
  (1, 'Acme LLC', 'Amsterdam, Damrak 1'),
  (2, 'Beta BV', 'Rotterdam, Coolsingel 10'),
  (3, 'Charlie GmbH', 'Berlin, Alexanderplatz 3');

-- =========================
-- PRODUCTS (qty, price, category)
-- =========================
INSERT INTO products (id, name, qty, price, category_id) VALUES
  (1, 'Pixel 9',        50, 799.00, 6),
  (2, 'Galaxy S25',     30, 899.00, 6),
  (3, 'iPhone 17',      20, 1199.00, 7),
  (4, 'MacBook Air 15', 15, 1599.00, 4),
  (5, 'ThinkPad X1',    10, 1799.00, 4),
  (6, 'Protein Bar',    200, 2.50,  5),
  (7, 'Chips',          150, 1.90,  5);

-- =========================
-- ORDERS
-- created_at: часть "последний месяц", часть "старше месяца"
-- =========================
INSERT INTO orders (id, customer_id, created_at) VALUES
  (1, 1, NOW() - INTERVAL '10 days'),
  (2, 1, NOW() - INTERVAL '20 days'),
  (3, 2, NOW() - INTERVAL '5 days'),
  (4, 2, NOW() - INTERVAL '40 days'),  -- старше месяца
  (5, 3, NOW() - INTERVAL '15 days');

-- =========================
-- ORDER ITEMS
-- =========================
INSERT INTO order_items (order_id, product_id, qty) VALUES
  -- Заказ 1 (Acme, 10 дней назад)
  (1, 1, 2),   -- Pixel 9 x2
  (1, 6, 20),  -- Protein Bar x20
  (1, 7, 10),  -- Chips x10

  -- Заказ 2 (Acme, 20 дней назад)
  (2, 2, 1),   -- Galaxy S25 x1
  (2, 6, 30),  -- Protein Bar x30
  (2, 7, 25),  -- Chips x25

  -- Заказ 3 (Beta, 5 дней назад)
  (3, 3, 1),   -- iPhone 17 x1
  (3, 6, 10),  -- Protein Bar x10

  -- Заказ 4 (Beta, 40 дней назад) - НЕ должен попасть в топ-5 "за последний месяц"
  (4, 4, 1),   -- MacBook Air 15 x1

  -- Заказ 5 (Charlie, 15 дней назад)
  (5, 1, 1),   -- Pixel 9 x1
  (5, 7, 40);  -- Chips x40
