<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password — Edufy</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="login-page">
    <div class="login-bg"></div>
    <div class="login-box">
        <div class="login-logo">✅</div>
        <h1>Reset Password</h1>
        <p>Create your new password.</p>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <div class="alert alert-danger" data-auto-dismiss><%= error %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/reset-password" method="post">
            <div class="form-group">
                <label class="form-label">New Password</label>
                <input type="password" name="password" class="form-control" placeholder="Enter new password" required>
            </div>
            <div class="form-group">
                <label class="form-label">Confirm Password</label>
                <input type="password" name="confirm_password" class="form-control" placeholder="Confirm new password" required>
            </div>
            <button type="submit" class="btn btn-teal w-100" style="justify-content:center;padding:11px;">
                Reset Password
            </button>
        </form>
    </div>
</div>
<script src="<%= request.getContextPath() %>/js/script.js"></script>
</body>
</html>
