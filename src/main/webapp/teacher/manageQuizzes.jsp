<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, model.*, model.Module" %>
<%
    request.setAttribute("pageTitle", "Manage Quizzes");
    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    List<Module> modules = (List<Module>) request.getAttribute("modules");
    List<QuizAttempt> quizAttempts = (List<QuizAttempt>) request.getAttribute("quizAttempts");
    Quiz selectedQuiz = (Quiz) request.getAttribute("selectedQuiz");
    String msg = request.getParameter("msg");
    User teacher = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quizzes - Teacher Portal</title>
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
            <a href="<%= ctx %>/teacher/dashboard" class="nav-item"><span class="nav-icon">🏠</span> Dashboard</a>
            <a href="<%= ctx %>/teacher/subjects" class="nav-item"><span class="nav-icon">📘</span> My Subjects</a>
            <a href="<%= ctx %>/teacher/assignments" class="nav-item"><span class="nav-icon">📝</span> Assignments</a>
            <a href="<%= ctx %>/teacher/quizzes" class="nav-item active"><span class="nav-icon">❓</span> Quizzes</a>
            <a href="<%= ctx %>/teacher/submissions" class="nav-item"><span class="nav-icon">📥</span> Submissions</a>
            <a href="<%= ctx %>/teacher/marks" class="nav-item"><span class="nav-icon">🏅</span> Marks</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">
            <% if (msg != null) { %>
            <div class="alert <%= "added".equals(msg) ? "alert-success" : "alert-danger" %>" data-auto-dismiss>
                <%= "added".equals(msg) ? "✅ Quiz created successfully." :
                    "deleted".equals(msg) ? "✅ Quiz deleted successfully." :
                    "no_questions".equals(msg) ? "⚠ Add at least one complete MCQ." :
                    "forbidden_module".equals(msg) ? "⚠ Selected module is not allowed." :
                    "invalid_module".equals(msg) ? "⚠ Invalid module selected." :
                    "❌ Could not process quiz request." %>
            </div>
            <% } %>

            <div class="page-header">
                <div>
                    <h1>❓ Module Quizzes</h1>
                    <p>Create timed MCQ quizzes with answer key for automatic marks</p>
                </div>
                <button class="btn btn-teal" onclick="openModal('addQuizModal')">+ New Quiz</button>
            </div>

            <div class="card">
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Title</th><th>Module</th><th>Subject</th><th>Duration</th><th>Questions</th><th>Actions</th></tr></thead>
                        <tbody>
                        <% if (quizzes != null && !quizzes.isEmpty()) { for (Quiz q : quizzes) { %>
                            <tr>
                                <td class="fw-700"><%= q.getTitle() %></td>
                                <td><span class="badge badge-muted"><%= q.getModuleName() %></span></td>
                                <td class="text-muted"><%= q.getSubjectName() %></td>
                                <td><span class="badge badge-amber"><%= q.getDurationMinutes() %> min</span></td>
                                <td><span class="badge badge-teal"><%= q.getQuestionCount() %> MCQ</span></td>
                                <td>
                                    <a href="<%= ctx %>/teacher/quizzes?quizId=<%= q.getId() %>" class="btn btn-ghost btn-sm">📊 Results</a>
                                    <button class="btn btn-rose btn-sm" onclick="confirmDelete('<%= ctx %>/teacher/deleteQuiz?id=<%= q.getId() %>', '<%= q.getTitle() %>')">🗑</button>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="6" style="text-align:center;padding:30px;color:var(--muted);">No quizzes yet. Create one now.</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <% if (selectedQuiz != null) { %>
            <div class="card" style="margin-top:16px;">
                <div class="card-header">
                    <h3>📊 Quiz Results — <%= selectedQuiz.getTitle() %></h3>
                    <span class="badge badge-muted"><%= quizAttempts != null ? quizAttempts.size() : 0 %> attempts</span>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr><th>#</th><th>Student</th><th>Score</th><th>Answered</th><th>Time Taken</th><th>Status</th><th>Submitted At</th></tr>
                        </thead>
                        <tbody>
                        <% if (quizAttempts != null && !quizAttempts.isEmpty()) {
                               int i = 1;
                               for (QuizAttempt at : quizAttempts) {
                                   int pct = at.getMaxScore() > 0 ? (at.getScore() * 100 / at.getMaxScore()) : 0;
                                   String scoreCls = pct >= 70 ? "badge-green" : pct >= 40 ? "badge-amber" : "badge-rose";
                        %>
                        <tr>
                            <td class="text-muted"><%= i++ %></td>
                            <td class="fw-700"><%= at.getStudentName() != null ? at.getStudentName() : ("Student #" + at.getStudentId()) %></td>
                            <td>
                                <span class="fw-700 text-teal"><%= at.getScore() %>/<%= at.getMaxScore() %></span>
                                <span class="badge <%= scoreCls %>" style="margin-left:6px;"><%= pct %>%</span>
                            </td>
                            <td><span class="badge badge-muted"><%= at.getAnsweredCount() %>/<%= at.getTotalQuestions() %></span></td>
                            <td>
                                <% int timeSec = at.getTimeTakenSeconds();
                                   if (timeSec < 0) timeSec = 0;
                                   int mm = timeSec / 60;
                                   int ss = timeSec % 60;
                                   String timeText = mm + "m " + ss + "s";
                                %>
                                <span class="badge badge-amber"><%= timeText %></span>
                            </td>
                            <td>
                                <% if (at.isAutoSubmitted()) { %>
                                <span class="badge badge-rose">Time Over</span>
                                <% } else { %>
                                <span class="badge badge-green">Submitted</span>
                                <% } %>
                            </td>
                            <td class="text-muted" style="font-size:12px;"><%= at.getSubmittedAt() %></td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="7" style="text-align:center;padding:24px;color:var(--muted);">No student has submitted this quiz yet.</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<div class="modal-overlay" id="addQuizModal">
    <div class="modal" style="max-width:860px;">
        <div class="modal-header"><h4>+ Create New Quiz</h4><button class="modal-close" onclick="closeModal('addQuizModal')">✕</button></div>
        <form action="<%= ctx %>/teacher/addQuiz" method="post" id="quizForm">
            <div class="modal-body">
                <div class="form-grid-2">
                    <div class="form-group">
                        <label class="form-label">Module</label>
                        <select name="module_id" class="form-control" required>
                            <option value="">-- Select Module --</option>
                            <% if (modules != null) for (Module m : modules) { %>
                            <option value="<%= m.getId() %>"><%= m.getModuleName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Time Limit (minutes)</label>
                        <input name="duration_minutes" type="number" class="form-control" min="1" max="180" value="10" required>
                    </div>
                </div>

                <div class="form-group"><label class="form-label">Quiz Title</label><input name="title" class="form-control" required></div>
                <div class="form-group"><label class="form-label">Description</label><textarea name="description" class="form-control" rows="2"></textarea></div>

                <div class="card" style="margin-top:10px;">
                    <div class="card-header">
                        <h3>MCQ Questions</h3>
                        <button type="button" class="btn btn-ghost btn-sm" onclick="addQuestionRow()">+ Add Question</button>
                    </div>
                    <div class="card-body" id="questionContainer"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addQuizModal')">Cancel</button>
                <button type="submit" class="btn btn-teal">Create Quiz</button>
            </div>
        </form>
    </div>
</div>

<script src="<%= ctx %>/js/script.js"></script>
<script>
let qIdx = 0;

function questionTemplate(index) {
  return `
    <div class="card" style="margin-bottom:12px;border:1px solid var(--border);">
      <div class="card-header">
        <h3>Question ${index + 1}</h3>
        <button type="button" class="btn btn-rose btn-sm" onclick="this.closest('.card').remove(); renumberQuestions();">Remove</button>
      </div>
      <div class="card-body">
        <div class="form-group">
          <label class="form-label">Question</label>
          <textarea name="question_text" class="form-control" rows="2" required></textarea>
        </div>
        <div class="form-grid-2">
          <div class="form-group"><label class="form-label">Option A</label><input name="option_a" class="form-control" required></div>
          <div class="form-group"><label class="form-label">Option B</label><input name="option_b" class="form-control" required></div>
          <div class="form-group"><label class="form-label">Option C</label><input name="option_c" class="form-control" required></div>
          <div class="form-group"><label class="form-label">Option D</label><input name="option_d" class="form-control" required></div>
        </div>
        <div class="form-grid-2">
          <div class="form-group">
            <label class="form-label">Correct Answer</label>
            <select name="correct_option" class="form-control" required>
              <option value="A">A</option>
              <option value="B">B</option>
              <option value="C">C</option>
              <option value="D">D</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Marks</label>
            <input type="number" name="marks" class="form-control" value="1" min="1" max="100" required>
          </div>
        </div>
      </div>
    </div>
  `;
}

function addQuestionRow() {
  const box = document.getElementById('questionContainer');
  box.insertAdjacentHTML('beforeend', questionTemplate(qIdx));
  qIdx++;
}

function renumberQuestions() {
  const cards = document.querySelectorAll('#questionContainer .card .card-header h3');
  cards.forEach((h, i) => h.textContent = 'Question ' + (i + 1));
  qIdx = cards.length;
}

addQuestionRow();
addQuestionRow();
</script>
</body>
</html>
