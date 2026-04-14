<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify OTP — Edufy</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="login-page">
    <div class="login-bg"></div>
    <div class="login-box">
        <div class="login-logo">📩</div>
        <h1>Verify OTP</h1>
        <p>Enter the OTP sent to your email.</p>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <div class="alert alert-danger" data-auto-dismiss><%= error %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/verify-otp" method="post">
            <div class="form-group">
                <label class="form-label">OTP</label>
                <input type="text" name="otp" class="form-control" maxlength="6" placeholder="Enter 6-digit OTP" required>
            </div>
            <button type="submit" class="btn btn-teal w-100" style="justify-content:center;padding:11px;">
                Verify OTP
            </button>
        </form>

        <div style="margin-top:16px;text-align:center;">
            <a href="<%= request.getContextPath() %>/forgot-password" style="font-size:13px;color:var(--muted);text-decoration:none;">Resend OTP</a>
        </div>
    </div>
</div>
<script src="<%= request.getContextPath() %>/js/script.js"></script>
</body>
</html>
