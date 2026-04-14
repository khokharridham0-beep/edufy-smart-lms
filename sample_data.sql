-- ============================================================
-- AI-Based Assignment Management System - Sample Data
-- ============================================================
USE ai_assignment_system;

-- Clear existing data (using DELETE instead of TRUNCATE to avoid FK errors in some MySQL versions)
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM marks;
DELETE FROM submissions;
DELETE FROM assignments;
DELETE FROM modules;
DELETE FROM subjects;
DELETE FROM users;

ALTER TABLE marks AUTO_INCREMENT = 1;
ALTER TABLE submissions AUTO_INCREMENT = 1;
ALTER TABLE assignments AUTO_INCREMENT = 1;
ALTER TABLE modules AUTO_INCREMENT = 1;
ALTER TABLE subjects AUTO_INCREMENT = 1;
ALTER TABLE users AUTO_INCREMENT = 1;
SET FOREIGN_KEY_CHECKS = 1;

-- Insert Admin (password: admin123)
-- Admin will be ID 1
INSERT INTO users (name, email, password, role) VALUES
('System Admin', 'admin@edufy.com', 'admin123', 'ADMIN');

-- Insert Subjects first (without teacher)
INSERT INTO subjects (name, description) VALUES
('Java Programming', 'Core Java and Advanced Java concepts'),
('Web Development', 'HTML, CSS, JavaScript, JSP and Servlets'),
('Database Management', 'SQL, MySQL and database design principles');

-- Insert Teachers (password: teacher123)
-- Teachers will be IDs 2, 3, 4
INSERT INTO users (name, email, password, role, subject_id) VALUES
('Prof. Ramesh Patel', 'ramesh@edufy.com', 'teacher123', 'TEACHER', 1),
('Prof. Sunita Shah', 'sunita@edufy.com', 'teacher123', 'TEACHER', 2),
('Prof. Amit Kumar', 'amit@edufy.com', 'teacher123', 'TEACHER', 3);

-- Assign teachers to subjects
UPDATE subjects SET teacher_id = 2 WHERE id = 1;
UPDATE subjects SET teacher_id = 3 WHERE id = 2;
UPDATE subjects SET teacher_id = 4 WHERE id = 3;

-- Insert Students (password: student123)
-- Students will be IDs 5, 6, 7, 8
INSERT INTO users (name, email, password, role, subject_id) VALUES
('Rohan Mehta', 'rohan@edufy.com', 'student123', 'STUDENT', 1),
('Priya Sharma', 'priya@edufy.com', 'student123', 'STUDENT', 1),
('Kavya Nair', 'kavya@edufy.com', 'student123', 'STUDENT', 2),
('Arjun Singh', 'arjun@edufy.com', 'student123', 'STUDENT', 3);

-- Insert Modules
INSERT INTO modules (module_name, chapter_name, description, subject_id) VALUES
('Introduction to Java', 'Chapter 1: Getting Started', 'Basics of Java programming language', 1),
('OOP Concepts', 'Chapter 2: Core Java', 'Object Oriented Programming principles', 1),
('Collections Framework', 'Chapter 2: Core Java', 'Java collections and generics', 1),
('HTML & CSS Basics', 'Chapter 1: Frontend Basics', 'Web page structure and styling', 2),
('JavaScript Fundamentals', 'Chapter 2: Dynamic Web', 'Client-side scripting basics', 2),
('SQL Basics', 'Chapter 1: RDBMS Intro', 'SQL queries and database operations', 3),
('Advanced SQL', 'Chapter 2: Advanced Queries', 'Joins, subqueries and stored procedures', 3);

-- Insert Assignments
INSERT INTO assignments (title, question, keywords, module_id, subject_id, teacher_id, max_marks) VALUES
('Java Variables Assignment', 'Explain Java data types and variables with examples', 'variable,datatype,int,String,double,boolean,declaration,initialization', 1, 1, 2, 10),
('OOP Principles', 'Describe the four pillars of OOP with examples', 'encapsulation,inheritance,polymorphism,abstraction,class,object,method,interface', 2, 1, 2, 10),
('HTML Forms', 'Create a registration form using HTML with proper validation', 'form,input,label,button,validation,action,method,fieldset,required', 4, 2, 3, 10),
('SQL SELECT Queries', 'Write SQL queries for various SELECT operations', 'SELECT,FROM,WHERE,ORDER BY,GROUP BY,HAVING,DISTINCT,COUNT,SUM', 6, 3, 4, 10);
