-- Task 1.1
CREATE TABLE employee(
    employee_id integer,
    first_name text,
    last_name text,
    age integer check ( age between 18 and 65),
    salary numeric check ( salary > 0 )
);
-- Task 1.2
CREATE TABLE products_catalog(
    product_id integer,
    product_name text,
    regular_price numeric check ( regular_price > 0 ),
    discount_price numeric check ( discount_price > 0 ),
    constraint valid_discount check
        (discount_price < regular_price)
);
--Task 1.3
CREATE TABLE bookings(
    booking_id integer,
    check_in_date date,
    check_out_date date,
    num_guests integer check ( num_guests between 1 and 10),
    check ( check_out_date > check_in_date )
);

--Task 1.4
--Valid data
INSERT INTO employee
VALUES
(1,'Nika','Krivenko',19,180000),
(2,'Rostislav','Krivenko',20,1337);
INSERT INTO products_catalog
VALUES
(1,'TV',1299,1099),
(2,'Oven',599,499);
INSERT INTO bookings
VALUES
(1,'25-03-2025','27-03-2025',4),
(2,'14-04-2025','18-04-2025',2);
--Invalid data
INSERT INTO employee
VALUES (3,'Sanzhar','Tokishev',17,228);
INSERT INTO employee
VALUES (4,'Alisher','Aliev',20,-666);
INSERT INTO products_catalog
VALUES (3,'Console',299,0);
INSERT INTO products_catalog
VALUES (4,'Freezer',159,169);
INSERT INTO bookings
VALUES (3,'20-04-2025','19-04-2025',5);
INSERT INTO bookings
VALUES (4,'25-04-2025','29-04-2025',20);

--Task 2.1
CREATE TABLE customers(
    customer_id integer not null,
    email text not null,
    phone text null,
    registration_date date not null
);
--Task 2.2
CREATE TABLE inventory(
    item_id integer not null,
    item_name text not null,
    quantity integer not null check ( quantity >= 0 ),
    unit_price numeric not null check ( unit_price > 0 ),
    last_updated timestamp not null
);
--Task 2.3
--Valid data
INSERT INTO customers
VALUES
(1,'nikkka@mail.ru',null, '20-05-2024'),
(2,'rossstik@gmail.com','87772281337',current_date);
INSERT INTO inventory
VALUES
(1,'Pen',200,0.59,'14-03-2025 15:30:21'),
(2,'Notebook',150,1.25,'17-07-2025 16:00:00');
--Invalid data
INSERT INTO customers
VALUES (3,null,'87001236767','18-09-2024');

--Task 3.1
CREATE TABLE users(
    user_id integer,
    username text unique,
    email text unique,
    created_at timestamp
);
--Task 3.2
CREATE TABLE course_enrollments(
    enrollment_id integer,
    student_id integer,
    course_code text,
    semester text,
    constraint unique_record unique (student_id,course_code,semester)
);
--Task 3.3
ALTER TABLE users
DROP constraint users_username_key,
ADD constraint unique_username unique (username);

ALTER TABLE users
DROP constraint users_email_key,
ADD constraint unique_email unique (email);

--Valid data
INSERT INTO users
VALUES (1,'R0st1k','rastaman@mail.ru',current_timestamp);
--Invalid data (duplicate)
INSERT INTO users
VALUES (2,'R0st1k','balbes228@gmail.com','14-04-2004 15:00:00');
INSERT INTO users
VALUES (3,'Rostiks','rastaman@mail.ru','01-01-2001 01:00:00');

--Task 4.1
CREATE TABLE departments(
    dept_id integer primary key,
    dept_name text not null,
    location text
);
--Valid data
INSERT INTO departments
VALUES
(1,'IT','Building #1'),
(2,'Management','Building #3'),
(3,'Economics','Building #3');
--Invalid data
INSERT INTO departments
VALUES (1,'Management','Building #3');
INSERT INTO departments
VALUES (null,'IT','Building #1');

--Task 4.2
CREATE TABLE student_courses(
    student_id integer,
    course_id integer,
    enrollment_date date,
    grade text,
    primary key (student_id,course_id)
);
--Task 4.3
--In document

--Task 5.1
CREATE TABLE employees_dept(
    emp_id integer primary key,
    emp_name text not null,
    dept_id integer references departments,
    hire_date date
);
--Valid data
INSERT INTO employees_dept
VALUES
(1,'Jord',2,'22-03-2005'),
(2,'Bob',1,'11-09-2001');
--Invalid data
INSERT INTO employees_dept
VALUES (3,'Larry',4,current_date);

--Task 5.2
CREATE DATABASE LibrarySystem;
--Switch to database
CREATE TABLE authors(
    author_id integer primary key,
    author_name text not null,
    country text
);
CREATE TABLE publishers(
    publisher_id integer primary key,
    publisher_name text not null,
    city text
);
CREATE TABLE books(
    book_id integer primary key,
    title text not null,
    author_id integer references authors,
    publisher_id integer references publishers,
    publication_year integer,
    isbn text unique
);
INSERT INTO authors
VALUES
(1,'Arthur Morgan','USA'),
(2,'Jordan Bruno', 'Kazahstan');
INSERT INTO publishers
VALUES
(1,'Bob Frozen','Chicago'),
(2,'Mike Wizard', 'Detroit');
INSERT INTO books
VALUES
(1,'O-Block',1,1,2023,'VON777'),
(2,'Red Dead Redemtion',2,2,2018,'M1K4');

--Task 5.3
CREATE SCHEMA idk;
--switch to another schema inside current database
SET search_path TO idk, public;

CREATE TABLE categories(
    category_id integer primary key,
    category_name text not null
);
CREATE TABLE products_fk(
    product_id integer primary key,
    product_name text not null,
    category_id integer references categories on delete cascade
);
CREATE TABLE orders(
    order_id integer primary key,
    order_date date not null
);
CREATE TABLE order_item(
    item_id integer primary key,
    order_id integer references orders on delete cascade,
    product_id integer references products_fk,
    quantity integer check ( quantity > 0 )
);
INSERT INTO categories
VALUES
(1,'Car parts'),
(2,'For home');
INSERT INTO products_fk
VALUES
(1,'Toilet paper',2),
(2,'Headlights(1 unit) for 2006 Honda Civic',1);
INSERT INTO orders
VALUES
(1,'20-07-2024'),
(2,'07-10-2025');
INSERT INTO order_item
VALUES
(1,2,1,5),
(2,1,2,2);

DELETE FROM categories
WHERE category_id = 1;
DELETE FROM orders
WHERE order_id = 1;

--Task 6.1
CREATE DATABASE ecommerce;
CREATE TABLE customers(
    customer_id integer primary key,
    name text not null,
    email text unique ,
    phone text,
    registration_date date not null
);
CREATE TABLE products(
    product_id integer primary key,
    name text unique,
    description text,
    price integer check ( price > 0 ),
    stock_quantity integer check ( stock_quantity > 0 )
);
CREATE TABLE orders(
    order_id integer primary key,
    customer_id integer references customers,
    order_date date not null,
    total_amount integer not null,
    status text check
        ( status='pending' or status='processing' or status='shipped' or status='delivered' or status='cancelled')
);
CREATE TABLE order_details(
    order_detail_id integer primary key,
    order_id integer references orders,
    product_id integer references products,
    quantity integer check ( quantity > 0 ),
    unit_price numeric check ( unit_price > 0 )
);
INSERT INTO customers
VALUES
(1,'Rostislav','balbesik@mail.ru','87002281337', '20-05-2010'),
(2,'Nika','nikaklubnika@gmail.com',null,'15-10-2018'),
(3,'Sanzhar','tokishev06@inbox.com','87771238080','10-01-2014'),
(4,'Alisher','alishka@mail.ru','87058884067','30-04-2016'),
(5,'Ayim','bbyim@gmail.com',null,'05-03-2013');
INSERT INTO products
VALUES
(1,'TV','SmartTV+',599.99,15),
(2,'Fridge','Samsung exclusive',429.5,20),
(3,'Air fryer','For KFC',99.9,228),
(4,'Smartphone','Poco X3 Pro',129.99,50),
(5,'Tablet','Apple Ipad',699,10);
INSERT INTO orders
VALUES
(1,1,'20-06-2011',1288.5,'delivered'),
(2,3,'11-02-2015',2097,'cancelled'),
(3,2,'20-12-2020',1650,'shipped'),
(4,1,'01-01-2015',599.99,'pending'),
(5,5,'02-06-2025',499.5,'processing');
INSERT INTO order_details
VALUES
(1,1,2,3,429.5),
(2,3,4,2,129.99),
(3,2,5,3,699),
(4,4,1,1,599.99),
(5,5,3,5,99.9);

DELETE FROM customers WHERE customer_id = 1;

DELETE FROM orders WHERE order_id = 1;
SELECT * FROM order_details WHERE order_id = 1;

DELETE FROM products WHERE product_id = 3;

INSERT INTO products
VALUES (999, 'Bad', 'x', -5, 10);