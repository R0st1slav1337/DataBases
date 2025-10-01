CREATE DATABASE advanced_lab
    OWNER postgres;

\c advanced_Lab

CREATE TABLE employees(
    emp_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    department TEXT,
    salary INT,
    hire_date DATE,
    status TEXT DEFAULT 'Active'
);

CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY,
    dept_name TEXT,
    budget INT,
    manager_id INT
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name TEXT,
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Rostislav', 'Krivenko', 'IT','1337', '2025-10-01');

UPDATE employees
SET hire_date = '2019-03-28', salary = 228000
WHERE emp_id = 1;

ALTER TABLE employees
ALTER COLUMN salary SET DEFAULT 50000;

INSERT INTO employees
VALUES (DEFAULT, 'Sanzhar', 'Tokishev', 'Manager', DEFAULT, '2025-09-25', DEFAULT);

INSERT INTO departments
VALUES
    (DEFAULT, 'IT', 250000, 1),
    (DEFAULT, 'Manager', 300000, 2),
    (DEFAULT, 'Economics', 500000, 3);

INSERT INTO employees
VALUES (DEFAULT, 'Alisher', 'Aliev', 'Economics', 50000 * 1.1, CURRENT_DATE, DEFAULT);

CREATE TEMPORARY TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.1
WHERE status = 'Active';

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- Updates department based on salary ranges using CASE expression
UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary > 50000 AND salary <80000 THEN 'Senior'
        ELSE 'Junior'
    END;

ALTER TABLE employees
ALTER COLUMN department SET DEFAULT 'Junior';

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments
SET dept_name = 'Senior'
WHERE dept_name = 'Economics';

-- Updates department budgets based on average employee salaries
UPDATE departments
SET budget = (
    SELECT AVG(salary) * 1.2
    FROM employees
    WHERE employees.department = departments.dept_name
);

UPDATE employees
SET salary = salary * 1.15, status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

-- Removes departments that don't have any active employees
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

INSERT INTO employees
VALUES (DEFAULT, 'Ayim', 'Esenova', NULL, NULL, '2020-02-02', DEFAULT);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

-- CONCAT() join two data in one
INSERT INTO employees
VALUES (DEFAULT, 'Ernur', 'Kuat', 'Management', DEFAULT, CURRENT_DATE, DEFAULT)
RETURNING emp_id, CONCAT(first_name, ' ', last_name) AS full_name;

-- Gives a $5000 raise to all IT department employees and returns old and new salaries
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- Deletes employees hired before 2020 and returns their details
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- Conditional insert that checks for existing employee to avoid duplicates
INSERT INTO employees (first_name, last_name, department, hire_date)
SELECT 'Elnur', 'Sagadiev', 'IT', '2023-05-05'
WHERE NOT EXISTS(
    SELECT 1 FROM employees
    WHERE first_name = 'Elnur' AND last_name = 'Sagadiev'
);

-- Updates salaries based on department budget
UPDATE employees
SET salary =
    CASE
        WHEN department IN (
            SELECT dept_name FROM departments
            WHERE budget > 100000
        ) THEN salary * 1.10
        ELSE salary * 1.05
    END;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
    ('Anna', 'Chernova', 'IT', 70000, CURRENT_DATE),
    ('Dmitriy', 'Kozlov', 'Junior', 75000, CURRENT_DATE),
    ('Yelena', 'Belova', 'Senior', 65000, CURRENT_DATE),
    ('Sergey', 'Morozov', 'Management', 68000, CURRENT_DATE),
    ('Olga', 'Volkova', 'IT', 72000, CURRENT_DATE);


-- Gives a 10% salary increase to specific employees hired today
UPDATE employees
SET salary = salary * 1.10
WHERE emp_id IN (
    SELECT emp_id FROM employees
    WHERE first_name IN ('Anna', 'Dmitriy', 'Yelena', 'Sergey', 'Olga')
      AND last_name IN ('Chernova', 'Kozlov', 'Belova', 'Morozov', 'Volkova')
      AND hire_date = CURRENT_DATE
);

-- Archives table to store inactive employees
CREATE TABLE employee_archive AS
TABLE employees WITH NO DATA;

-- Adds timestamp column to track when the record was archived
ALTER TABLE employee_archive
ADD COLUMN archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Archives inactive employees and then removes them from main table
INSERT INTO employee_archive (
    emp_id, first_name, last_name, department,
    salary, hire_date, status, archived_at
)
SELECT
    emp_id, first_name, last_name, department,
    salary, hire_date, status, CURRENT_TIMESTAMP
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

-- Updates project end dates based on budget and department employee count
UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
    AND dept_id IN (
        SELECT dept_id
        FROM departments
        WHERE (
            SELECT COUNT(*)
            FROM employees
            WHERE employees.department = departments.dept_name
        ) > 3
    );