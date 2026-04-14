<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Edufy</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .login-footer { margin-top: 20px; text-align: center; font-size: 13px; color: var(--muted); }
        .forgot-wrap { text-align: right; margin-top: 8px; }
        .forgot-link { font-size: 12px; color: var(--teal); text-decoration: none; }
        .forgot-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
<div class="login-page">
    <div class="login-bg"></div>
    <div class="login-box">
        <div class="login-logo">🤖</div>
        <h1>Welcome Back</h1>
        <p>Sign in to Edufy</p>

        <% String error = (String) request.getAttribute("error"); %>
        <% String resetStatus = request.getParameter("reset"); %>
        <% if ("success".equals(resetStatus)) { %>
        <div class="alert alert-success" data-auto-dismiss>✅ Password reset successful. Please login with your new password.</div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger" data-auto-dismiss>⚠ <%= error %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login" method="post">
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" class="form-control" placeholder="Enter your email" required
                       id="emailInput">
            </div>
            <div class="form-group">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" placeholder="Enter your password" required
                       id="passInput">
                <div class="forgot-wrap">
                    <a class="forgot-link" href="<%= request.getContextPath() %>/forgot-password">Forgot Password?</a>
                </div>
            </div>
            <button type="submit" class="btn btn-teal w-100" style="justify-content:center;padding:11px;">
                Sign In →
            </button>
        </form>

        <div class="login-footer">
            Login with your registered email and password.
        </div>
    </div>
</div>
<script src="<%= request.getContextPath() %>/js/script.js"></script>
</body>
</html>


