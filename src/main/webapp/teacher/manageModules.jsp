<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*, model.Module" %>
<%
    request.setAttribute("pageTitle", "Manage Modules");
    List<Module> modules = (List<Module>) request.getAttribute("modules");
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
    User teacher = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modules — Teacher</title>
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
                <div><h1>📂 Modules</h1><p>Manage modules in your subjects</p></div>
                <button class="btn btn-teal" onclick="openModal('addModuleModal')">+ New Module</button>
            </div>
            <% if (modules != null && !modules.isEmpty()) { for (Module m : modules) { %>
            <div class="module-card">
                <div class="module-header" data-toggle="true">
                    <div style="flex:1;">
                        <h4 style="margin-bottom:4px;"><span>📂</span> <%= m.getModuleName() %> <span class="badge badge-teal" style="margin-left:8px;"><%= m.getSubjectName() %></span></h4>
                        <% if (m.getChapterName() != null && !m.getChapterName().isEmpty()) { %>
                            <span class="text-muted" style="font-size:12px; margin-left: 28px;">🔖 <%= m.getChapterName() %></span>
                        <% } %>
                    </div>
                    <div>
                        <button class="btn btn-ghost btn-sm"
                            data-form="editModuleForm"
                            data-modal="editModuleModal"
                            data-id="<%= m.getId() %>"
                            data-subject_id="<%= m.getSubjectId() %>"
                            data-chapter_name="<%= m.getChapterName() != null ? m.getChapterName() : "" %>"
                            data-module_name="<%= m.getModuleName() %>"
                            data-description="<%= m.getDescription() != null ? m.getDescription() : "" %>"
                            onclick="event.stopPropagation(); populateEdit(this)">✏</button>
                        <button class="btn btn-rose btn-sm" onclick="event.stopPropagation(); confirmDelete('<%= ctx %>/teacher/deleteModule?id=<%= m.getId() %>', '<%= m.getModuleName() %>')">🗑</button>
                        <span class="toggle-icon" style="margin-left:12px;">▾</span>
                    </div>
                </div>
                <div class="module-body">
                    <div class="assignment-row">
                        <span class="text-muted" style="font-size:13px;"><%= m.getDescription() != null ? m.getDescription() : "No description." %></span>
                    </div>
                </div>
            </div>
            <% } } else { %>
            <div class="card"><div class="card-body" style="text-align:center;padding:40px;color:var(--muted);">No modules in your subjects yet.</div></div>
            <% } %>
        </div>
    </div>
</div>
</div>
<script src="<%= ctx %>/js/script.js"></script>

<!-- Add Module Modal -->
<div class="modal-overlay" id="addModuleModal">
    <div class="modal">
        <div class="modal-header">
            <h4>+ Create New Module</h4>
            <button class="modal-close" onclick="closeModal('addModuleModal')">✕</button>
        </div>
        <form action="<%= ctx %>/teacher/addModule" method="post">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Subject</label>
                    <select name="subject_id" class="form-control" required>
                        <option value="">-- Select Subject --</option>
                        <% if (subjects != null) for (Subject s : subjects) { %>
                        <option value="<%= s.getId() %>"><%= s.getName() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Chapter Name (Optional)</label>
                    <input name="chapter_name" class="form-control" placeholder="e.g. Chapter 1: Introduction">
                </div>
                <div class="form-group">
                    <label class="form-label">Module Name</label>
                    <input name="module_name" class="form-control" required placeholder="e.g. Basics of Java">
                </div>
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control" rows="3" placeholder="Objective of module"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addModuleModal')">Cancel</button>
                <button type="submit" class="btn btn-teal">Create Module</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Module Modal -->
<div class="modal-overlay" id="editModuleModal">
    <div class="modal">
        <div class="modal-header">
            <h4>✏ Edit Module</h4>
            <button class="modal-close" onclick="closeModal('editModuleModal')">✕</button>
        </div>
        <form id="editModuleForm" action="<%= ctx %>/teacher/updateModule" method="post">
            <div class="modal-body">
                <input type="hidden" name="id">
                <div class="form-group">
                    <label class="form-label">Subject</label>
                    <select name="subject_id" class="form-control" required>
                        <option value="">-- Select Subject --</option>
                        <% if (subjects != null) for (Subject s : subjects) { %>
                        <option value="<%= s.getId() %>"><%= s.getName() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Chapter Name (Optional)</label>
                    <input name="chapter_name" class="form-control" placeholder="e.g. Chapter 1: Introduction">
                </div>
                <div class="form-group">
                    <label class="form-label">Module Name</label>
                    <input name="module_name" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control" rows="3"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editModuleModal')">Cancel</button>
                <button type="submit" class="btn btn-teal">Save Changes</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>


