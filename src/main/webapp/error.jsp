<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error — Edufy</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="login-page">
    <div class="login-bg"></div>
    <div style="text-align:center;position:relative;z-index:1;">
        <div style="font-size:72px;margin-bottom:16px;">⚠</div>
        <h1 style="font-family:var(--font-head);font-size:28px;font-weight:800;margin-bottom:8px;">Something went wrong</h1>
        <p style="color:var(--muted);margin-bottom:24px;">
            <% Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code"); %>
            <% if (statusCode != null) { %>Error <%= statusCode %> — <% } %>
            <%= request.getAttribute("javax.servlet.error.message") != null
                ? request.getAttribute("javax.servlet.error.message")
                : "An unexpected error occurred." %>
        </p>
        <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-teal">← Go Home</a>
    </div>
</div>
</body>
</html>


