package controller;

import dao.AssignmentDAO;
import dao.DBConnection;
import dao.MarksDAO;
import dao.ModuleDAO;
import dao.QuizDAO;
import dao.SubjectDAO;
import dao.SubmissionDAO;
import model.Assignment;
import model.Module;
import model.Quiz;
import model.QuizAttempt;
import model.QuizQuestion;
import model.Subject;
import model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * TeacherServlet - Handles all Teacher actions
 */
@WebServlet("/teacher/*")
public class TeacherServlet extends HttpServlet {

    private final SubjectDAO    subjectDAO    = new SubjectDAO();
    private final ModuleDAO     moduleDAO     = new ModuleDAO();
    private final AssignmentDAO assignmentDAO = new AssignmentDAO();
    private final SubmissionDAO submissionDAO = new SubmissionDAO();
    private final MarksDAO      marksDAO      = new MarksDAO();
    private final QuizDAO       quizDAO       = new QuizDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isTeacher(req, resp)) return;

        String path = req.getPathInfo();
        if (path == null) path = "/dashboard";
        
        if (path.endsWith(".jsp")) {
            req.getServletContext().getNamedDispatcher("jsp").forward(req, resp);
            return;
        }

        User teacher = getUser(req);

        switch (path) {
            case "/dashboard":
                loadDashboard(req, resp, teacher); break;
            case "/subjects":
                loadSubjects(req, resp, teacher); break;
            case "/modules":
                loadModules(req, resp, teacher); break;
            case "/deleteModule":
                deleteModule(req, resp, teacher); break;
            case "/assignments":
                loadAssignments(req, resp, teacher); break;
            case "/quizzes":
                loadQuizzes(req, resp, teacher); break;
            case "/uploadAssignment":
                showUploadForm(req, resp, teacher); break;
            case "/submissions":
                loadSubmissions(req, resp, teacher); break;
            case "/marks":
                loadMarks(req, resp, teacher); break;
            case "/deleteAssignment":
                deleteAssignment(req, resp, teacher); break;
            case "/deleteQuiz":
                deleteQuiz(req, resp, teacher); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isTeacher(req, resp)) return;

        String path = req.getPathInfo();
        if (path == null) path = "";
        User teacher = getUser(req);

        switch (path) {
            case "/addAssignment":
                addAssignment(req, resp, teacher); break;
            case "/addQuiz":
                addQuiz(req, resp, teacher); break;
            case "/updateAssignment":
                updateAssignment(req, resp, teacher); break;
            case "/addModule":
                addModule(req, resp, teacher); break;
            case "/updateModule":
                updateModule(req, resp, teacher); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
        }
    }

    private void loadDashboard(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws ServletException, IOException {
        req.setAttribute("subjects",    subjectDAO.getSubjectsByTeacher(teacher.getId()));
        req.setAttribute("assignments", assignmentDAO.getAssignmentsByTeacher(teacher.getId()));
        req.setAttribute("quizzes",     quizDAO.getQuizzesByTeacher(teacher.getId()));
        req.getRequestDispatcher("/teacher/dashboard.jsp").forward(req, resp);
    }

    private void loadQuizzes(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws ServletException, IOException {
        java.util.List<model.Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
        java.util.List<model.Module> modules = new java.util.ArrayList<>();
        for (model.Subject s : subjects) {
            modules.addAll(moduleDAO.getModulesBySubject(s.getId()));
        }
        req.setAttribute("modules", modules);
        req.setAttribute("quizzes", quizDAO.getQuizzesByTeacher(teacher.getId()));

        String quizIdParam = req.getParameter("quizId");
        if (quizIdParam != null && !quizIdParam.trim().isEmpty()) {
            try {
                int quizId = Integer.parseInt(quizIdParam);
                if (quizDAO.isQuizOwnedByTeacher(quizId, teacher.getId())) {
                    req.setAttribute("selectedQuiz", quizDAO.getQuizById(quizId));
                    req.setAttribute("quizAttempts", loadQuizAttemptsForTeacherQuiz(quizId));
                }
            } catch (NumberFormatException ignored) {}
        }

        req.getRequestDispatcher("/teacher/manageQuizzes.jsp").forward(req, resp);
    }

    private java.util.List<QuizAttempt> loadQuizAttemptsForTeacherQuiz(int quizId) {
        java.util.List<QuizAttempt> list = new java.util.ArrayList<>();
        String sql = "SELECT qa.*, u.name AS student_name, q.title AS quiz_title, " +
                     "TIMESTAMPDIFF(SECOND, qa.started_at, qa.submitted_at) AS time_taken_seconds " +
                     "FROM quiz_attempts qa " +
                     "JOIN users u ON qa.student_id = u.id " +
                     "JOIN quizzes q ON qa.quiz_id = q.id " +
                     "WHERE qa.quiz_id = ? " +
                     "ORDER BY qa.submitted_at DESC";
        try (java.sql.Connection conn = DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            java.sql.ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                QuizAttempt at = new QuizAttempt();
                at.setId(rs.getInt("id"));
                at.setQuizId(rs.getInt("quiz_id"));
                at.setStudentId(rs.getInt("student_id"));
                at.setStudentName(rs.getString("student_name"));
                at.setQuizTitle(rs.getString("quiz_title"));
                at.setScore(rs.getInt("score"));
                at.setMaxScore(rs.getInt("max_score"));
                at.setAnsweredCount(rs.getInt("answered_count"));
                at.setTotalQuestions(rs.getInt("total_questions"));
                at.setTimeTakenSeconds(rs.getInt("time_taken_seconds"));
                at.setAutoSubmitted(rs.getBoolean("auto_submitted"));
                at.setStartedAt(rs.getString("started_at"));
                at.setSubmittedAt(rs.getString("submitted_at"));
                list.add(at);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void loadSubjects(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws ServletException, IOException {
        req.setAttribute("subjects", subjectDAO.getSubjectsByTeacher(teacher.getId()));
        req.getRequestDispatcher("/teacher/mySubjects.jsp").forward(req, resp);
    }

    private void loadModules(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws ServletException, IOException {
        // Teacher can only see modules from their subjects
        java.util.List<model.Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
        java.util.List<model.Module> allModules = new java.util.ArrayList<>();
        for (model.Subject s : subjects) allModules.addAll(moduleDAO.getModulesBySubject(s.getId()));
        req.setAttribute("modules", allModules);
        req.setAttribute("subjects", subjects);
        req.getRequestDispatcher("/teacher/manageModules.jsp").forward(req, resp);
    }

    private void addModule(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws IOException {
        Module m = new Module();
        m.setModuleName(req.getParameter("module_name"));
        m.setChapterName(req.getParameter("chapter_name"));
        m.setDescription(req.getParameter("description"));
        m.setSubjectId(Integer.parseInt(req.getParameter("subject_id")));
        moduleDAO.addModule(m);
        resp.sendRedirect(req.getContextPath() + "/teacher/modules?msg=added");
    }

    private void updateModule(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws IOException {
        Module m = new Module();
        m.setId(Integer.parseInt(req.getParameter("id")));
        m.setModuleName(req.getParameter("module_name"));
        m.setChapterName(req.getParameter("chapter_name"));
        m.setDescription(req.getParameter("description"));
        m.setSubjectId(Integer.parseInt(req.getParameter("subject_id")));
        moduleDAO.updateModule(m);
        resp.sendRedirect(req.getContextPath() + "/teacher/modules?msg=updated");
    }

    private void deleteModule(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        moduleDAO.deleteModule(id);
        resp.sendRedirect(req.getContextPath() + "/teacher/modules?msg=deleted");
    }

    private void loadAssignments(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws ServletException, IOException {
        java.util.List<model.Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
        java.util.List<model.Module> modules = new java.util.ArrayList<>();
        for (model.Subject s : subjects) {
            modules.addAll(moduleDAO.getModulesBySubject(s.getId()));
        }
        req.setAttribute("subjects", subjects);
        req.setAttribute("modules", modules);
        req.setAttribute("assignments", assignmentDAO.getAssignmentsByTeacher(teacher.getId()));
        req.getRequestDispatcher("/teacher/uploadAssignment.jsp").forward(req, resp);
    }

    private void showUploadForm(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws ServletException, IOException {
        java.util.List<model.Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
        req.setAttribute("subjects", subjects);
        // Modules for first subject if any
        if (!subjects.isEmpty()) {
            req.setAttribute("modules", moduleDAO.getModulesBySubject(subjects.get(0).getId()));
        }
        req.getRequestDispatcher("/teacher/uploadAssignment.jsp").forward(req, resp);
    }

    private void addAssignment(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws IOException {
        Assignment a = new Assignment();
        a.setTitle(req.getParameter("title"));
        a.setQuestion(req.getParameter("question"));
        a.setKeywords(req.getParameter("keywords"));
        a.setModuleId(Integer.parseInt(req.getParameter("module_id")));
        a.setSubjectId(Integer.parseInt(req.getParameter("subject_id")));
        a.setTeacherId(teacher.getId());
        a.setSubmissionMethod(normalizeSubmissionMethod(req.getParameter("submission_method")));
        String maxM = req.getParameter("max_marks");
        a.setMaxMarks(maxM != null && !maxM.isEmpty() ? Integer.parseInt(maxM) : 10);
        assignmentDAO.addAssignment(a);
        resp.sendRedirect(req.getContextPath() + "/teacher/assignments?msg=added");
    }

    private void updateAssignment(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws IOException {
        Assignment a = new Assignment();
        a.setId(Integer.parseInt(req.getParameter("id")));
        a.setTitle(req.getParameter("title"));
        a.setQuestion(req.getParameter("question"));
        a.setKeywords(req.getParameter("keywords"));
        a.setSubmissionMethod(normalizeSubmissionMethod(req.getParameter("submission_method")));
        String maxM = req.getParameter("max_marks");
        a.setMaxMarks(maxM != null && !maxM.isEmpty() ? Integer.parseInt(maxM) : 10);
        assignmentDAO.updateAssignment(a);
        resp.sendRedirect(req.getContextPath() + "/teacher/assignments?msg=updated");
    }

    private String normalizeSubmissionMethod(String method) {
        if (method == null) return "TEXT";
        String normalized = method.trim().toUpperCase();
        switch (normalized) {
            case "TEXT":
            case "FILE":
            case "IMAGE":
                return normalized;
            default:
                return "TEXT";
        }
    }

    private void deleteAssignment(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        assignmentDAO.deleteAssignment(id);
        resp.sendRedirect(req.getContextPath() + "/teacher/assignments?msg=deleted");
    }

    private void addQuiz(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws IOException {
        int moduleId;
        try {
            moduleId = Integer.parseInt(req.getParameter("module_id"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/teacher/quizzes?msg=invalid_module");
            return;
        }

        Module module = moduleDAO.getModuleById(moduleId);
        if (module == null) {
            resp.sendRedirect(req.getContextPath() + "/teacher/quizzes?msg=invalid_module");
            return;
        }

        java.util.List<Subject> teacherSubjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
        boolean ownsSubject = false;
        for (Subject s : teacherSubjects) {
            if (s.getId() == module.getSubjectId()) {
                ownsSubject = true;
                break;
            }
        }
        if (!ownsSubject) {
            resp.sendRedirect(req.getContextPath() + "/teacher/quizzes?msg=forbidden_module");
            return;
        }

        int duration = 10;
        try {
            duration = Integer.parseInt(req.getParameter("duration_minutes"));
        } catch (Exception ignored) {}
        if (duration < 1) duration = 1;
        if (duration > 180) duration = 180;

        String[] questionTexts = req.getParameterValues("question_text");
        String[] optionAs = req.getParameterValues("option_a");
        String[] optionBs = req.getParameterValues("option_b");
        String[] optionCs = req.getParameterValues("option_c");
        String[] optionDs = req.getParameterValues("option_d");
        String[] correctOptions = req.getParameterValues("correct_option");
        String[] marksValues = req.getParameterValues("marks");

        java.util.List<QuizQuestion> questions = new java.util.ArrayList<>();
        if (questionTexts != null) {
            for (int i = 0; i < questionTexts.length; i++) {
                String qt = safeAt(questionTexts, i);
                String oa = safeAt(optionAs, i);
                String ob = safeAt(optionBs, i);
                String oc = safeAt(optionCs, i);
                String od = safeAt(optionDs, i);
                String co = safeAt(correctOptions, i);
                if (isBlank(qt) || isBlank(oa) || isBlank(ob) || isBlank(oc) || isBlank(od) || isBlank(co)) {
                    continue;
                }

                int marks = 1;
                try { marks = Integer.parseInt(safeAt(marksValues, i)); } catch (Exception ignored) {}
                if (marks < 1) marks = 1;
                if (marks > 100) marks = 100;

                QuizQuestion q = new QuizQuestion();
                q.setQuestionText(qt.trim());
                q.setOptionA(oa.trim());
                q.setOptionB(ob.trim());
                q.setOptionC(oc.trim());
                q.setOptionD(od.trim());
                q.setCorrectOption(normalizeOption(co));
                q.setMarks(marks);
                questions.add(q);
            }
        }

        if (questions.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/teacher/quizzes?msg=no_questions");
            return;
        }

        Quiz quiz = new Quiz();
        quiz.setTitle(req.getParameter("title"));
        quiz.setDescription(req.getParameter("description"));
        quiz.setModuleId(moduleId);
        quiz.setSubjectId(module.getSubjectId());
        quiz.setTeacherId(teacher.getId());
        quiz.setDurationMinutes(duration);

        boolean ok = quizDAO.createQuizWithQuestions(quiz, questions);
        resp.sendRedirect(req.getContextPath() + "/teacher/quizzes?msg=" + (ok ? "added" : "failed"));
    }

    private void deleteQuiz(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws IOException {
        int quizId;
        try {
            quizId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/teacher/quizzes?msg=invalid");
            return;
        }

        if (!quizDAO.isQuizOwnedByTeacher(quizId, teacher.getId())) {
            resp.sendRedirect(req.getContextPath() + "/teacher/quizzes?msg=forbidden");
            return;
        }

        quizDAO.deleteQuiz(quizId);
        resp.sendRedirect(req.getContextPath() + "/teacher/quizzes?msg=deleted");
    }

    private String safeAt(String[] arr, int idx) {
        if (arr == null || idx < 0 || idx >= arr.length) return "";
        return arr[idx] != null ? arr[idx] : "";
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String normalizeOption(String option) {
        if (option == null) return "A";
        String n = option.trim().toUpperCase();
        if ("A".equals(n) || "B".equals(n) || "C".equals(n) || "D".equals(n)) return n;
        return "A";
    }

    private void loadSubmissions(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws ServletException, IOException {
        String aid = req.getParameter("assignmentId");
        if (aid != null && !aid.isEmpty()) {
            int assignmentId = Integer.parseInt(aid);
            req.setAttribute("submissions", submissionDAO.getSubmissionsByAssignment(assignmentId));
            req.setAttribute("assignment",  new AssignmentDAO().getAssignmentById(assignmentId));
        }
        req.setAttribute("assignments", assignmentDAO.getAssignmentsByTeacher(teacher.getId()));
        req.getRequestDispatcher("/teacher/viewSubmissions.jsp").forward(req, resp);
    }

    private void loadMarks(HttpServletRequest req, HttpServletResponse resp, User teacher)
            throws ServletException, IOException {
        String aid = req.getParameter("assignmentId");
        if (aid != null && !aid.isEmpty()) {
            req.setAttribute("marksList",  marksDAO.getMarksByAssignment(Integer.parseInt(aid)));
            req.setAttribute("assignment", new AssignmentDAO().getAssignmentById(Integer.parseInt(aid)));
        }
        req.setAttribute("assignments", assignmentDAO.getAssignmentsByTeacher(teacher.getId()));
        req.getRequestDispatcher("/teacher/viewMarks.jsp").forward(req, resp);
    }

    private boolean isTeacher(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); return false;
        }
        User user = (User) session.getAttribute("user");
        if (!"TEACHER".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); return false;
        }
        return true;
    }

    private User getUser(HttpServletRequest req) {
        return (User) req.getSession().getAttribute("user");
    }
}
