package controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/verify-otp")
public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("fpEmail") == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }
        req.getRequestDispatcher("/verifyOtp.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("fpEmail") == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String enteredOtp = req.getParameter("otp");
        String expectedOtp = (String) session.getAttribute("fpOtp");
        Long expiry = (Long) session.getAttribute("fpExpiry");

        if (enteredOtp == null || enteredOtp.trim().isEmpty()) {
            req.setAttribute("error", "Please enter the OTP.");
            req.getRequestDispatcher("/verifyOtp.jsp").forward(req, resp);
            return;
        }

        if (expiry == null || System.currentTimeMillis() > expiry) {
            clearResetState(session);
            req.setAttribute("error", "OTP has expired. Please request a new one.");
            req.getRequestDispatcher("/forgotPassword.jsp").forward(req, resp);
            return;
        }

        if (!enteredOtp.trim().equals(expectedOtp)) {
            req.setAttribute("error", "Invalid OTP. Please try again.");
            req.getRequestDispatcher("/verifyOtp.jsp").forward(req, resp);
            return;
        }

        session.setAttribute("fpVerified", Boolean.TRUE);
        resp.sendRedirect(req.getContextPath() + "/reset-password");
    }

    private void clearResetState(HttpSession session) {
        session.removeAttribute("fpEmail");
        session.removeAttribute("fpOtp");
        session.removeAttribute("fpExpiry");
        session.removeAttribute("fpVerified");
    }
}
