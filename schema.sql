-- ============================================================
-- AI-Based Assignment Management System - Database Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS ai_assignment_system;
USE ai_assignment_system;

-- Users Table (Admin, Teacher, Student)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'TEACHER', 'STUDENT') NOT NULL,
    subject_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subjects Table
CREATE TABLE IF NOT EXISTS subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    teacher_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Modules Table (belongs to a Subject)
CREATE TABLE IF NOT EXISTS modules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    module_name VARCHAR(200) NOT NULL,
    chapter_name VARCHAR(255),
    description TEXT,
    subject_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
);

-- Assignments Table
CREATE TABLE IF NOT EXISTS assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    question TEXT NOT NULL,
    keywords TEXT NOT NULL,
    module_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    max_marks INT DEFAULT 10,
    submission_method ENUM('TEXT', 'FILE', 'IMAGE') NOT NULL DEFAULT 'TEXT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id)
);

-- Submissions Table
CREATE TABLE IF NOT EXISTS submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    assignment_id INT NOT NULL,
    file_path VARCHAR(500),
    text_content TEXT,
    status ENUM('PENDING', 'EVALUATED', 'COPIED', 'REJECTED') DEFAULT 'PENDING',
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
);

-- Marks Table
CREATE TABLE IF NOT EXISTS marks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    assignment_id INT NOT NULL,
    marks_obtained INT DEFAULT 0,
    max_marks INT DEFAULT 10,
    matched_keywords TEXT,
    plagiarism_score INT DEFAULT 0,
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
);

-- Add foreign key for subject_id in users after subjects table created
ALTER TABLE users ADD CONSTRAINT fk_user_subject
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL;

ALTER TABLE subjects ADD CONSTRAINT fk_subject_teacher
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL;
    
