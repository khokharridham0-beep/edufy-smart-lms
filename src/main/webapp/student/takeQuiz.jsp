<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "Take Quiz");
    Quiz quiz = (Quiz) request.getAttribute("quiz");
    List<QuizQuestion> questions = (List<QuizQuestion>) request.getAttribute("questions");
    Integer remainingSeconds = (Integer) request.getAttribute("remainingSeconds");
    if (remainingSeconds == null) remainingSeconds = 0;
    User student = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Take Quiz</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        .quiz-grid { display:grid; grid-template-columns: 1fr 280px; gap:16px; }
        .sticky-box { position: sticky; top: 80px; }
        .timer-box { font-size: 26px; font-weight: 800; font-family: var(--font-head); }
        .mcq-box { margin-bottom: 12px; }
        .option-row { display:flex; gap:8px; align-items:flex-start; margin:6px 0; }
        .option-row input { margin-top: 4px; }
        @media (max-width: 920px) {
            .quiz-grid { grid-template-columns: 1fr; }
            .sticky-box { position: static; }
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
            <a href="<%= ctx %>/student/dashboard" class="nav-item"><span class="nav-icon">🏠</span> Dashboard</a>
            <a href="<%= ctx %>/student/results" class="nav-item"><span class="nav-icon">🏅</span> My Results</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>❓ <%= quiz != null ? quiz.getTitle() : "Quiz" %></h1>
                    <p><%= quiz != null && quiz.getDescription() != null ? quiz.getDescription() : "Answer all questions within the timer." %></p>
                </div>
            </div>

            <form action="<%= ctx %>/quiz/submit" method="post" id="quizSubmitForm">
                <input type="hidden" name="quizId" value="<%= quiz != null ? quiz.getId() : 0 %>">
                <input type="hidden" id="remainingSeconds" value="<%= remainingSeconds %>">
                <div class="quiz-grid">
                    <div>
                        <% if (questions != null) {
                            int i = 1;
                            for (QuizQuestion q : questions) { %>
                        <div class="card mcq-box question-block">
                            <div class="card-header"><h3>Q<%= i++ %>. <%= q.getQuestionText() %></h3></div>
                            <div class="card-body">
                                <label class="option-row"><input type="radio" name="q_<%= q.getId() %>" value="A"> <span>A. <%= q.getOptionA() %></span></label>
                                <label class="option-row"><input type="radio" name="q_<%= q.getId() %>" value="B"> <span>B. <%= q.getOptionB() %></span></label>
                                <label class="option-row"><input type="radio" name="q_<%= q.getId() %>" value="C"> <span>C. <%= q.getOptionC() %></span></label>
                                <label class="option-row"><input type="radio" name="q_<%= q.getId() %>" value="D"> <span>D. <%= q.getOptionD() %></span></label>
                                <div style="font-size:12px;color:var(--muted);margin-top:6px;">Marks: <%= q.getMarks() %></div>
                            </div>
                        </div>
                        <% } } %>
                        <button type="submit" class="btn btn-teal" id="finalSubmitBtn">Submit Quiz</button>
                    </div>

                    <div class="sticky-box">
                        <div class="card">
                            <div class="card-header"><h3>⏱ Countdown</h3></div>
                            <div class="card-body">
                                <div class="timer-box" id="timerBox">00:00</div>
                                <div style="font-size:12px;color:var(--muted);margin-top:6px;">Time runs from first click/start.</div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header"><h3>📊 Progress</h3></div>
                            <div class="card-body">
                                <div id="fillInfo" class="fw-700">Filled 0 of 0 MCQ</div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
(function() {
    let remaining = parseInt(document.getElementById('remainingSeconds').value || '0', 10);
  const form = document.getElementById('quizSubmitForm');
  const timerBox = document.getElementById('timerBox');
  const fillInfo = document.getElementById('fillInfo');

  function pad(n) { return (n < 10 ? '0' : '') + n; }
  function renderTimer() {
    const mm = Math.floor(remaining / 60);
    const ss = remaining % 60;
    timerBox.textContent = pad(mm) + ':' + pad(ss);
    if (remaining <= 60) timerBox.style.color = 'var(--rose)';
  }

  function updateProgress() {
    const blocks = document.querySelectorAll('.question-block');
    const total = blocks.length;
    let filled = 0;
    blocks.forEach(block => {
      if (block.querySelector('input[type="radio"]:checked')) filled++;
    });
    fillInfo.textContent = 'Filled ' + filled + ' of ' + total + ' MCQ';
  }

  document.querySelectorAll('input[type="radio"]').forEach(el => {
    el.addEventListener('change', updateProgress);
  });
  updateProgress();
  renderTimer();

  const t = setInterval(() => {
    remaining--;
    renderTimer();
    if (remaining <= 0) {
      clearInterval(t);
      form.submit();
    }
  }, 1000);
})();
</script>
</body>
</html>
