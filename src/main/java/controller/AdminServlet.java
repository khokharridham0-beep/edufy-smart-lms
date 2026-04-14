package controller;

import dao.*;
import model.*;
import model.Module;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * AdminServlet - Handles all Admin actions
 */
@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    private final UserDAO   userDAO   = new UserDAO();
    private final SubjectDAO subjectDAO = new SubjectDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) return;

        String path = req.getPathInfo(); // e.g. "/dashboard", "/students"
        if (path == null) path = "/dashboard";
        
        if (path.endsWith(".jsp")) {
            req.getServletContext().getNamedDispatcher("jsp").forward(req, resp);
            return;
        }

        switch (path) {
            case "/dashboard":
                loadDashboard(req, resp); break;
            case "/students":
                loadStudents(req, resp); break;
            case "/teachers":
                loadTeachers(req, resp); break;
            case "/subjects":
                loadSubjects(req, resp); break;
            case "/deleteUser":
                deleteUser(req, resp); break;
            case "/deleteSubject":
                deleteSubject(req, resp); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) return;

        String path = req.getPathInfo();
        if (path == null) path = "";

        switch (path) {
            case "/addStudent":
                addUser(req, resp, "STUDENT"); break;
            case "/updateStudent":
                updateUser(req, resp, "STUDENT"); break;
            case "/addTeacher":
                addUser(req, resp, "TEACHER"); break;
            case "/updateTeacher":
                updateUser(req, resp, "TEACHER"); break;
            case "/addSubject":
                addSubject(req, resp); break;
            case "/updateSubject":
                updateSubject(req, resp); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    // ─── Dashboard ────────────────────────────────────────────────
    private void loadDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("studentCount", userDAO.countByRole("STUDENT"));
        req.setAttribute("teacherCount", userDAO.countByRole("TEACHER"));
        req.setAttribute("subjectCount", subjectDAO.countSubjects());
        req.setAttribute("subjects",     subjectDAO.getAllSubjects());
        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }

    // ─── Students ─────────────────────────────────────────────────
    private void loadStudents(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("students", userDAO.getAllStudents());
        req.setAttribute("subjects",  subjectDAO.getAllSubjects());
        req.getRequestDispatcher("/admin/manageStudents.jsp").forward(req, resp);
    }

    private void addUser(HttpServletRequest req, HttpServletResponse resp, String role)
            throws IOException {
        User u = new User();
        u.setName(req.getParameter("name"));
        u.setEmail(req.getParameter("email"));
        u.setPassword(req.getParameter("password"));
        u.setRole(role);
        String subjectIdStr = req.getParameter("subject_id");
        if (subjectIdStr != null && !subjectIdStr.isEmpty())
            u.setSubjectId(Integer.parseInt(subjectIdStr));
        userDAO.addUser(u);
        resp.sendRedirect(req.getContextPath() + "/admin/" +
                (role.equals("STUDENT") ? "students" : "teachers") +
                "?msg=added");
    }

    private void updateUser(HttpServletRequest req, HttpServletResponse resp, String role)
            throws IOException {
        User u = new User();
        u.setId(Integer.parseInt(req.getParameter("id")));
        u.setName(req.getParameter("name"));
        u.setEmail(req.getParameter("email"));
        u.setPassword(req.getParameter("password"));
        u.setRole(role);
        String subjectIdStr = req.getParameter("subject_id");
        if (subjectIdStr != null && !subjectIdStr.isEmpty())
            u.setSubjectId(Integer.parseInt(subjectIdStr));
        userDAO.updateUser(u);
        resp.sendRedirect(req.getContextPath() + "/admin/" +
                (role.equals("STUDENT") ? "students" : "teachers") +
                "?msg=updated");
    }

    private void deleteUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        String redirectTo = req.getParameter("from");
        userDAO.deleteUser(id);
        resp.sendRedirect(req.getContextPath() + "/admin/" + redirectTo + "?msg=deleted");
    }

    // ─── Teachers ─────────────────────────────────────────────────
    private void loadTeachers(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("teachers", userDAO.getAllTeachers());
        req.setAttribute("subjects",  subjectDAO.getAllSubjects());
        req.getRequestDispatcher("/admin/manageTeachers.jsp").forward(req, resp);
    }

    // ─── Subjects ──────────────────────────────────────────────────
    private void loadSubjects(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("subjects",  subjectDAO.getAllSubjects());
        req.setAttribute("teachers", userDAO.getAllTeachers());
        req.getRequestDispatcher("/admin/manageSubjects.jsp").forward(req, resp);
    }

    private void addSubject(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Subject s = new Subject();
        s.setName(req.getParameter("name"));
        s.setDescription(req.getParameter("description"));
        String tid = req.getParameter("teacher_id");
        if (tid != null && !tid.isEmpty()) s.setTeacherId(Integer.parseInt(tid));
        subjectDAO.addSubject(s);
        resp.sendRedirect(req.getContextPath() + "/admin/subjects?msg=added");
    }

    private void updateSubject(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Subject s = new Subject();
        s.setId(Integer.parseInt(req.getParameter("id")));
        s.setName(req.getParameter("name"));
        s.setDescription(req.getParameter("description"));
        String tid = req.getParameter("teacher_id");
        if (tid != null && !tid.isEmpty()) s.setTeacherId(Integer.parseInt(tid));
        subjectDAO.updateSubject(s);
        resp.sendRedirect(req.getContextPath() + "/admin/subjects?msg=updated");
    }

    private void deleteSubject(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        subjectDAO.deleteSubject(id);
        resp.sendRedirect(req.getContextPath() + "/admin/subjects?msg=deleted");
    }

    // ─── Auth Guard ───────────────────────────────────────────────
    private boolean isAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }
        User user = (User) session.getAttribute("user");
        if (!"ADMIN".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }
}
