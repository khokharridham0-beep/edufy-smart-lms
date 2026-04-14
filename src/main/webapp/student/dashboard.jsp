<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, java.util.Map, model.*, model.Module" %>
<%
    request.setAttribute("pageTitle", "Student Dashboard");
    List<Subject>     subjects       = (List<Subject>)              request.getAttribute("subjects");
    String submitMsg = (String) request.getAttribute("submitMsg");
    User student = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        .welcome-banner {
            background: linear-gradient(135deg, #162032 0%, #1e3a5f 100%);
            border: 1px solid rgba(0,212,200,.2);
            border-radius: var(--radius);
            padding: 24px 28px;
            margin-bottom: 24px;
            position: relative; overflow: hidden;
        }
        .welcome-banner::after {
            content: '🎓';
            position: absolute; right: 24px; top: 50%;
            transform: translateY(-50%);
            font-size: 48px; opacity: .3;
        }
        .welcome-banner h2 { font-family: var(--font-head); font-size: 22px; font-weight: 800; }
        .welcome-banner p  { color: var(--muted); margin-top: 4px; }
    </style>
</head>
<body>
<div class="layout">
    <!-- Student Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-brand"><div class="brand-icon">🤖</div><h2>Edufy</h2><span>Student Portal</span></div>
        <div class="sidebar-user">
            <div class="user-avatar" style="background:linear-gradient(135deg,var(--teal),#0090cc);"><%= student.getName().charAt(0) %></div>
            <div class="user-info"><div class="user-name"><%= student.getName() %></div><div class="user-role">Student</div></div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-label">Overview</div>
            <a href="<%= ctx %>/student/dashboard"     class="nav-item active"><span class="nav-icon">🏠</span> Dashboard</a>
            <div class="nav-label">Academics</div>
            <a href="<%= ctx %>/student/subjectDetails" class="nav-item"><span class="nav-icon">📘</span> My Subject</a>
            <a href="<%= ctx %>/student/results"       class="nav-item"><span class="nav-icon">🏅</span> My Results</a>
            <div class="nav-label">Account</div>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">

            <% if (submitMsg != null) { %>
            <div class="alert <%= submitMsg.startsWith("⚠") ? "alert-warning" : "alert-success" %>" data-auto-dismiss>
                <%= submitMsg %>
            </div>
            <% } %>

            <!-- Welcome Banner -->
            <div class="welcome-banner">
                <h2>Welcome back, <%= student.getName() %>! 👋</h2>
                <p>Explore your subjects and start learning.</p>
            </div>

            <!-- Subject Grid -->
            <div class="page-header" style="margin-top:8px;">
                <div>
                    <h1 style="font-size:18px;">📘 All Subjects</h1>
                    <p>Select a subject to view its modules and assignments</p>
                </div>
            </div>

            <div class="grid-cards" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:24px;">
                <% if (subjects != null && !subjects.isEmpty()) { 
                    for (Subject s : subjects) { %>
                <div class="card" style="transition: transform 0.2s; cursor: pointer;" onclick="window.location.href='<%= ctx %>/student/subjectDetails?subjectId=<%= s.getId() %>'">
                    <div class="card-body">
                        <h3 style="margin-bottom:8px;font-size:18px;color:var(--teal);">📘 <%= s.getName() %></h3>
                        <p class="text-muted" style="font-size:14px;margin-bottom:16px;height:40px;overflow:hidden;text-overflow:ellipsis;"><%= s.getDescription() != null ? s.getDescription() : "No description provided." %></p>
                        <a href="<%= ctx %>/student/subjectDetails?subjectId=<%= s.getId() %>" class="btn btn-ghost btn-sm" style="width:100%;text-align:center;">View Details →</a>
                    </div>
                </div>
                <%    }
                   } else { %>
                <div class="card" style="grid-column: 1 / -1;">
                    <div class="card-body" style="text-align:center;padding:40px;color:var(--muted);">No subjects available yet.</div>
                </div>
                <% } %>
            </div>

        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body>
</html>


