CREATE SCHEMA online_store;

CREATE TABLE brands(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR (40) NOT NULL UNIQUE
);

CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR (40) NOT NULL UNIQUE
);

CREATE TABLE reviews(
id INT PRIMARY KEY AUTO_INCREMENT,
content TEXT,
rating DECIMAL (10,2) NOT NULL,
picture_url VARCHAR (80) NOT NULL,
published_at DATETIME NOT NULL
);

CREATE TABLE products (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR (40) NOT NULL,
price DECIMAL (19,2) NOT NULL,
quantity_in_stock INT,
description TEXT,
brand_id INT NOT NULL,
category_id INT NOT NULL,
review_id INT,
CONSTRAINT fk_product_brand FOREIGN KEY (brand_id) REFERENCES brands (id),
CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories (id),
CONSTRAINT fk_product_reviews FOREIGN KEY (review_id) REFERENCES reviews (id)
);

CREATE TABLE customers (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (20) NOT NULL,
last_name VARCHAR (20) NOT NULL,
phone VARCHAR (30) NOT NULL UNIQUE,
address VARCHAR (60) NOT NULL,
discount_card BIT (1) NOT NULL DEFAULT 0
);

CREATE TABLE orders (
id INT PRIMARY KEY AUTO_INCREMENT,
order_datetime DATETIME NOT NULL,
customer_id INT NOT NULL,
CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers (id)
);

CREATE TABLE orders_products (
order_id INT,
product_id INT,
CONSTRAINT fk_maping_orders FOREIGN KEY (order_id) REFERENCES orders (id),
CONSTRAINT fk_maping_products FOREIGN KEY (product_id) REFERENCES products (id)
);

INSERT INTO reviews(content,picture_url,published_at,rating)
(SELECT substring(description,1,15),reverse(name),'20101010',price/8
FROM products
WHERE id >=5);


UPDATE products
SET quantity_in_stock = quantity_in_stock - 5
WHERE quantity_in_stock >= 60 AND quantity_in_stock <= 70;

DELETE FROM customers  as c
WHERE id NOT IN (SELECT customer_id FROM orders);

SELECT id, name FROM categories
ORDER BY name DESC;

SELECT id, brand_id, name, quantity_in_stock FROM products
WHERE price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock ASC, id ASC;

SELECT id, content, rating, picture_url, published_at 
FROM reviews
WHERE content LIKE 'My%' AND
char_length(content) > 61
ORDER BY rating DESC;

SELECT concat_ws(' ', first_name, last_name) AS full_name, address, o.order_datetime AS order_date
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
WHERE year(o.order_datetime) <=2018
ORDER BY full_name DESC;

SELECT COUNT(p.id) AS items_count, c.name, SUM(p.quantity_in_stock) AS total_quantity
FROM products as p
JOIN  categories AS c ON c.id = p.category_id
GROUP BY c.name
ORDER BY items_count DESC, total_quantity ASC
LIMIT 5;

SELECT udf_customer_count ('Shirley');

SELECT c.first_name, c.last_name, COUNT(o.id)
FROM customers as c
JOIN orders as o ON o.customer_id = c.id
JOIN orders_products AS op ON op.order_id = o.id
WHERE c.first_name = 'Shirley';

SELECT  first_name, last_name, udf_customer_products_count ('Shirley') AS total_products
FROM customers 
WHERE first_name = 'Shirley';

CALL udp_reduce_price ('Phones and tablets');

SELECT p.price from products as p
JOIN reviews AS r ON r.id = p.review_id
JOIN categories AS c ON p.category_id = c.id
WHERE c.name = 'Phones and tablets'
AND 
r.rating < 4;
