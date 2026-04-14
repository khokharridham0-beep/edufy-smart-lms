<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "My Subjects");
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
    User teacher = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Subjects — Teacher</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="sidebar-brand"><div class="brand-icon">🤖</div><h2>Edufy</h2><span>Teacher Portal</span></div>
        <div class="sidebar-user">
            <div class="user-avatar" style="background:linear-gradient(135deg,var(--amber),var(--rose));"><%= teacher.getName().charAt(0) %></div>
            <div class="user-info"><div class="user-name"><%= teacher.getName() %></div><div class="user-role">Teacher</div></div>
        </div>
        <nav class="sidebar-nav">
            <a href="<%= ctx %>/teacher/dashboard"   class="nav-item"><span class="nav-icon">🏠</span> Dashboard</a>
            <a href="<%= ctx %>/teacher/subjects"     class="nav-item active"><span class="nav-icon">📘</span> My Subjects</a>
            <a href="<%= ctx %>/teacher/assignments" class="nav-item"><span class="nav-icon">📝</span> Assignments</a>
            <a href="<%= ctx %>/teacher/submissions" class="nav-item"><span class="nav-icon">📥</span> Submissions</a>
            <a href="<%= ctx %>/teacher/marks"       class="nav-item"><span class="nav-icon">🏅</span> Marks</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>
    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">
            <div class="page-header"><div><h1>📘 My Subjects</h1><p>Subjects assigned to you</p></div></div>
            <% if (subjects != null && !subjects.isEmpty()) { for (Subject c : subjects) { %>
            <div class="card" style="margin-bottom:20px;">
                <div class="card-header">
                    <h3>📘 <%= c.getName() %></h3>
                    <a href="<%= ctx %>/teacher/assignments" class="btn btn-teal btn-sm">View Assignments</a>
                </div>
                <div class="card-body">
                    <p class="text-muted"><%= c.getDescription() != null ? c.getDescription() : "No description provided." %></p>
                </div>
            </div>
            <% } } else { %>
            <div class="card"><div class="card-body" style="text-align:center;padding:40px;color:var(--muted);">No subjects assigned yet. Contact admin.</div></div>
            <% } %>
        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body>
</html>


