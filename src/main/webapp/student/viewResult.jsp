<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "My Results");
    List<Marks> marksList = (List<Marks>) request.getAttribute("marksList");
    String submitMsg = (String) request.getAttribute("submitMsg");
    User student = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
    int totalMarksObtained = 0, totalMaxMarks = 0;
    if (marksList != null) for (Marks mk : marksList) { totalMarksObtained += mk.getMarksObtained(); totalMaxMarks += mk.getMaxMarks(); }
    int overallPct = totalMaxMarks > 0 ? totalMarksObtained * 100 / totalMaxMarks : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Results — Student</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        .result-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 20px;
            margin-bottom: 16px;
            transition: transform .2s;
        }
        .result-card:hover { transform: translateY(-2px); box-shadow: var(--shadow); }
        .marks-big { font-family: var(--font-head); font-size: 32px; font-weight: 800; line-height: 1; }
        .grade-badge {
            display: inline-flex; align-items: center; justify-content: center;
            width: 52px; height: 52px; border-radius: 50%;
            font-family: var(--font-head); font-size: 20px; font-weight: 800;
        }
    </style>
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
            <a href="<%= ctx %>/student/subjectDetails" class="nav-item"><span class="nav-icon">📘</span> My Subject</a>
            <a href="<%= ctx %>/student/results"       class="nav-item active"><span class="nav-icon">🏅</span> My Results</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">

            <% if (submitMsg != null) { %>
            <div class="alert <%= submitMsg.startsWith("⚠") ? "alert-warning" : "alert-success" %>" data-auto-dismiss><%= submitMsg %></div>
            <% } %>

            <div class="page-header">
                <div><h1>🏅 My Results</h1><p>Auto-evaluated marks from keyword matching</p></div>
            </div>

            <!-- Overall Summary -->
            <% if (marksList != null && !marksList.isEmpty()) { %>
            <div class="card" style="margin-bottom:24px;">
                <div class="card-body" style="display:flex;align-items:center;gap:24px;flex-wrap:wrap;">
                    <% String gradeColor = overallPct>=70?"var(--green)":overallPct>=40?"var(--amber)":"var(--rose)";
                       String grade = overallPct>=90?"A+":overallPct>=80?"A":overallPct>=70?"B":overallPct>=60?"C":overallPct>=40?"D":"F"; %>
                    <div class="grade-badge" style="background:<%= gradeColor %>22;color:<%= gradeColor %>;"><%= grade %></div>
                    <div>
                        <div class="text-muted" style="font-size:12px;">OVERALL SCORE</div>
                        <div class="marks-big text-teal"><%= totalMarksObtained %> <span style="font-size:16px;color:var(--muted);">/ <%= totalMaxMarks %></span></div>
                        <div class="d-flex align-center gap-8" style="margin-top:8px;">
                            <div class="progress-bar-outer" style="width:160px;">
                                <div class="progress-bar-fill" style="width:<%= overallPct %>%;"></div>
                            </div>
                            <span class="badge <%= overallPct>=70?"badge-green":overallPct>=40?"badge-amber":"badge-rose" %>"><%= overallPct %>%</span>
                        </div>
                    </div>
                    <div style="margin-left:auto;">
                        <div class="text-muted" style="font-size:12px;">ASSIGNMENTS</div>
                        <div class="fw-700" style="font-size:24px;font-family:var(--font-head);"><%= marksList.size() %></div>
                    </div>
                </div>
            </div>

            <!-- Individual Results -->
            <% for (Marks mk : marksList) {
                int pct = mk.getMaxMarks()>0 ? mk.getMarksObtained()*100/mk.getMaxMarks() : 0;
                boolean plagiarised = "PLAGIARISM DETECTED".equals(mk.getMatchedKeywords());
            %>
            <div class="result-card">
                <div class="d-flex align-center gap-12" style="flex-wrap:wrap;margin-bottom:12px;">
                    <div style="flex:1;">
                        <div class="fw-700" style="font-size:15px;">📄 <%= mk.getAssignmentTitle() %></div>
                    </div>
                    <% if (plagiarised) { %>
                        <span class="badge badge-rose">⚠ Plagiarised — 0 marks</span>
                    <% } else { %>
                        <span class="marks-big" style="font-size:22px;color:var(--teal);"><%= mk.getMarksObtained() %><span style="font-size:14px;color:var(--muted);">/<%= mk.getMaxMarks() %></span></span>
                        <span class="badge <%= pct>=70?"badge-green":pct>=40?"badge-amber":"badge-rose" %>"><%= pct %>%</span>
                    <% } %>
                </div>

                <% if (!plagiarised) { %>
                <div class="progress-bar-outer" style="margin-bottom:10px;">
                    <div class="progress-bar-fill" style="width:<%= pct %>%;"></div>
                </div>
                <% if (mk.getMatchedKeywords()!=null && !mk.getMatchedKeywords().isEmpty()) { %>
                <div style="font-size:12px;margin-bottom:6px;">
                    <span class="text-muted">Matched Keywords: </span>
                    <% for (String kw : mk.getMatchedKeywords().split(",")) { %>
                        <span class="badge badge-teal" style="margin:1px;font-size:10px;"><%= kw.trim() %></span>
                    <% } %>
                </div>
                <% } %>
                <% } %>

                <div class="d-flex gap-12" style="font-size:12px;color:var(--muted);flex-wrap:wrap;">
                    <span>🔍 Similarity: <span class="badge <%= mk.getPlagiarismScore()>=80?"badge-rose":mk.getPlagiarismScore()>=50?"badge-amber":"badge-green" %>" style="font-size:10px;"><%= mk.getPlagiarismScore() %>%</span></span>
                    <span>🕐 Evaluated: <%= mk.getEvaluatedAt() %></span>
                </div>
            </div>
            <% } %>

            <% } else { %>
            <div class="card"><div class="card-body" style="text-align:center;padding:50px;">
                <div style="font-size:48px;margin-bottom:16px;">📭</div>
                <div class="fw-700" style="font-size:18px;margin-bottom:8px;">No results yet</div>
                <div class="text-muted">Submit your assignments to see marks here.</div>
                <div style="margin-top:20px;"><a href="<%= ctx %>/student/subjectDetails" class="btn btn-teal">View Assignments →</a></div>
            </div></div>
            <% } %>

        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body>
</html>


