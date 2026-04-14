<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "View Submissions");
    List<Submission> submissions = (List<Submission>) request.getAttribute("submissions");
    List<Assignment> assignments = (List<Assignment>) request.getAttribute("assignments");
    Assignment selAssignment = (Assignment) request.getAttribute("assignment");
    User teacher = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submissions</title>
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
            <a href="<%= ctx %>/teacher/subjects"     class="nav-item"><span class="nav-icon">📘</span> My Subjects</a>
            <a href="<%= ctx %>/teacher/assignments" class="nav-item"><span class="nav-icon">📝</span> Assignments</a>
            <a href="<%= ctx %>/teacher/submissions" class="nav-item active"><span class="nav-icon">📥</span> Submissions</a>
            <a href="<%= ctx %>/teacher/marks"       class="nav-item"><span class="nav-icon">🏅</span> Marks</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">
            <div class="page-header">
                <div><h1>📥 Submissions</h1><p>Student submissions for your assignments</p></div>
            </div>

            <!-- Filter by assignment -->
            <div class="card">
                <div class="card-body">
                    <form method="get" action="<%= ctx %>/teacher/submissions" class="d-flex align-center gap-12" style="flex-wrap:wrap;">
                        <select name="assignmentId" class="form-control" style="max-width:340px;">
                            <option value="">-- Select Assignment --</option>
                            <% if (assignments != null) for (Assignment a : assignments) { %>
                            <option value="<%= a.getId() %>" <%= (selAssignment != null && selAssignment.getId() == a.getId()) ? "selected" : "" %>><%= a.getTitle() %> (<%= a.getSubjectName() %>)</option>
                            <% } %>
                        </select>
                        <button type="submit" class="btn btn-teal">🔍 View Submissions</button>
                    </form>
                </div>
            </div>

            <% if (submissions != null) { %>
            <div class="card">
                <div class="card-header">
                    <h3>📋 Submissions
                    <% if (selAssignment != null) { %> — <%= selAssignment.getTitle() %><% } %>
                    </h3>
                    <span class="badge badge-teal"><%= submissions.size() %> total</span>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>#</th><th>Student</th><th>Submitted At</th><th>Status</th><th>File</th><th>Content Preview</th></tr></thead>
                        <tbody>
                        <% if (!submissions.isEmpty()) { int i=1; for (Submission sub : submissions) { %>
                            <tr>
                                <td class="text-muted"><%= i++ %></td>
                                <td>
                                    <div class="d-flex align-center gap-8">
                                        <div class="user-avatar" style="width:30px;height:30px;font-size:11px;"><%= sub.getStudentName() != null ? sub.getStudentName().charAt(0) : "?" %></div>
                                        <%= sub.getStudentName() %>
                                    </div>
                                </td>
                                <td class="text-muted" style="font-size:12px;"><%= sub.getSubmittedAt() %></td>
                                <td>
                                    <% String st = sub.getStatus();
                                       String cls = "EVALUATED".equals(st) ? "badge-green" : "COPIED".equals(st) || "REJECTED".equals(st) ? "badge-rose" : "badge-amber"; %>
                                    <span class="badge <%= cls %>"><%= st %></span>
                                </td>
                                <td>
                                    <% if (sub.getFilePath() != null && !sub.getFilePath().isEmpty()) { %>
                                    <a href="<%= ctx %>/<%= sub.getFilePath() %>" target="_blank" class="btn btn-ghost btn-sm">📎 Download</a>
                                    <% } else { %><span class="text-muted">No file</span><% } %>
                                </td>
                                <td style="font-size:12px;color:var(--muted);max-width:200px;overflow:hidden;">
                                    <% if (sub.getTextContent() != null && !sub.getTextContent().isEmpty()) {
                                        String preview = sub.getTextContent().length() > 80 ? sub.getTextContent().substring(0, 80) + "..." : sub.getTextContent(); %>
                                        <%= preview %>
                                    <% } else { %>—<% } %>
                                </td>
                            </tr>
                        <% } } else { %><tr><td colspan="6" style="text-align:center;padding:30px;color:var(--muted);">No submissions yet for this assignment.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body></html>


