-- From Moodle
CREATE TABLE orders
	(orderId INT,
	date DATE,
	customerId INT,
	customerName VARCHAR(15),
	city VARCHAR(15),
	itemId INT,
	itemName VARCHAR(15),
	quantity INT,
	price REAL,
	PRIMARY KEY (orderId, customerId, itemId)
	);

INSERT INTO orders VALUES ('2301', '2011-02-23', '101', 'Martin', 'Prague', '3786', 'Net', '3', '35.00');
INSERT INTO orders VALUES ('2301', '2011-02-23', '101', 'Martin', 'Prague', '4011', 'Racket', '6', '65.00');
INSERT INTO orders VALUES ('2301', '2011-02-23', '101', 'Martin', 'Prague', '9132', 'Pack-3', '8', '4.75');
INSERT INTO orders VALUES ('2302', '2012-02-25', '107', 'Herman', 'Madrid', '5794', 'Pack-6', '4', '5.00');
INSERT INTO orders VALUES ('2303', '2011-11-27', '110', 'Pedro', 'Moscow', '4011', 'Racket', '2', '65.00');
INSERT INTO orders VALUES ('2303', '2011-11-27', '110', 'Pedro', 'Moscow', '3141', 'Cover', '2', '10.00');

-- Normalized form
CREATE TABLE customer (
    customerId INT PRIMARY KEY,
	customerName VARCHAR(15),
	city VARCHAR(15)
);

CREATE TABLE "order" (
    orderId INT PRIMARY KEY,
	date DATE,
	customerId INT,
	FOREIGN KEY (customerId) REFERENCES customer (customerId)
);

CREATE TABLE item (
    itemId INT PRIMARY KEY,
	itemName VARCHAR(15),
	price REAL
);

CREATE TABLE order_item (
    orderId INT,
    itemId INT,
    quantity INT,
    PRIMARY KEY (orderId, itemId),
    FOREIGN KEY (orderId) REFERENCES "order" (orderId),
    FOREIGN KEY (itemId) REFERENCES item (itemId)
);

-- Copy data
INSERT INTO customer (customerId, customerName, city)
SELECT DISTINCT customerId, customerName, city FROM orders;

INSERT INTO "order" (orderId, date, customerId)
SELECT DISTINCT orderId, date, customerId FROM orders;

INSERT INTO item (itemId, itemName, price)
SELECT DISTINCT itemId, itemName, price FROM orders;

INSERT INTO order_item (orderId, itemId, quantity)
SELECT orderId, itemId, quantity FROM orders;

-- Drop old table
DROP TABLE orders;

-- Queries
-- 1. Cheapest order
SELECT sum(quantity * i.price) as total_price FROM order_item oi
JOIN item i on i.itemId = oi.itemId
GROUP BY oi.orderId
ORDER BY total_price
LIMIT 1;

-- 2. Customer with the most ordered items
SELECT customerName, city, sum(quantity) as total_quantity FROM customer
LEFT OUTER JOIN "order" o on customer.customerId = o.customerId
LEFT OUTER JOIN order_item oi on o.orderId = oi.orderId
GROUP BY customerName, city
ORDER BY total_quantity DESC
LIMIT 1;

