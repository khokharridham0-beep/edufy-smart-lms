package controller;

import dao.*;
import model.*;
import model.Module;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * StudentServlet - Handles all Student portal actions
 */
@WebServlet("/student/*")
public class StudentServlet extends HttpServlet {

    private final SubjectDAO    subjectDAO    = new SubjectDAO();
    private final ModuleDAO     moduleDAO     = new ModuleDAO();
    private final AssignmentDAO assignmentDAO = new AssignmentDAO();
    private final SubmissionDAO submissionDAO = new SubmissionDAO();
    private final MarksDAO      marksDAO      = new MarksDAO();
    private final QuizDAO       quizDAO       = new QuizDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isStudent(req, resp)) return;
        User student = getUser(req);

        String path = req.getPathInfo();
        if (path == null) path = "/dashboard";
        
        if (path.endsWith(".jsp")) {
            req.getServletContext().getNamedDispatcher("jsp").forward(req, resp);
            return;
        }

        switch (path) {
            case "/dashboard":
                loadDashboard(req, resp, student); break;
            case "/subjects":
                loadSubjects(req, resp, student); break;
            case "/subjectDetails":
                loadSubjectDetails(req, resp, student); break;
            case "/submitAssignment":
                showSubmitForm(req, resp, student); break;
            case "/results":
                loadResults(req, resp, student); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }

    private void loadDashboard(HttpServletRequest req, HttpServletResponse resp, User student)
            throws ServletException, IOException {
        List<Subject> subjects = subjectDAO.getAllSubjects();

        req.setAttribute("subjects",       subjects);
        req.setAttribute("submitMsg",      req.getSession().getAttribute("submitMsg"));
        req.getSession().removeAttribute("submitMsg");
        req.getRequestDispatcher("/student/dashboard.jsp").forward(req, resp);
    }

    private void loadSubjects(HttpServletRequest req, HttpServletResponse resp, User student)
            throws ServletException, IOException {
        req.setAttribute("subjects", subjectDAO.getAllSubjects());
        req.getRequestDispatcher("/student/mySubjects.jsp").forward(req, resp);
    }

    private void loadSubjectDetails(HttpServletRequest req, HttpServletResponse resp, User student)
            throws ServletException, IOException {
        String subjectIdParam = req.getParameter("subjectId");
        if (subjectIdParam == null) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }
        int subjectId = Integer.parseInt(subjectIdParam);

        Subject subject = subjectDAO.getSubjectById(subjectId);
        List<Module> modules = moduleDAO.getModulesBySubject(subjectId);

        // Build module → assignments map
        Map<Integer, List<Assignment>> moduleAssignmentsMap = new LinkedHashMap<>();
        Map<Integer, List<Quiz>> moduleQuizMap = new LinkedHashMap<>();
        for (Module m : modules) {
            moduleAssignmentsMap.put(m.getId(), assignmentDAO.getAssignmentsByModule(m.getId()));
            moduleQuizMap.put(m.getId(), quizDAO.getQuizzesByModule(m.getId()));
        }

        // Submission & marks for each assignment
        Map<Integer, Submission> submissionMap = new HashMap<>();
        Map<Integer, Marks> marksMap = new HashMap<>();
        Map<Integer, QuizAttempt> quizAttemptMap = new HashMap<>();
        for (List<Assignment> aList : moduleAssignmentsMap.values()) {
            for (Assignment a : aList) {
                Submission sub = submissionDAO.getStudentSubmission(student.getId(), a.getId());
                if (sub != null) submissionMap.put(a.getId(), sub);
                Marks mk = marksDAO.getMarks(student.getId(), a.getId());
                if (mk != null) marksMap.put(a.getId(), mk);
            }
        }
        for (List<Quiz> qList : moduleQuizMap.values()) {
            for (Quiz qz : qList) {
                QuizAttempt qa = quizDAO.getQuizAttempt(qz.getId(), student.getId());
                if (qa != null) quizAttemptMap.put(qz.getId(), qa);
            }
        }

        req.setAttribute("subject",               subject);
        req.setAttribute("modules",               modules);
        req.setAttribute("moduleAssignmentsMap",  moduleAssignmentsMap);
        req.setAttribute("moduleQuizMap",         moduleQuizMap);
        req.setAttribute("submissionMap",         submissionMap);
        req.setAttribute("marksMap",              marksMap);
        req.setAttribute("quizAttemptMap",        quizAttemptMap);
        req.setAttribute("quizMsg",               req.getParameter("quizMsg"));
        req.getRequestDispatcher("/student/subjectDetails.jsp").forward(req, resp);
    }

    private void showSubmitForm(HttpServletRequest req, HttpServletResponse resp, User student)
            throws ServletException, IOException {
        String aid = req.getParameter("assignmentId");
        if (aid != null) {
            Assignment a = assignmentDAO.getAssignmentById(Integer.parseInt(aid));
            req.setAttribute("assignment", a);
        }
        req.getRequestDispatcher("/student/submitAssignment.jsp").forward(req, resp);
    }

    private void loadResults(HttpServletRequest req, HttpServletResponse resp, User student)
            throws ServletException, IOException {
        List<Marks> marksList = marksDAO.getMarksByStudent(student.getId());
        req.setAttribute("marksList",  marksList);
        req.setAttribute("submitMsg",  req.getSession().getAttribute("submitMsg"));
        req.getSession().removeAttribute("submitMsg");
        req.getRequestDispatcher("/student/viewResult.jsp").forward(req, resp);
    }

    private boolean isStudent(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); return false;
        }
        User user = (User) session.getAttribute("user");
        if (!"STUDENT".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); return false;
        }
        return true;
    }

    private User getUser(HttpServletRequest req) {
        return (User) req.getSession().getAttribute("user");
    }
}
