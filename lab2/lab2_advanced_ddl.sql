CREATE DATABASE university_main
    OWNER postgres
    TEMPLATE template0
    ENCODING 'UTF8';
CREATE DATABASE university_archive
    CONNECTION LIMIT 50
    TEMPLATE template0;
CREATE DATABASE university_test
    CONNECTION LIMIT 10
    IS_TEMPLATE true;
CREATE TABLESPACE student_data
    LOCATION 'C:/Program Files/PostgreSQL/17/data/students';
CREATE TABLESPACE course_data
    OWNER postgres
    LOCATION 'C:/Program Files/PostgreSQL/17/data/courses';
CREATE DATABASE university_distributed
    TABLESPACE student_data
    ENCODING 'LATIN9'
    LC_COLLATE='C'
    LC_CTYPE='C'
    TEMPLATE template0;

\c university_main -- work directly in university_main database

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(4,2),
    is_active BOOLEAN DEFAULT TRUE,
    graduation_year SMALLINT
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    office_number VARCHAR(20),
    hire_date DATE,
    salary NUMERIC(12,2),
    is_tenured BOOLEAN DEFAULT FALSE,
    years_experience INT
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8) UNIQUE NOT NULL,
    course_title VARCHAR(100) NOT NULL,
    description TEXT,
    credits SMALLINT,
    max_enrollment INT,
    course_fee NUMERIC(10,2),
    is_online BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INT REFERENCES courses(course_id) ON DELETE CASCADE,
    professor_id INT REFERENCES professors(professor_id) ON DELETE SET NULL,
    classroom VARCHAR(20),
    class_date DATE NOT NULL,
    start_time TIME WITHOUT TIME ZONE NOT NULL,
    end_time TIME WITHOUT TIME ZONE NOT NULL,
    duration INTERVAL
);

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id) ON DELETE CASCADE,
    course_id INT REFERENCES courses(course_id) ON DELETE CASCADE,
    semester VARCHAR(20),
    year INT,
    grade CHAR(2),
    attendance_percentage NUMERIC(4,1),
    submission_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- change students
ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20) DEFAULT 'ACTIVE';
ALTER TABLE students
    ALTER COLUMN phone TYPE VARCHAR(20);
ALTER TABLE students
    ALTER COLUMN gpa SET DEFAULT 0.00;

-- change professors
ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ADD COLUMN last_promotion_date DATE;
ALTER TABLE professors
    ALTER COLUMN years_experience TYPE SMALLINT;
ALTER TABLE professors
    ALTER COLUMN is_tenured SET DEFAULT FALSE;

-- change courses
ALTER TABLE courses
    ADD COLUMN prerequisite_course_id INTEGER,
    ADD COLUMN difficulty_level SMALLINT,
    ADD COLUMN lab_required BOOLEAN DEFAULT FALSE;
ALTER TABLE courses
    ALTER COLUMN course_code TYPE VARCHAR(10);
ALTER TABLE courses
    ALTER COLUMN credits SET DEFAULT 3;

-- change schedule
ALTER TABLE class_schedule
    ADD COLUMN room_capacity INTEGER,
    ADD COLUMN session_type VARCHAR(15),
    ADD COLUMN equipment_needed TEXT;
ALTER TABLE class_schedule
    DROP COLUMN duration,
    ALTER COLUMN classroom TYPE VARCHAR(30);

-- change records
ALTER TABLE student_records
    ADD COLUMN extra_credit_points DECIMAL(4,1) DEFAULT 0.0,
    ADD COLUMN final_exam_date DATE;
ALTER TABLE student_records
    ALTER COLUMN grade TYPE VARCHAR(5);
ALTER TABLE student_records
    DROP COLUMN last_updated;

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL ,
    department_code CHAR(5) UNIQUE NOT NULL,
    building VARCHAR(50),
    phone VARCHAR(15),
    budget NUMERIC(15,2),
    established_year INTEGER
);

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price NUMERIC(10,2),
    is_available BOOLEAN DEFAULT TRUE,
    acquisition_timestamp TIMESTAMP
);

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    book_id INTEGER,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount NUMERIC(10,2),
    loan_status VARCHAR(20),
    CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES library_books(book_id) ON DELETE CASCADE
);

-- make realtion with professors by department_code
ALTER TABLE professors
    ADD CONSTRAINT fk_professor_department
    FOREIGN KEY (department_code)
    REFERENCES departments(department_code)
    ON DELETE SET NULL;

-- without relations
ALTER TABLE professors
    ADD COLUMN department_id INTEGER;
ALTER TABLE students
    ADD COLUMN advisor_id INTEGER;
ALTER TABLE courses
    ADD COLUMN department_id INTEGER;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) NOT NULL,
    min_percentage DECIMAL(4,1) NOT NULL,
    max_percentage DECIMAL(4,1) NOT NULL,
    gpa_points DECIMAL(3,2) NOT NULL
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20) NOT NULL,
    academic_year INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_deadline TIMESTAMPTZ NOT NULL,
    is_current BOOLEAN DEFAULT FALSE
);

DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

-- recreate table 
CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) NOT NULL,
    min_percentage DECIMAL(4,1) NOT NULL,
    max_percentage DECIMAL(4,1) NOT NULL,
    gpa_points DECIMAL(3,2) NOT NULL,
    description TEXT                -- new column
);

-- drop and recreate
DROP TABLE IF EXISTS semester_calendar CASCADE;
CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20) NOT NULL,
    academic_year INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_deadline TIMESTAMPTZ NOT NULL,
    is_current BOOLEAN DEFAULT FALSE
);

-- make template = false
UPDATE pg_database
SET datistemplate = false
WHERE datname = 'university_test';
-- drop database
DROP DATABASE IF EXISTS university_test;

DROP DATABASE IF EXISTS university_distributed;

-- make a backup based on database
CREATE DATABASE university_backup
    WITH TEMPLATE university_main
    OWNER postgres;