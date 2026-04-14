<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "Admin Dashboard");
    request.setAttribute("activePage", "dashboard");
    int studentCount = (Integer) request.getAttribute("studentCount");
    int teacherCount = (Integer) request.getAttribute("teacherCount");
    int subjectCount  = (Integer) request.getAttribute("subjectCount");
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Edufy</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<div class="layout">
    <%@ include file="../components/sidebar.jsp" %>
    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">

            <!-- Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon teal">👩‍🎓</div>
                    <div class="stat-info">
                        <div class="stat-value"><%= studentCount %></div>
                        <div class="stat-label">Total Students</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber">👨‍🏫</div>
                    <div class="stat-info">
                        <div class="stat-value"><%= teacherCount %></div>
                        <div class="stat-label">Total Teachers</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon rose">📘</div>
                    <div class="stat-info">
                        <div class="stat-value"><%= subjectCount %></div>
                        <div class="stat-label">Total Subjects</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green">🤖</div>
                    <div class="stat-info">
                        <div class="stat-value">AI</div>
                        <div class="stat-label">Auto Evaluation</div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="card">
                <div class="card-header">
                    <h3>⚡ Quick Actions</h3>
                </div>
                <div class="card-body d-flex gap-12" style="flex-wrap:wrap;">
                    <a href="<%= ctx %>/admin/students" class="btn btn-teal">👩‍🎓 Manage Students</a>
                    <a href="<%= ctx %>/admin/teachers" class="btn btn-amber">👨‍🏫 Manage Teachers</a>
                    <a href="<%= ctx %>/admin/subjects"  class="btn btn-ghost">📘 Manage Subjects</a>
                    <a href="<%= ctx %>/admin/modules"  class="btn btn-ghost">📂 Manage Modules</a>
                </div>
            </div>

            <!-- Subjects overview -->
            <div class="card">
                <div class="card-header">
                    <h3>📘 Subjects Overview</h3>
                    <a href="<%= ctx %>/admin/subjects" class="btn btn-ghost btn-sm">View All</a>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr><th>#</th><th>Subject Name</th><th>Description</th><th>Assigned Teacher</th></tr>
                        </thead>
                        <tbody>
                        <% if (subjects != null && !subjects.isEmpty()) {
                            int i = 1;
                            for (Subject c : subjects) { %>
                            <tr>
                                <td class="text-muted"><%= i++ %></td>
                                <td class="fw-700"><%= c.getName() %></td>
                                <td class="text-muted" style="font-size:13px;"><%= c.getDescription() != null ? c.getDescription() : "—" %></td>
                                <td>
                                    <% if (c.getTeacherName() != null && !c.getTeacherName().isEmpty()) { %>
                                        <span class="badge badge-teal">🎓 <%= c.getTeacherName() %></span>
                                    <% } else { %>
                                        <span class="badge badge-muted">Unassigned</span>
                                    <% } %>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="4" style="text-align:center; padding:30px; color:var(--muted);">No subjects yet. <a href="<%= ctx %>/admin/subjects">Add one →</a></td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body>
</html>


