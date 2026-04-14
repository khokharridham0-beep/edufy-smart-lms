<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*, model.Module" %>
<%
    request.setAttribute("pageTitle", "Assignments");
    List<Assignment> assignments = (List<Assignment>) request.getAttribute("assignments");
    List<Module>     modules     = (List<Module>)     request.getAttribute("modules");
    String msg = request.getParameter("msg");
    User teacher = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assignments — Teacher Portal</title>
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
            <a href="<%= ctx %>/teacher/assignments" class="nav-item active"><span class="nav-icon">📝</span> Assignments</a>
            <a href="<%= ctx %>/teacher/quizzes" class="nav-item"><span class="nav-icon">❓</span> Quizzes</a>
            <a href="<%= ctx %>/teacher/submissions" class="nav-item"><span class="nav-icon">📥</span> Submissions</a>
            <a href="<%= ctx %>/teacher/marks"       class="nav-item"><span class="nav-icon">🏅</span> Marks</a>
            <a href="<%= ctx %>/logout" class="nav-item danger"><span class="nav-icon">⏻</span> Logout</a>
        </nav>
    </aside>

    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">
            <% if (msg != null) { %><div class="alert alert-success" data-auto-dismiss>✅ Assignment <%= msg %> successfully.</div><% } %>
            <div class="page-header">
                <div><h1>📝 Assignments</h1><p>Create and manage your assignments with keywords for auto-evaluation</p></div>
                <button class="btn btn-teal" onclick="openModal('addAssignmentModal')">+ New Assignment</button>
            </div>

            <div class="card">
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Title</th><th>Module</th><th>Subject</th><th>Method</th><th>Max Marks</th><th>Keywords</th><th>Actions</th></tr></thead>
                        <tbody>
                        <% if (assignments != null && !assignments.isEmpty()) { for (Assignment a : assignments) { %>
                            <tr>
                                <td class="fw-700"><%= a.getTitle() %></td>
                                <td><span class="badge badge-muted"><%= a.getModuleName() %></span></td>
                                <td class="text-muted" style="font-size:13px;"><%= a.getSubjectName() %></td>
                                <td><span class="badge badge-amber"><%= a.getSubmissionMethod() != null ? a.getSubmissionMethod() : "TEXT" %></span></td>
                                <td><span class="badge badge-teal"><%= a.getMaxMarks() %> marks</span></td>
                                <td style="font-size:12px;color:var(--muted);max-width:200px;">
                                    <% String[] kws = a.getKeywords().split(",");
                                       int shown = 0;
                                       for (String kw : kws) { if (shown++ >= 3) break; %>
                                        <span class="badge badge-amber" style="margin:1px;"><%= kw.trim() %></span>
                                    <% } if (kws.length > 3) { %><span class="text-muted" style="font-size:11px;">+<%= kws.length - 3 %> more</span><% } %>
                                </td>
                                <td>
                                    <a href="<%= ctx %>/teacher/submissions?assignmentId=<%= a.getId() %>" class="btn btn-ghost btn-sm">📥 Submissions</a>
                                    <button class="btn btn-ghost btn-sm"
                                        data-form="editAssignmentForm" data-modal="editAssignmentModal"
                                        data-id="<%= a.getId() %>" data-title="<%= a.getTitle() %>"
                                        data-question="<%= a.getQuestion().replace("\"","&quot;") %>"
                                        data-keywords="<%= a.getKeywords() %>"
                                        data-submission_method="<%= a.getSubmissionMethod() != null ? a.getSubmissionMethod() : "TEXT" %>"
                                        data-max_marks="<%= a.getMaxMarks() %>" onclick="populateEdit(this)">✏</button>
                                    <button class="btn btn-rose btn-sm" onclick="confirmDelete('<%= ctx %>/teacher/deleteAssignment?id=<%= a.getId() %>','<%= a.getTitle() %>')">🗑</button>
                                </td>
                            </tr>
                        <% } } else { %><tr><td colspan="7" style="text-align:center;padding:30px;color:var(--muted);">No assignments yet. Create one!</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add Assignment Modal -->
<div class="modal-overlay" id="addAssignmentModal">
    <div class="modal" style="max-width:600px;">
        <div class="modal-header"><h4>+ New Assignment</h4><button class="modal-close" onclick="closeModal('addAssignmentModal')">✕</button></div>
        <form action="<%= ctx %>/teacher/addAssignment" method="post">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Module</label>
                    <select name="module_id" id="moduleSelect" class="form-control" required>
                        <option value="">-- Select Module --</option>
                        <% if (modules != null) for (Module m : modules) { %><option value="<%= m.getId() %>"><%= m.getModuleName() %></option><% } %>
                    </select>
                    <div style="margin-top:6px;font-size:12px;color:var(--muted);">Only modules from your admin-assigned subjects are shown.</div>
                </div>
                <div class="form-group"><label class="form-label">Assignment Title</label><input name="title" class="form-control" required placeholder="e.g. Java Variables Assignment"></div>
                <div class="form-group"><label class="form-label">Question / Description</label><textarea name="question" class="form-control" required rows="3" placeholder="Describe what students need to do..."></textarea></div>
                <div class="form-group">
                    <label class="form-label">Keywords <span class="text-muted" style="font-weight:400;">(comma-separated, used for auto-evaluation)</span></label>
                    <input name="keywords" class="form-control" required placeholder="variable, datatype, int, String, boolean">
                    <div style="margin-top:6px;font-size:12px;color:var(--muted);">💡 Each keyword found in student answer contributes proportional marks</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Submission Method</label>
                    <select name="submission_method" class="form-control" required>
                        <option value="TEXT">Text Answer</option>
                        <option value="FILE">File Upload (PDF/DOCX/TXT)</option>
                        <option value="IMAGE">Image / Handwritten</option>
                    </select>
                </div>
                <div class="form-group"><label class="form-label">Max Marks</label><input name="max_marks" type="number" class="form-control" value="10" min="1" max="100"></div>
            </div>
            <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="closeModal('addAssignmentModal')">Cancel</button><button type="submit" class="btn btn-teal">Create Assignment</button></div>
        </form>
    </div>
</div>

<!-- Edit Assignment Modal -->
<div class="modal-overlay" id="editAssignmentModal">
    <div class="modal" style="max-width:600px;">
        <div class="modal-header"><h4>✏ Edit Assignment</h4><button class="modal-close" onclick="closeModal('editAssignmentModal')">✕</button></div>
        <form id="editAssignmentForm" action="<%= ctx %>/teacher/updateAssignment" method="post">
            <div class="modal-body">
                <input type="hidden" name="id">
                <div class="form-group"><label class="form-label">Title</label><input name="title" class="form-control" required></div>
                <div class="form-group"><label class="form-label">Question</label><textarea name="question" class="form-control" rows="3"></textarea></div>
                <div class="form-group"><label class="form-label">Keywords (comma-separated)</label><input name="keywords" class="form-control" required></div>
                <div class="form-group">
                    <label class="form-label">Submission Method</label>
                    <select name="submission_method" class="form-control" required>
                        <option value="TEXT">Text Answer</option>
                        <option value="FILE">File Upload (PDF/DOCX/TXT)</option>
                        <option value="IMAGE">Image / Handwritten</option>
                    </select>
                </div>
                <div class="form-group"><label class="form-label">Max Marks</label><input name="max_marks" type="number" class="form-control" min="1" max="100"></div>
            </div>
            <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="closeModal('editAssignmentModal')">Cancel</button><button type="submit" class="btn btn-teal">Save Changes</button></div>
        </form>
    </div>
</div>

<script src="<%= ctx %>/js/script.js"></script>
</body></html>


