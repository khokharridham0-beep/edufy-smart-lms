package controller;

import dao.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("fpEmail") == null || !Boolean.TRUE.equals(session.getAttribute("fpVerified"))) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }
        req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("fpEmail") == null || !Boolean.TRUE.equals(session.getAttribute("fpVerified"))) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String password = req.getParameter("password");
        String confirm = req.getParameter("confirm_password");
        String email = (String) session.getAttribute("fpEmail");

        if (password == null || password.trim().isEmpty() || confirm == null || confirm.trim().isEmpty()) {
            req.setAttribute("error", "Please enter both password fields.");
            req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirm)) {
            req.setAttribute("error", "Password and confirm password do not match.");
            req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
            return;
        }

        boolean updated = userDAO.updatePasswordByEmail(email, password);
        if (!updated) {
            req.setAttribute("error", "Could not reset password. Please try again.");
            req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
            return;
        }

        clearResetState(session);
        resp.sendRedirect(req.getContextPath() + "/login?reset=success");
    }

    private void clearResetState(HttpSession session) {
        session.removeAttribute("fpEmail");
        session.removeAttribute("fpOtp");
        session.removeAttribute("fpExpiry");
        session.removeAttribute("fpVerified");
    }
}
