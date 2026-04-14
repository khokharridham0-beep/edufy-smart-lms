<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "View Marks");
    List<Marks>      marksList   = (List<Marks>)      request.getAttribute("marksList");
    List<Assignment> assignments = (List<Assignment>) request.getAttribute("assignments");
    Assignment selAssignment     = (Assignment)       request.getAttribute("assignment");
    User teacher = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Marks — Teacher Portal</title>
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
            <a href="<%= ctx %>/teacher/submissions" class="nav-item"><span class="nav-icon">📥</span> Submissions</a>
            <a href="<%= ctx %>/teacher/marks"       class="nav-item active"><span class="nav-icon">🏅</span> Marks</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">

            <div class="page-header">
                <div><h1>🏅 Student Marks</h1><p>Auto-evaluated marks based on keyword matching</p></div>
            </div>

            <!-- Filter -->
            <div class="card">
                <div class="card-body">
                    <form method="get" action="<%= ctx %>/teacher/marks" class="d-flex align-center gap-12" style="flex-wrap:wrap;">
                        <select name="assignmentId" class="form-control" style="max-width:360px;">
                            <option value="">-- Select Assignment --</option>
                            <% if (assignments != null) for (Assignment a : assignments) { %>
                            <option value="<%= a.getId() %>" <%= (selAssignment != null && selAssignment.getId() == a.getId()) ? "selected" : "" %>><%= a.getTitle() %> (<%= a.getSubjectName() %>)</option>
                            <% } %>
                        </select>
                        <button type="submit" class="btn btn-teal">🔍 View Marks</button>
                    </form>
                </div>
            </div>

            <% if (marksList != null) { %>
            <!-- Assignment Info -->
            <% if (selAssignment != null) { %>
            <div class="card">
                <div class="card-body d-flex gap-12" style="flex-wrap:wrap;align-items:center;">
                    <div><span class="text-muted" style="font-size:12px;">ASSIGNMENT</span><div class="fw-700"><%= selAssignment.getTitle() %></div></div>
                    <div><span class="text-muted" style="font-size:12px;">MAX MARKS</span><div class="fw-700 text-teal"><%= selAssignment.getMaxMarks() %></div></div>
                    <div><span class="text-muted" style="font-size:12px;">KEYWORDS</span>
                        <div>
                        <% for (String kw : selAssignment.getKeywords().split(",")) { %>
                            <span class="badge badge-amber" style="margin:1px;"><%= kw.trim() %></span>
                        <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>

            <div class="card">
                <div class="card-header">
                    <h3>📊 Marks Report</h3>
                    <span class="badge badge-teal"><%= marksList.size() %> evaluated</span>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr><th>#</th><th>Student</th><th>Marks</th><th>Score %</th><th>Matched Keywords</th><th>Plagiarism</th><th>Evaluated At</th></tr>
                        </thead>
                        <tbody>
                        <% if (!marksList.isEmpty()) {
                            int i = 1;
                            for (Marks mk : marksList) {
                                int pct = mk.getMaxMarks() > 0 ? (mk.getMarksObtained() * 100 / mk.getMaxMarks()) : 0;
                                String scoreClass = pct >= 70 ? "badge-green" : pct >= 40 ? "badge-amber" : "badge-rose";
                        %>
                            <tr>
                                <td class="text-muted"><%= i++ %></td>
                                <td>
                                    <div class="d-flex align-center gap-8">
                                        <div class="user-avatar" style="width:30px;height:30px;font-size:11px;"><%= mk.getStudentName() != null ? mk.getStudentName().charAt(0) : "?" %></div>
                                        <%= mk.getStudentName() %>
                                    </div>
                                </td>
                                <td>
                                    <span class="fw-700 text-teal"><%= mk.getMarksObtained() %></span>
                                    <span class="text-muted">/ <%= mk.getMaxMarks() %></span>
                                </td>
                                <td>
                                    <div class="d-flex align-center gap-8">
                                        <div class="progress-bar-outer" style="width:80px;">
                                            <div class="progress-bar-fill" style="width:<%= pct %>%;"></div>
                                        </div>
                                        <span class="badge <%= scoreClass %>"><%= pct %>%</span>
                                    </div>
                                </td>
                                <td style="font-size:12px;max-width:200px;">
                                    <% if (mk.getMatchedKeywords() != null && !mk.getMatchedKeywords().isEmpty()
                                          && !"PLAGIARISM DETECTED".equals(mk.getMatchedKeywords())) {
                                        for (String kw : mk.getMatchedKeywords().split(",")) { %>
                                        <span class="badge badge-teal" style="margin:1px;font-size:10px;"><%= kw.trim() %></span>
                                    <% } } else if ("PLAGIARISM DETECTED".equals(mk.getMatchedKeywords())) { %>
                                        <span class="badge badge-rose">Plagiarised</span>
                                    <% } else { %><span class="text-muted">None</span><% } %>
                                </td>
                                <td>
                                    <% int ps = mk.getPlagiarismScore(); %>
                                    <span class="badge <%= ps >= 80 ? "badge-rose" : ps >= 50 ? "badge-amber" : "badge-green" %>">
                                        <%= ps %>% similar
                                    </span>
                                </td>
                                <td class="text-muted" style="font-size:12px;"><%= mk.getEvaluatedAt() %></td>
                            </tr>
                        <% } } else { %><tr><td colspan="7" style="text-align:center;padding:30px;color:var(--muted);">No marks available yet.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <% } %>

        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body>
</html>


