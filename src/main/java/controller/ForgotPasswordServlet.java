package controller;

import dao.UserDAO;
import model.User;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Date;
import java.util.Properties;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private String mailError = null;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/forgotPassword.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Please enter your registered email.");
            req.getRequestDispatcher("/forgotPassword.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.getUserByEmail(email.trim());
        if (user == null) {
            req.setAttribute("error", "No account found with this email.");
            req.getRequestDispatcher("/forgotPassword.jsp").forward(req, resp);
            return;
        }

        String otp = generateOtp();
        if (!sendOtpEmail(email.trim(), otp)) {
            req.setAttribute("error", mailError != null ? mailError : "Could not send OTP email. Please try again or contact admin.");
            req.getRequestDispatcher("/forgotPassword.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("fpEmail", email.trim());
        session.setAttribute("fpOtp", otp);
        session.setAttribute("fpExpiry", System.currentTimeMillis() + (5 * 60 * 1000));
        session.setAttribute("fpVerified", Boolean.FALSE);

        resp.sendRedirect(req.getContextPath() + "/verify-otp");
    }

    private String generateOtp() {
        SecureRandom random = new SecureRandom();
        int value = 100000 + random.nextInt(900000);
        return String.valueOf(value);
    }

    private boolean sendOtpEmail(String toEmail, String otp) {
        // Read SMTP settings in this order: env -> JVM property -> web.xml context-param.
        String smtpHost = readConfig("EDUFY_SMTP_HOST", "smtp.host", "smtp.gmail.com");
        String smtpPort = readConfig("EDUFY_SMTP_PORT", "smtp.port", "587");
        String smtpUser = readConfig("EDUFY_SMTP_USER", "smtp.user", null);
        String smtpPass = readConfig("EDUFY_SMTP_PASS", "smtp.pass", null);

        if (smtpUser == null || smtpPass == null || smtpUser.trim().isEmpty() || smtpPass.trim().isEmpty()) {
            mailError = "SMTP not configured. Set EDUFY_SMTP_USER and EDUFY_SMTP_PASS (or smtp.user/smtp.pass in web.xml).";
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);

        Session mailSession = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUser, smtpPass);
            }
        });

        try {
            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(smtpUser, "Edufy Support"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Edufy Password Reset OTP");
            message.setSentDate(new Date());
            message.setText("Your OTP for password reset is: " + otp + "\n\nThis OTP is valid for 5 minutes.");
            Transport.send(message);
            mailError = null;
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            mailError = "OTP email failed: " + e.getMessage();
            return false;
        }
    }

    private String readConfig(String envKey, String contextKey, String defaultValue) {
        String val = System.getenv(envKey);
        if (val != null && !val.trim().isEmpty()) return val.trim();

        val = System.getenv(contextKey);
        if (val != null && !val.trim().isEmpty()) return val.trim();

        val = System.getProperty(envKey);
        if (val != null && !val.trim().isEmpty()) return val.trim();

        val = System.getProperty(contextKey);
        if (val != null && !val.trim().isEmpty()) return val.trim();

        val = getServletContext().getInitParameter(envKey);
        if (val != null && !val.trim().isEmpty()) return val.trim();

        val = getServletContext().getInitParameter(contextKey);
        if (val != null && !val.trim().isEmpty()) return val.trim();

        return defaultValue;
    }
}
