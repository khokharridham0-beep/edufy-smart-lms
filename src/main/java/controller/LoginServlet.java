package controller;

import dao.UserDAO;
import model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * LoginServlet - Handles login for Admin, Teacher, Student
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // If already logged in, redirect to respective dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            redirectToDashboard((User) session.getAttribute("user"), req, resp);
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Please enter email and password.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.authenticate(email.trim(), password.trim());

        if (user == null) {
            req.setAttribute("error", "Invalid email or password. Please try again.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // Create session and store user
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getId());
        session.setAttribute("userName", user.getName());
        session.setAttribute("userRole", user.getRole());
        // Keep session active until user explicitly logs out.
        session.setMaxInactiveInterval(-1);

        redirectToDashboard(user, req, resp);
    }

    private void redirectToDashboard(User user, HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        switch (user.getRole()) {
            case "ADMIN":   resp.sendRedirect(ctx + "/admin/dashboard");   break;
            case "TEACHER": resp.sendRedirect(ctx + "/teacher/dashboard"); break;
            case "STUDENT": resp.sendRedirect(ctx + "/student/dashboard"); break;
            default:        resp.sendRedirect(ctx + "/login.jsp");
        }
    }
}
