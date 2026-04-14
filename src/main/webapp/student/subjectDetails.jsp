<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, java.util.Map, model.*, model.Module" %>
<%
    request.setAttribute("pageTitle", "Subject Details");
    Subject       subject   = (Subject)      request.getAttribute("subject");
    List<Module> modules  = (List<Module>) request.getAttribute("modules");
    Map<Integer, List<Assignment>> modAssMap = (Map<Integer, List<Assignment>>) request.getAttribute("moduleAssignmentsMap");
    Map<Integer, List<Quiz>> moduleQuizMap = (Map<Integer, List<Quiz>>) request.getAttribute("moduleQuizMap");
    Map<Integer, Submission> subMap   = (Map<Integer, Submission>) request.getAttribute("submissionMap");
    Map<Integer, Marks>      marksMap = (Map<Integer, Marks>)      request.getAttribute("marksMap");
    Map<Integer, QuizAttempt> quizAttemptMap = (Map<Integer, QuizAttempt>) request.getAttribute("quizAttemptMap");
    String quizMsg = (String) request.getAttribute("quizMsg");
    User student = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subject Details — Student</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        .question-box {
            background: var(--navy-mid);
            border-left: 3px solid var(--teal);
            border-radius: 0 8px 8px 0;
            padding: 10px 14px;
            font-size: 13px;
            margin: 8px 0;
            color: var(--text);
        }
        .keywords-row { margin: 6px 0; font-size: 12px; }
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
            <a href="<%= ctx %>/student/subjectDetails" class="nav-item active"><span class="nav-icon">📘</span> My Subject</a>
            <a href="<%= ctx %>/student/results"       class="nav-item"><span class="nav-icon">🏅</span> My Results</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">

            <% if (quizMsg != null && !quizMsg.isEmpty()) { %>
            <div class="alert alert-success" data-auto-dismiss><%= quizMsg %></div>
            <% } %>

            <!-- Subject Banner -->
            <% if (subject != null) { %>
            <div style="background:linear-gradient(135deg,#162032,#1e3a5f);border:1px solid rgba(0,212,200,.2);border-radius:var(--radius);padding:22px 26px;margin-bottom:24px;">
                <div class="d-flex align-center gap-12">
                    <div style="width:48px;height:48px;background:linear-gradient(135deg,var(--teal),#0090cc);border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:22px;">📘</div>
                    <div>
                        <h1 style="font-family:var(--font-head);font-size:20px;font-weight:800;"><%= subject.getName() %></h1>
                        <p style="color:var(--muted);font-size:13px;margin-top:4px;"><%= subject.getDescription() != null ? subject.getDescription() : "" %></p>
                    </div>
                </div>
            </div>

            <!-- Modules and Assignments — Hierarchical View -->
            <% if (modules != null && !modules.isEmpty()) {
                java.util.Map<String, List<Module>> chapterMap = new java.util.LinkedHashMap<>();
                for (Module mod : modules) {
                    String chName = mod.getChapterName();
                    if (chName == null || chName.trim().isEmpty()) chName = "General Reference (No Chapter)";
                    chapterMap.computeIfAbsent(chName, k -> new java.util.ArrayList<>()).add(mod);
                }
                
                for (java.util.Map.Entry<String, List<Module>> chapterEntry : chapterMap.entrySet()) {
                    String currentChapter = chapterEntry.getKey();
                    List<Module> chapterModules = chapterEntry.getValue();
            %>
            <div class="chapter-group" style="margin-bottom:32px;">
                <h3 style="margin-bottom:16px; border-bottom:1px solid var(--border); padding-bottom:8px; font-weight:800; color:var(--teal);">🔖 <%= currentChapter %></h3>

                <% for (Module mod : chapterModules) {
                    List<Assignment> modAssignments = modAssMap != null ? modAssMap.get(mod.getId()) : null;
                    int aCount = modAssignments != null ? modAssignments.size() : 0;
                %>
                <div class="module-card" style="margin-bottom:20px; margin-left: 12px;">
                    <div class="module-header" data-toggle="true">
                        <h4>
                            <span class="toggle-icon">▾</span>
                            📂 <%= mod.getModuleName() %>
                            <span class="badge badge-muted" style="margin-left:6px;"><%= aCount %> assignment<%= aCount!=1?"s":"" %></span>
                        </h4>
                        <span style="font-size:12px;color:var(--muted);"><%= mod.getDescription()!=null?mod.getDescription():"" %></span>
                    </div>
                    <div class="module-body">
                        <% List<Quiz> moduleQuizzes = moduleQuizMap != null ? moduleQuizMap.get(mod.getId()) : null;
                           if (moduleQuizzes != null && !moduleQuizzes.isEmpty()) { %>
                        <div style="padding:12px 20px 4px 28px; border-bottom:1px solid var(--border);">
                            <div style="font-weight:700; margin-bottom:8px;">❓ Module Quizzes</div>
                            <% for (Quiz qz : moduleQuizzes) {
                                QuizAttempt qa = quizAttemptMap != null ? quizAttemptMap.get(qz.getId()) : null;
                                boolean attempted = qa != null && (qa.getAnsweredCount() > 0 || qa.isAutoSubmitted() || qa.getScore() > 0);
                            %>
                            <div class="d-flex align-center gap-12" style="flex-wrap:wrap; margin-bottom:10px; padding:10px; border:1px solid var(--border); border-radius:8px; background:rgba(255,255,255,.02);">
                                <div style="flex:1; min-width:220px;">
                                    <div class="fw-700"><%= qz.getTitle() %></div>
                                    <div class="text-muted" style="font-size:12px;"><%= qz.getQuestionCount() %> MCQ | <%= qz.getDurationMinutes() %> min</div>
                                </div>
                                <% if (attempted) { %>
                                    <span class="badge <%= qa.isAutoSubmitted() ? "badge-rose" : "badge-green" %>">
                                        <%= qa.isAutoSubmitted() ? "Time Over" : "Submitted" %>
                                    </span>
                                    <span class="badge badge-teal">Score: <%= qa.getScore() %>/<%= qa.getMaxScore() %></span>
                                    <span class="badge badge-muted">Filled: <%= qa.getAnsweredCount() %>/<%= qa.getTotalQuestions() %></span>
                                <% } else { %>
                                    <a href="<%= ctx %>/quiz/start?quizId=<%= qz.getId() %>" class="btn btn-amber btn-sm">Start Quiz</a>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                        <% } %>

                        <% if (modAssignments != null && !modAssignments.isEmpty()) {
                            for (Assignment a : modAssignments) {
                                Submission sub  = subMap   != null ? subMap.get(a.getId())   : null;
                                Marks      mark = marksMap != null ? marksMap.get(a.getId()) : null;
                                boolean done = sub != null;
                        %>
                        <div style="padding:16px 20px 16px 28px;border-bottom:1px solid var(--border);">
                            <!-- Assignment Header -->
                            <div class="d-flex align-center gap-12" style="flex-wrap:wrap;margin-bottom:8px;">
                                <div style="flex:1;">
                                    <div style="font-weight:700;font-size:15px;">📄 <%= a.getTitle() %></div>
                                </div>
                                <span class="badge badge-amber"><%= a.getMaxMarks() %> marks</span>
                                <% if (done) {
                                    String st = sub.getStatus();
                                    String bc = "EVALUATED".equals(st)?"badge-green":"COPIED".equals(st)||"REJECTED".equals(st)?"badge-rose":"badge-amber";
                                %>
                                    <span class="badge <%= bc %>"><%= st %></span>
                                    <% if (mark != null) { %>
                                    <span class="badge badge-teal fw-700">Score: <%= mark.getMarksObtained() %>/<%= mark.getMaxMarks() %></span>
                                    <% } %>
                                <% } else { %>
                                    <a href="<%= ctx %>/student/submitAssignment?assignmentId=<%= a.getId() %>" class="btn btn-teal btn-sm">📤 Submit</a>
                                <% } %>
                            </div>

                            <!-- Question -->
                            <div class="question-box"><strong>Question:</strong> <%= a.getQuestion() %></div>

                            <!-- Evaluation result if submitted -->
                            <% if (done && mark != null) { %>
                            <div style="margin-top:10px;padding:12px 14px;background:rgba(0,212,200,.05);border-radius:8px;border:1px solid rgba(0,212,200,.1);">
                                <div class="d-flex gap-12 align-center" style="flex-wrap:wrap;margin-bottom:8px;">
                                    <span style="font-size:12px;font-weight:600;color:var(--muted);">MARKS:</span>
                                    <span class="fw-700 text-teal" style="font-size:18px;"><%= mark.getMarksObtained() %> / <%= mark.getMaxMarks() %></span>
                                    <% int pct = mark.getMaxMarks()>0 ? mark.getMarksObtained()*100/mark.getMaxMarks():0; %>
                                    <div class="progress-bar-outer" style="width:120px;">
                                        <div class="progress-bar-fill" style="width:<%= pct %>%;"></div>
                                    </div>
                                    <span class="badge <%= pct>=70?"badge-green":pct>=40?"badge-amber":"badge-rose" %>"><%= pct %>%</span>
                                </div>
                                <% if (mark.getMatchedKeywords()!=null && !mark.getMatchedKeywords().isEmpty() && !"PLAGIARISM DETECTED".equals(mark.getMatchedKeywords())) { %>
                                <div class="keywords-row">
                                    <span style="font-size:12px;color:var(--muted);">Matched Keywords: </span>
                                    <% for (String kw : mark.getMatchedKeywords().split(",")) { %>
                                    <span class="badge badge-teal" style="margin:1px;font-size:10px;"><%= kw.trim() %></span>
                                    <% } %>
                                </div>
                                <% } %>
                                <% if (mark.getPlagiarismScore() > 0) { %>
                                <div style="font-size:12px;color:var(--muted);margin-top:4px;">
                                    Similarity: <span class="badge <%= mark.getPlagiarismScore()>=80?"badge-rose":mark.getPlagiarismScore()>=50?"badge-amber":"badge-green" %>"><%= mark.getPlagiarismScore() %>%</span>
                                </div>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                        <% } } else { %>
                        <div class="assignment-row"><span class="text-muted">No assignments in this module.</span></div>
                        <% } %>
                    </div>
                </div>
                <% } // End module loop %>
            </div>
            <% } // End chapter loop
             } else { %>
            <div class="card"><div class="card-body" style="text-align:center;padding:30px;color:var(--muted);">No modules yet.</div></div>
            <% } %>
            <% } else { %>
            <div class="card"><div class="card-body" style="text-align:center;padding:40px;color:var(--muted);">Not enrolled in any subject.</div></div>
            <% } %>

        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body>
</html>


