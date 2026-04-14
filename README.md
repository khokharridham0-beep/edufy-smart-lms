# edufy-smart-lms
🚀 Edufy – AI-assisted Smart LMS with JSP, Servlets, plagiarism detection &amp; premium SaaS UI

Project Overview
Edufy Smart AI Learning Management System is a role-based academic web platform developed for BCA Semester 4. The solution is implemented using Java, JSP, and Servlets, with MySQL as the persistent data store. The platform provides separate operational interfaces for Student, Teacher, and Admin users.

The system combines assignment lifecycle management, keyword-based answer evaluation simulation, plagiarism similarity scoring, timed quiz handling, and administrative governance in one integrated web application.

Project Objective
The objective of this project is to design and implement a structured academic management system that reduces manual evaluation effort, improves visibility of learning outcomes, and supports scalable multi-role workflows.

Primary objectives:
1. Provide a single platform for student, teacher, and admin workflows.
2. Enable assignment creation with configurable keyword criteria.
3. Support text and file-oriented student submission methods.
4. Simulate automated answer evaluation with deterministic logic.
5. Detect potentially copied submissions using similarity analysis.
6. Offer clear result visibility and role-specific analytics.
7. Support timed quiz authoring and participation.

Problem Statement
Traditional assignment and assessment processes are often fragmented, manual, and time-intensive. Teachers spend significant effort on repetitive first-level checks, students receive delayed feedback, and administrators lack centralized operational insights.

An effective academic platform should address these gaps by:
1. Improving assessment turnaround time.
2. Providing structured role-based access and operations.
3. Introducing plagiarism screening before final evaluation.
4. Maintaining transparent student performance records.
5. Consolidating institutional data across subjects, modules, and assessments.

Solution Explanation
Edufy addresses these requirements through a layered architecture and role-oriented workflow design.

Core solution areas:
1. Role-based authentication and session routing.
2. Subject and module organization for academic structure.
3. Assignment creation with keywords, marks, and submission method.
4. Submission processing with validation, file handling, and text extraction.
5. Plagiarism check using Jaccard similarity on normalized token sets.
6. Keyword matching engine for proportional marks computation.
7. Quiz module with timer logic and auto-submission behavior.
8. Administrative controls for users, subjects, and system counts.

System Workflow
1. User authentication
   The user logs in through the login interface. Credentials are validated against the users table, and session attributes are established.

2. Role-based redirection
   After authentication, the system routes the user to the corresponding dashboard: admin, teacher, or student.

3. Academic setup by teacher
   Teachers manage modules, create assignments, configure keywords and marks, and create timed quizzes with MCQ items.

4. Student activity
   Students access subjects, review assignments, submit answers in allowed formats, and attempt quizzes.

5. Submission intake
   Submission processing validates method and file type, stores uploaded files, and extracts text from supported file formats where applicable.

6. Similarity screening
   New submission text is compared with existing submissions of the same assignment. Similarity score and copied verdict are computed.

7. Evaluation
   If not flagged as copied, keyword-based matching calculates marks and matched keywords. If copied, status and score policies are applied.

8. Result persistence and display
   Marks and metadata are saved and shown in student and teacher views.

9. Password recovery
   Forgot-password flow issues OTP by email, verifies OTP with expiry, and updates password after successful verification.

Detailed Modules

Student Module
1. Dashboard access
   Displays available subjects and entry points to academic activities.
2. Subject details view
   Presents modules, assignments, quiz links, submission state, marks, and attempt information.
3. Assignment submission
   Supports text submission, document upload flow, and image upload flow based on assignment configuration.
4. Results and analytics
   Shows marks, maximum marks, matched keywords, and plagiarism score.
5. Quiz participation
   Supports timed quiz attempts and automatic submission when time expires.

Teacher Module
1. Dashboard and quick actions
   Provides counts and direct access to assignment, quiz, submission, and marks pages.
2. Module management
   Creates, updates, and deletes modules for assigned subjects.
3. Assignment management
   Creates, updates, and deletes assignments with keywords, marks, and method controls.
4. Submission and marks review
   Tracks student submissions and evaluated outcomes.
5. Quiz management
   Creates timed MCQ quizzes with configurable options and marks.
6. Quiz result monitoring
   Reviews student attempts, scores, answered count, time taken, and auto-submission state.

Admin Module
1. Dashboard analytics
   Shows institution-level counts for students, teachers, and subjects.
2. Student management
   Supports create, update, and delete operations.
3. Teacher management
   Supports create, update, and delete operations.
4. Subject management
   Supports subject creation, update, deletion, and teacher assignment.
5. Governance
   Maintains high-level data consistency and user role administration.

Technologies Used
Application and architecture
1. Java
2. JSP
3. Servlets
4. DAO pattern
5. MVC-oriented module separation

Frontend
1. HTML5
2. CSS3
3. JavaScript
4. Shared component-driven JSP layouts
5. Responsive dashboard design

Backend and data
1. MySQL
2. JDBC using MySQL Connector J
3. SQL initialization scripts

Runtime libraries
1. javax.servlet-api-4.0.1.jar
2. javax.mail-1.6.2.jar
3. javax.activation-1.2.0.jar
4. mysql-connector-j-9.1.0.jar
5. pdfbox-app-2.0.30.jar

Development and deployment
1. Eclipse IDE
2. Apache Tomcat

Complete Project Folder Structure
edufy-smart-lms
  .classpath
  .gitattributes
  .project
  README.md
  schema.sql
  sample_data.sql

  .settings
    .jsdtscope
    org.eclipse.core.resources.prefs
    org.eclipse.jdt.core.prefs
    org.eclipse.wst.common.component
    org.eclipse.wst.common.project.facet.core.xml
    org.eclipse.wst.jsdt.ui.superType.container
    org.eclipse.wst.jsdt.ui.superType.name

  build
    classes
      controller
        AdminServlet.class
        ForgotPasswordServlet$1.class
        ForgotPasswordServlet.class
        LoginServlet.class
        LogoutServlet.class
        ModulesApiServlet.class
        QuizServlet.class
        ResetPasswordServlet.class
        StudentServlet.class
        SubmissionServlet.class
        TeacherServlet.class
        VerifyOtpServlet.class
      dao
        AssignmentDAO.class
        DBConnection.class
        MarksDAO.class
        ModuleDAO.class
        QuizDAO.class
        SubjectDAO.class
        SubmissionDAO.class
        UserDAO.class
      model
        Assignment.class
        Marks.class
        Module.class
        Quiz.class
        QuizAttempt.class
        QuizQuestion.class
        Subject.class
        Submission.class
        User.class
      utils
        KeywordMatcher$EvaluationResult.class
        KeywordMatcher.class
        PlagiarismChecker$PlagiarismResult.class
        PlagiarismChecker.class

  src
    main
      java
        controller
          AdminServlet.java
          ForgotPasswordServlet.java
          LoginServlet.java
          LogoutServlet.java
          ModulesApiServlet.java
          QuizServlet.java
          ResetPasswordServlet.java
          StudentServlet.java
          SubmissionServlet.java
          TeacherServlet.java
          VerifyOtpServlet.java
        dao
          AssignmentDAO.java
          DBConnection.java
          MarksDAO.java
          ModuleDAO.java
          QuizDAO.java
          SubjectDAO.java
          SubmissionDAO.java
          UserDAO.java
        model
          Assignment.java
          Marks.java
          Module.java
          Quiz.java
          QuizAttempt.java
          QuizQuestion.java
          Subject.java
          Submission.java
          User.java
        utils
          KeywordMatcher.java
          PlagiarismChecker.java

      webapp
        index.jsp
        login.jsp
        forgotPassword.jsp
        verifyOtp.jsp
        resetPassword.jsp
        error.jsp

        admin
          dashboard.jsp
          manageStudents.jsp
          manageSubjects.jsp
          manageTeachers.jsp

        components
          header.jsp
          sidebar.jsp

        css
          style.css

        js
          script.js

        META-INF
          MANIFEST.MF

        student
          dashboard.jsp
          mySubjects.jsp
          subjectDetails.jsp
          submitAssignment.jsp
          takeQuiz.jsp
          viewResult.jsp

        teacher
          dashboard.jsp
          manageModules.jsp
          manageQuizzes.jsp
          mySubjects.jsp
          uploadAssignment.jsp
          viewMarks.jsp
          viewSubmissions.jsp

        WEB-INF
          web.xml
          lib
            javax.activation-1.2.0.jar
            javax.mail-1.6.2.jar
            javax.servlet-api-4.0.1.jar
            mysql-connector-j-9.1.0.jar
            pdfbox-app-2.0.30.jar

Key Features and Highlights
1. End-to-end role-based LMS operation.
2. Multi-format assignment submission workflow.
3. Keyword-based automated marks simulation.
4. Plagiarism similarity scoring and copied status handling.
5. Timed quiz lifecycle with automatic finalization support.
6. OTP-based password reset flow.
7. Clear layered code organization with controller, dao, model, and utility packages.
8. Responsive UI structure with reusable JSP components.
9. SQL scripts for database setup and sample data initialization.
10. Extensible foundation for future product enhancements.

Future Enhancements
1. Replace keyword-only evaluation with semantic NLP-based assessment.
2. Integrate OCR pipeline for image answer text extraction.
3. Apply secure password hashing and stronger authentication policy.
4. Externalize database and mail configuration into secure environment profiles.
5. Add activity audit logs for admin and teacher operations.
6. Introduce advanced chart-based analytics and reporting.
7. Add notifications and reminders for deadlines and quizzes.
8. Expose service APIs for mobile or external integrations.
9. Add automated unit, integration, and UI testing.
10. Introduce CI CD pipeline and environment-based deployment.

Author Information

Name: Khokhar Ridham

Program: Bachelor of Computer Applications, Semester 4

Role: Full Stack Java Web Developer

Email: khokharridham0@gmail.com
