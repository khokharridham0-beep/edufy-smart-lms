<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*, model.Module" %>
<%
    request.setAttribute("pageTitle", "My Subject");
    Subject       subject  = (Subject)       request.getAttribute("subject");
    List<Module> modules = (List<Module>) request.getAttribute("modules");
    User student = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Subject — Student</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="sidebar-brand"><div class="brand-icon">🤖</div><h2>Edufy</h2><span>Student Portal</span></div>
        <div class="sidebar-user">
            <div class="user-avatar" style="background:linear-gradient(135deg,var(--teal),#0090cc);"><%= student.getName().charAt(0) %></div>
            <div class="user-info"><div class="user-name"><%= student.getName() %></div><div class="user-role">Student</div></div>
        </div>
        <nav class="sidebar-nav">
            <a href="<%= ctx %>/student/dashboard"     class="nav-item"><span class="nav-icon">🏠</span> Dashboard</a>
            <a href="<%= ctx %>/student/subjectDetails" class="nav-item active"><span class="nav-icon">📘</span> My Subject</a>
            <a href="<%= ctx %>/student/results"       class="nav-item"><span class="nav-icon">🏅</span> My Results</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>
    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">
            <% if (subject != null) { %>
            <div class="page-header">
                <div><h1>📘 <%= subject.getName() %></h1><p><%= subject.getDescription() != null ? subject.getDescription() : "" %></p></div>
                <a href="<%= ctx %>/student/subjectDetails" class="btn btn-teal">View Full Details →</a>
            </div>
            <div class="stats-grid">
                <div class="stat-card"><div class="stat-icon teal">📂</div><div class="stat-info"><div class="stat-value"><%= modules!=null?modules.size():0 %></div><div class="stat-label">Modules</div></div></div>
            </div>
            <% if (modules != null) { for (Module m : modules) { %>
            <div class="module-card">
                <div class="module-header"><h4>📂 <%= m.getModuleName() %></h4></div>
                <div class="module-body"><div class="assignment-row"><span class="text-muted" style="font-size:13px;"><%= m.getDescription()!=null?m.getDescription():"No description." %></span></div></div>
            </div>
            <% } } %>
            <% } else { %>
            <div class="card"><div class="card-body" style="text-align:center;padding:40px;color:var(--muted);">Not enrolled in any subject. Contact admin.</div></div>
            <% } %>
        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body>
</html>̥