-- Task 1
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
CREATE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id;
--Test
SELECT * FROM employee_details; -- 4 rows returned, Tom Brown is not assigned to any department, so he does not show up

--Task 2.2
CREATE VIEW dept_statistics AS
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count, COALESCE(AVG(e.salary), 0) AS average_salary, COALESCE(MAX(e.salary), 0) AS maximum_salary, COALESCE(MIN(e.salary), 0) AS minimum_salary
FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name; -- COALESCE() - converting NULL to 0
--Test
SELECT * FROM dept_statistics
ORDER BY employee_count DESC;

--Task 2.3
CREATE VIEW project_overview AS
SELECT p.project_name, p.budget, d.dept_name, d.location, COUNT(e.emp_id) AS team_size
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name, d.location;
--Test
SELECT * FROM project_overview;

--Task 2.4
CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000; -- Because of LEFT JOIN we can see high earners even if they don't have department
--Test
SELECT * FROM high_earners;

--Task 3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id;
--Test
SELECT * FROM employee_details;

--Task 3.2
ALTER VIEW high_earners RENAME TO top_performers;
--Test
SELECT * FROM top_performers;

--Task 3.3
CREATE TEMP VIEW temp_view AS
SELECT emp_name, salary FROM employees
WHERE salary < 50000;
--Test
SELECT * FROM temp_view;
DROP VIEW IF EXISTS temp_view;

--Task 4.1
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;
--Test
SELECT * FROM employee_salaries;
--Task 4.2
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';
--Test
SELECT * FROM employee_salaries WHERE emp_name = 'John Smith';
--Task 4.3
INSERT INTO employee_salaries
VALUES (6, 'Alise Johnson', 102, 58000);
--Test, Successful
SELECT * FROM employees;
--Task 4.4
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;
--Test, don't work because view allow only dept_id = 101, other will not satisfy this condition
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);

--Task 5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(COUNT(DISTINCT e.emp_id), 0) AS total_employees,
    COALESCE(SUM(DISTINCT e.salary), 0) AS total_salaries,
    COALESCE(COUNT(DISTINCT p.project_id), 0) AS total_projects,
    COALESCE(SUM(DISTINCT p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;
--Test
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;
--Task 5.2
INSERT INTO employees
VALUES (8, 'Charlie Brown', 101, 54000);
--Test, materialized view makes snapshot of data, refreshing updates data for view
REFRESH MATERIALIZED VIEW dept_summary_mv;
--Test 5.3, CONCURRENTLY creates temporary table to refresh view, so we can read data from view while refreshing process
CREATE UNIQUE INDEX dept_summary_mv_index ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
--Task 5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;
--Test, ERROR: materialized view "project_stats_mv" has not been populated
SELECT * FROM project_stats_mv;
--How to fix
REFRESH MATERIALIZED VIEW project_stats_mv;

--Task 6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
CREATE USER report_user WITH PASSWORD 'report456';
--Test
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';
--Task 6.2
CREATE ROLE db_creator WITH CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager WITH CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user WITH SUPERUSER LOGIN PASSWORD 'admin999';
--Task 6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;
--Task 6.4
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;
CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fn001';
GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;
GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;
--Task 6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES on employee_details FROM data_viewer;
--Task 6.6
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER USER analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;

--Task 7.1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
CREATE ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';
GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;
--Task 7.2
CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;
--Test
SELECT tablename, tableowner FROM pg_tables
WHERE schemaname = 'public';
--Task 7.3
CREATE ROLE temp_owner WITH LOGIN;
CREATE TABLE temp_table(
    id int
);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;
--Task 7.4
CREATE VIEW hr_employee_view AS
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name, d.location
FROM employees e JOIN departments d ON e.dept_id = d.dept_id
WHERE e.dept_id = 102;  -- HR department only

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;
drop view dept_dashboard;
--Task 8.1
CREATE VIEW dept_dashboard AS
SELECT d.dept_name, d.location,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    COUNT(DISTINCT p.project_id) AS active_projects,
    COALESCE(SUM(DISTINCT p.budget), 0) AS total_project_budget,
    CASE
        WHEN COUNT(DISTINCT e.emp_id) = 0 THEN 0
        ELSE ROUND(COALESCE(SUM(DISTINCT p.budget), 0) / COUNT(DISTINCT e.emp_id), 2)
    END AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name, d.location
ORDER BY d.dept_name;
--Test
SELECT * FROM dept_dashboard;

--Task 8.2
ALTER TABLE projects
ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000
ORDER BY p.budget DESC;
--Test
SELECT * FROM high_budget_projects;

--Test 8.3
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice WITH PASSWORD 'alice123';
CREATE USER bob WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;