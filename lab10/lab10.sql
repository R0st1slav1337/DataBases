CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);
INSERT INTO accounts (name, balance)
VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);
INSERT INTO products (shop, product, price)
VALUES
    ('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);

--Task 1
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
COMMIT;
-- Balance of Alice decrease (900), Bob's increase (600).
-- Because we make money transfer, we must be sure that Bob will receive money from Alice.
-- Alice will send money, but Bob will not receive money because of the system crash.
select * from accounts;

--Task 2
BEGIN;
UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
-- Balance was 400.
-- Became 900 again, like it was before UPDATE.
-- In situations when money (or something else) were sent by mistake (by accident).

-- Task 3
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';
COMMIT;
-- Balance of Alice became 800, Bob's stays the same, Wally's became 850.
-- Before ROLLBACK Bob's balance was increased, but because SAVEPOINT was created before this UPDATE, Bob's balance was returned to initial amount.
-- We can correct mid-transaction mistakes without aborting the whole transaction (allows partial rollbacks within transaction).

--Task 4
--Scenario A
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

--Scenario B
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
-- Before we see products 'Coke' and 'Pepsi', after we see only product 'Fanta'.
-- No changes, Terminal 2 does not affect on Terminal 1, because Terminal 1 see snapshot of initial data, even if Terminal 2 make changes.
-- READ COMMITTED: Allows a transaction to see committed changes from other transactions immediately.
-- SERIALIZABLE: Provides full isolation, transaction sees a snapshot as of its start.

--Task 5
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 1 sees a snapshot of the data as of the start of its transaction, because of REPEATABLE READ isolation.
-- Phantom read occurs within a transaction, when two identical queries return different sets of rows
-- because another transaction inserted or deleted rows that satisfy the query’s WHERE clause between the two queries.
-- SERIALIZABLE isolation (but in this case REPEATABLE READ isolation prevents it too).

--Task 6
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
-- No because PostgreSQL does not allow dirty reads by READ UNCOMMITTED, but theoretically it should see 99.99.
-- Problematic is that Terminal 2 later performs a ROLLBACK, meaning the price 99.99 was never actually committed.
-- Dirty read occurs when a transaction reads changes made by another transaction that has not been committed.
-- Reading uncommitted data can lead to inconsistent or incorrect application behavior.

-- Exercise 2
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', '7Up', 2.00);

SAVEPOINT sp1;

UPDATE products SET price = 15.00
WHERE product = '7Up';

SAVEPOINT sp2;

DELETE FROM products
WHERE product = '7Up';

ROLLBACK TO SAVEPOINT sp1;
COMMIT;
--Final state
SELECT * FROM products ORDER BY id;
-- Price of '7Up' doen't change and it wasn't deleted 
-- because of savepoint#1 created instantly after creating product.