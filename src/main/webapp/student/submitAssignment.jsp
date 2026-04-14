<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="model.*" %>
<%
    request.setAttribute("pageTitle", "Submit Assignment");
    Assignment assignment = (Assignment) request.getAttribute("assignment");
    User student = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
    String submissionMethod = assignment != null && assignment.getSubmissionMethod() != null
            ? assignment.getSubmissionMethod().trim().toUpperCase()
            : "TEXT";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Assignment — Student</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        .submit-panel { display:none; }
        .submit-panel.active { display:block; }
        .upload-drop {
            border: 2px dashed var(--border);
            border-radius: var(--radius);
            padding: 36px;
            text-align: center;
            cursor: pointer;
            transition: border-color .2s;
        }
        .upload-drop:hover { border-color: var(--teal); }
        .upload-drop input { display:none; }
        .upload-icon { font-size:36px; margin-bottom:8px; }
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
            <a href="<%= ctx %>/student/results"       class="nav-item"><span class="nav-icon">🏅</span> My Results</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>
    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">

            <div class="page-header">
                <div>
                    <h1>📤 Submit Assignment</h1>
                    <% if (assignment != null) { %><p><%= assignment.getTitle() %> — <%= assignment.getSubjectName() %></p><% } %>
                </div>
                <a href="<%= ctx %>/student/subjectDetails" class="btn btn-ghost btn-sm">← Back</a>
            </div>

            <% if (assignment == null) { %>
            <div class="alert alert-danger">Assignment not found.</div>
            <% } else { %>

            <!-- Assignment Info -->
            <div class="card">
                <div class="card-body">
                    <div style="padding:14px;background:var(--navy-mid);border-radius:8px;border-left:3px solid var(--teal);">
                        <div class="fw-700" style="margin-bottom:6px;">📄 <%= assignment.getTitle() %></div>
                        <div style="font-size:14px;color:var(--muted);"><%= assignment.getQuestion() %></div>
                        <div style="margin-top:10px;">
                            <span class="badge badge-amber" style="margin-right:4px;"><%= assignment.getMaxMarks() %> Max Marks</span>
                            <span class="badge badge-muted"><%= assignment.getModuleName() %></span>
                        </div>
                        <div style="margin-top:8px;font-size:12px;color:var(--muted);">
                            💡 <em>Tip: Make sure your answer includes relevant keywords for better marks. Answers are auto-evaluated.</em>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Submission Form -->
            <div class="card">
                <div class="card-header"><h3>📤 Your Submission</h3></div>
                <div class="card-body">
                    <div style="margin-bottom:14px;">
                        <span class="badge badge-teal">Allowed Submission Method: <%= submissionMethod %></span>
                    </div>

                    <form action="<%= ctx %>/submit" method="post" enctype="multipart/form-data" id="submitForm">
                        <input type="hidden" name="assignment_id" value="<%= assignment.getId() %>">
                        <input type="hidden" name="submission_method" value="<%= submissionMethod %>">

                        <% if ("TEXT".equals(submissionMethod)) { %>
                        <!-- Text Panel -->
                        <div class="submit-panel active" id="panel-text">
                            <div class="form-group">
                                <label class="form-label">Type or paste your answer below</label>
                                <textarea name="text_content" id="textContent" class="form-control" rows="10"
                                    placeholder="Write your complete answer here. Include relevant keywords from the assignment question for better evaluation..."></textarea>
                                <div style="font-size:12px;color:var(--muted);margin-top:6px;" id="wordCount">Words: 0</div>
                            </div>
                        </div>
                        <% } %>

                        <% if ("FILE".equals(submissionMethod)) { %>
                        <!-- File Panel -->
                        <div class="submit-panel active" id="panel-file">
                            <div class="form-group">
                                <label class="form-label">Upload PDF, DOCX or TXT file</label>
                                <div class="upload-drop" onclick="document.getElementById('fileInputDoc').click();" id="dropZoneDoc">
                                    <div class="upload-icon">📎</div>
                                    <div class="fw-700">Click to upload or drag & drop</div>
                                    <div class="text-muted" style="font-size:13px;margin-top:4px;">PDF, DOCX, TXT — max 10MB</div>
                                    <div id="docFileName" style="color:var(--teal);margin-top:8px;font-size:13px;"></div>
                                </div>
                                <input type="file" id="fileInputDoc" name="submission_file" accept=".pdf,.docx,.txt"
                                    onchange="showFileName(this,'docFileName')">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Also include text answer (optional, improves auto-evaluation)</label>
                                <textarea name="text_content" class="form-control" rows="5" placeholder="Paste any text from your document..."></textarea>
                            </div>
                        </div>
                        <% } %>

                        <% if ("IMAGE".equals(submissionMethod)) { %>
                        <!-- Image Panel -->
                        <div class="submit-panel active" id="panel-image">
                            <div class="form-group">
                                <label class="form-label">Upload image of handwritten answer</label>
                                <div class="upload-drop" onclick="document.getElementById('fileInputImg').click();">
                                    <div class="upload-icon">🖼</div>
                                    <div class="fw-700">Click to upload handwritten answer</div>
                                    <div class="text-muted" style="font-size:13px;margin-top:4px;">JPG, PNG, JPEG, WEBP, JFIF — max 10MB</div>
                                    <div id="imgFileName" style="color:var(--teal);margin-top:8px;font-size:13px;"></div>
                                </div>
                                <input type="file" id="fileInputImg" name="submission_file" accept=".jpg,.jpeg,.png,.webp,.jfif"
                                    onchange="showFileName(this,'imgFileName')">
                            </div>
                            <div class="alert alert-info" style="margin-top:8px;">
                                ℹ Image submissions are stored but cannot be auto-evaluated by keyword matching. Marks may be 0 unless teacher manually reviews.
                            </div>
                        </div>
                        <% } %>

                        <div style="margin-top:20px;" class="d-flex gap-12">
                            <button type="submit" class="btn btn-teal" id="submitBtn">📤 Submit Assignment</button>
                            <a href="<%= ctx %>/student/subjectDetails" class="btn btn-ghost">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
<script>
function showFileName(input, targetId) {
    const el = document.getElementById(targetId);
    if (el && input.files.length > 0) el.textContent = '✅ ' + input.files[0].name;
}
// Word count
const ta = document.getElementById('textContent');
if (ta) ta.addEventListener('input', () => {
    const words = ta.value.trim().split(/\s+/).filter(w => w).length;
    document.getElementById('wordCount').textContent = 'Words: ' + words;
});
// Submit guard
document.getElementById('submitForm').addEventListener('submit', function(e) {
    const btn = document.getElementById('submitBtn');
    btn.disabled = true;
    btn.textContent = 'Submitting...';
});
</script>
</body>
</html>


