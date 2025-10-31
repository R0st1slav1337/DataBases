-- Task 1.1
CREATE TABLE employees(
    emp_id int primary key,
    emp_name varchar(50),
    dept_id int,
    salary decimal(10, 2)
);
CREATE TABLE departments(
    dept_id int primary key,
    dept_name varchar(50),
    location varchar(50)
);
CREATE TABLE projects(
    project_id int primary key,
    project_name varchar(50),
    dept_id int,
    budget decimal(10, 2)
);
--Task 1.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (101, 'IT', 'Building A'),
    (102, 'HR', 'Building B'),
    (103, 'Finance', 'Building C'),
    (104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES
    (1, 'Website Redesign', 101, 100000),
    (2, 'Employee Training', 102, 50000),
    (3, 'Budget Analysis', 103, 75000),
    (4, 'Cloud Migration', 101, 150000),
    (5, 'AI Research', NULL, 200000);

--Task 2.1
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d; -- 5 emp * 4 dept = 20 possible variants
--Task 2.2
--Comma notation
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;
--INNER JOIN
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;
--Task 2.3
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p;

--Task 3.1
--Returned 4 rows, Tom Brown has not department
SELECT e.emp_name, d.dept_name, d.location
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id;
--Task 3.2
--USING syntax provides cleaner output by eliminating the redundant join column.
SELECT emp_name, dept_name, location
FROM employees INNER JOIN departments USING (dept_id);
--Task 3.3
SELECT emp_name, dept_name, location
FROM employees NATURAL INNER JOIN departments;
--Task 3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

--Task 4.1
--Tom Brown is shown because of LEFT JOIN, but have all NULL values
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id;
--Task 4.2
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e LEFT JOIN departments d USING (dept_id);
--Task 4.3
SELECT e.emp_name, e.dept_id
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
--Task 4.4
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

--Task 5.1
SELECT e.emp_name, d.dept_name
FROM employees e RIGHT JOIN departments d ON e.dept_id = d.dept_id;
--Task 5.2
SELECT e.emp_name, d.dept_name
FROM departments d LEFT JOIN employees e on d.dept_id = e.dept_id
--Task 5.3
SELECT d.dept_name, d.location
FROM employees e RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--Task 6.1
--NULL values for Tom Brown (he is not in any department) and Marketing (there are not any employees)
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e FULL JOIN departments d ON e.dept_id = d.dept_id;
--Task 6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d FULL JOIN projects p ON d.dept_id = p.dept_id;
--Task 6.3
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;
--Task 7.1
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
--Task 7.2
--WHERE clause returning only matching rows (is applied after joining), while filter in ON clause returning all rows (is applied while joining)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--Task 7.3
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
--No difference because INNER JOIN returns only matching data from both tables, can't be NULL values
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--Task 8.1
SELECT d.dept_name, e.emp_name, e.salary, p.project_name, p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;
--Task 8.2
-- Add manager_id column
ALTER TABLE employees ADD COLUMN manager_id INT;
-- Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;
--Self join query
SELECT e.emp_name AS employee, m.emp_name AS manager
FROM employees e LEFT JOIN employees m ON e.manager_id = m.emp_id;
--Task 8.3
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;
--Answers for Lab questions are in word document