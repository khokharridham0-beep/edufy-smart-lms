<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password — Edufy</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="login-page">
    <div class="login-bg"></div>
    <div class="login-box">
        <div class="login-logo">🔐</div>
        <h1>Forgot Password</h1>
        <p>Enter your registered email to receive OTP.</p>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <div class="alert alert-danger" data-auto-dismiss><%= error %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/forgot-password" method="post">
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" class="form-control" placeholder="Enter your registered email" required>
            </div>
            <button type="submit" class="btn btn-teal w-100" style="justify-content:center;padding:11px;">
                Send OTP
            </button>
        </form>

        <div style="margin-top:16px;text-align:center;">
            <a href="<%= request.getContextPath() %>/login" style="font-size:13px;color:var(--muted);text-decoration:none;">← Back to login</a>
        </div>
    </div>
</div>
<script src="<%= request.getContextPath() %>/js/script.js"></script>
</body>
</html>
