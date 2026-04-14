<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "Teacher Dashboard");
    List<Subject>     subjects     = (List<Subject>)     request.getAttribute("subjects");
    List<Assignment> assignments = (List<Assignment>) request.getAttribute("assignments");
    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    User teacher = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<div class="layout">
    <!-- Teacher Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon">🤖</div>
            <h2>Edufy</h2>
            <span>Teacher Portal</span>
        </div>
        <div class="sidebar-user">
            <div class="user-avatar" style="background:linear-gradient(135deg,var(--amber),var(--rose));"><%= teacher.getName().charAt(0) %></div>
            <div class="user-info"><div class="user-name"><%= teacher.getName() %></div><div class="user-role">Teacher</div></div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-label">Overview</div>
            <a href="<%= ctx %>/teacher/dashboard" class="nav-item active"><span class="nav-icon">🏠</span> Dashboard</a>
            <div class="nav-label">Teaching</div>
            <a href="<%= ctx %>/teacher/subjects"   class="nav-item"><span class="nav-icon">📘</span> My Subjects</a>
            <a href="<%= ctx %>/teacher/assignments" class="nav-item"><span class="nav-icon">📝</span> Assignments</a>
            <a href="<%= ctx %>/teacher/submissions" class="nav-item"><span class="nav-icon">📥</span> Submissions</a>
            <a href="<%= ctx %>/teacher/marks"     class="nav-item"><span class="nav-icon">🏅</span> Marks</a>
            <div class="nav-label">Account</div>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon teal">📘</div>
                    <div class="stat-info">
                        <div class="stat-value"><%= subjects != null ? subjects.size() : 0 %></div>
                        <div class="stat-label">My Subjects</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber">📝</div>
                    <div class="stat-info">
                        <div class="stat-value"><%= assignments != null ? assignments.size() : 0 %></div>
                        <div class="stat-label">Assignments Created</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green">🤖</div>
                    <div class="stat-info"><div class="stat-value">Auto</div><div class="stat-label">Keyword Evaluation</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon rose">🔍</div>
                    <div class="stat-info"><div class="stat-value">AI</div><div class="stat-label">Plagiarism Detection</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon teal">❓</div>
                    <div class="stat-info">
                        <div class="stat-value"><%= quizzes != null ? quizzes.size() : 0 %></div>
                        <div class="stat-label">Quizzes Created</div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header"><h3>⚡ Quick Actions</h3></div>
                <div class="card-body d-flex gap-12" style="flex-wrap:wrap;">
                    <a href="<%= ctx %>/teacher/uploadAssignment" class="btn btn-teal">+ Upload Assignment</a>
                    <a href="<%= ctx %>/teacher/quizzes" class="btn btn-amber">+ Create Quiz</a>
                    <a href="<%= ctx %>/teacher/submissions" class="btn btn-ghost">📥 View Submissions</a>
                    <a href="<%= ctx %>/teacher/marks" class="btn btn-ghost">🏅 View Marks</a>
                </div>
            </div>

            <!-- My Subjects -->
            <div class="card">
                <div class="card-header"><h3>📘 My Subjects</h3></div>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Subject</th><th>Description</th><th>Actions</th></tr></thead>
                        <tbody>
                        <% if (subjects != null && !subjects.isEmpty()) { for (Subject c : subjects) { %>
                            <tr>
                                <td class="fw-700"><%= c.getName() %></td>
                                <td class="text-muted" style="font-size:13px;"><%= c.getDescription() != null ? c.getDescription() : "—" %></td>
                                <td><a href="<%= ctx %>/teacher/assignments" class="btn btn-ghost btn-sm">View Assignments</a></td>
                            </tr>
                        <% } } else { %><tr><td colspan="3" style="text-align:center;padding:30px;color:var(--muted);">No subjects assigned yet.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body></html>


