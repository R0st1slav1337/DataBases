--Task 1
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

--Task 2.1
CREATE INDEX emp_salary_idx ON employees(salary);
--Test, 2 indexes: emp_salary_idx, employees_pkey
SELECT indexname, indexdef FROM pg_indexes
WHERE tablename = 'employees';

--Task 2.2, Indexing foreign key columns improves join performance, speeds up referential integrity checks
CREATE INDEX emp_dept_idx ON employees(dept_id);
--Test
SELECT * FROM employees WHERE dept_id = 101;

--Task 2.3, departments_pkey, emp_dept_idx, emp_salary_idx, employees_pkey, projects_pkey; pkey indexes were created automatically
SELECT tablename, indexname, indexdef FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

--Task 3.1, No, because the index is sorted by dept_id first and then by salary, so searching for salary alone would require a full index scan
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
--Test
SELECT emp_name, salary FROM employees
WHERE dept_id = 101 AND salary > 52000;

--Task 3.2, Yes, index is sorted by the first column first, then the second, and so on,
--making it efficient for queries that filter by the leftmost columns but not for queries that skip them
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
--Test
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

--Task 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);
--Test, ERROR: Duplicate key value violates the uniqueness constraint "emp_email_unique_idx"
--Details: The key "(email)=(john.smith@company.com )" already exists.
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

--Task 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;
--Test, Yes, PostgreSQL automatically creates a unique index when you add a UNIQUE constraint
SELECT indexname, indexdef FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

--Task 5.1, helps by storing the salary data in descending order, allowing the database to retrieve records
-- directly in the required sorted order without performing a separate sorting operation.
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
--Test
SELECT emp_name, salary FROM employees
ORDER BY salary DESC;

--Task 5.2, showing NULL values before not nulls
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
--Test
SELECT proj_name, budget FROM projects
ORDER BY budget NULLS FIRST;

--Task 6.1, without index PostgreSQL would have to perform a full table scan and
-- apply the LOWER() function to every emp_name value to find matches
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
--Test
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

--Task 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));
--Test
SELECT emp_name, hire_date FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

--Task 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
--Test
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

--Task 7.2, to reduce storage overhead, improve write performance (indexes slow down INSERT/UPDATE/DELETE operations)
DROP INDEX emp_salary_dept_idx;

--Task 7.3
REINDEX INDEX employees_salary_index;

--Task 8.1
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
-- CREATE INDEX emp_dept_idx ON employees(dept_id);
-- CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

--Task 8.2,
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;
--Test, it's smaller, faster to maintain, and uses less storage because
-- it only indexes a subset of rows that meet the specified condition
SELECT proj_name, budget FROM projects
WHERE budget > 80000;

--Task 8.3, output shows a "Seq Scan" (Sequential Scan), which tells that PostgreSQL decided
-- to scan the entire table rather than use an index
EXPLAIN SELECT * FROM employees WHERE salary > 52000;

--Task 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
--Test, HASH is faster when you only perform simple equality comparisons (=) and not range queries
SELECT * FROM departments WHERE dept_name = 'IT';

--Task 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);
--Test, both can do first query, only btree can bo second query
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
SELECT * FROM projects WHERE proj_name > 'Database';

--Task 10.1, dept_name_hash_idx and proj_name_hash_idx are largest,
-- because hash indexes require more storage overhead for their bucket structure compared to B-tree indexes
SELECT schemaname, tablename, indexname, pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

--Task 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;

--Task 10.3
CREATE VIEW index_documentation AS
SELECT tablename, indexname, indexdef, 'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public' AND indexname LIKE '%salary%';
--Test
SELECT * FROM index_documentation;

--Answers for questions summary questions are in word document