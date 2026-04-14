<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
 
<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "Manage Subjects");
    request.setAttribute("activePage", "subjects");
    List<Subject> subjects  = (List<Subject>) request.getAttribute("subjects");
    List<User>   teachers = (List<User>)   request.getAttribute("teachers");
    String msg = request.getParameter("msg");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Subjects</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<div class="layout">
    <%@ include file="../components/sidebar.jsp" %>
    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">
            <% if (msg != null) { %><div class="alert alert-success" data-auto-dismiss>✅ Subject <%= msg %> successfully.</div><% } %>
            <div class="page-header">
                <div><h1>📘 Subjects</h1><p>Manage subjects and assign teachers</p></div>
                <button class="btn btn-teal" onclick="openModal('addSubjectModal')">+ Add Subject</button>
            </div>

            <div class="card">
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>#</th><th>Subject Name</th><th>Description</th><th>Teacher</th><th>Actions</th></tr></thead>
                        <tbody>
                        <% if (subjects != null && !subjects.isEmpty()) { int i=1; for (Subject c : subjects) { %>
                            <tr>
                                <td class="text-muted"><%= i++ %></td>
                                <td class="fw-700"><%= c.getName() %></td>
                                <td class="text-muted" style="font-size:13px;max-width:240px;"><%= c.getDescription() != null ? c.getDescription() : "—" %></td>
                                <td>
                                    <% if (c.getTeacherName() != null && !c.getTeacherName().isEmpty()) { %>
                                    <span class="badge badge-amber">🎓 <%= c.getTeacherName() %></span>
                                    <% } else { %><span class="badge badge-muted">Unassigned</span><% } %>
                                </td>
                                <td>
                                    <button class="btn btn-ghost btn-sm"
                                        data-form="editSubjectForm" data-modal="editSubjectModal"
                                        data-id="<%= c.getId() %>" data-name="<%= c.getName() %>"
                                        data-description="<%= c.getDescription() != null ? c.getDescription() : "" %>"
                                        data-teacher_id="<%= c.getTeacherId() %>" onclick="populateEdit(this)">✏ Edit</button>
                                    <button class="btn btn-rose btn-sm" onclick="confirmDelete('<%= ctx %>/admin/deleteSubject?id=<%= c.getId() %>','<%= c.getName() %>')">🗑</button>
                                </td>
                            </tr>
                        <% } } else { %><tr><td colspan="5" style="text-align:center;padding:30px;color:var(--muted);">No subjects yet.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add Subject Modal -->
<div class="modal-overlay" id="addSubjectModal">
    <div class="modal"><div class="modal-header"><h4>+ Add Subject</h4><button class="modal-close" onclick="closeModal('addSubjectModal')">✕</button></div>
    <form action="<%= ctx %>/admin/addSubject" method="post">
        <div class="modal-body">
            <div class="form-group"><label class="form-label">Subject Name</label><input name="name" class="form-control" required placeholder="e.g. Java Programming"></div>
            <div class="form-group"><label class="form-label">Description</label><textarea name="description" class="form-control" placeholder="Subject description..."></textarea></div>
            <div class="form-group"><label class="form-label">Assign Teacher</label>
                <select name="teacher_id" class="form-control">
                    <option value="">-- Select Teacher --</option>
                    <% if (teachers != null) for (User t : teachers) { %><option value="<%= t.getId() %>"><%= t.getName() %></option><% } %>
                </select>
            </div>
        </div>
        <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="closeModal('addSubjectModal')">Cancel</button><button type="submit" class="btn btn-teal">Add Subject</button></div>
    </form></div>
</div>

<!-- Edit Subject Modal -->
<div class="modal-overlay" id="editSubjectModal">
    <div class="modal"><div class="modal-header"><h4>✏ Edit Subject</h4><button class="modal-close" onclick="closeModal('editSubjectModal')">✕</button></div>
    <form id="editSubjectForm" action="<%= ctx %>/admin/updateSubject" method="post">
        <div class="modal-body">
            <input type="hidden" name="id">
            <div class="form-group"><label class="form-label">Subject Name</label><input name="name" class="form-control" required></div>
            <div class="form-group"><label class="form-label">Description</label><textarea name="description" class="form-control"></textarea></div>
            <div class="form-group"><label class="form-label">Assign Teacher</label>
                <select name="teacher_id" class="form-control">
                    <option value="">-- No Teacher --</option>
                    <% if (teachers != null) for (User t : teachers) { %><option value="<%= t.getId() %>"><%= t.getName() %></option><% } %>
                </select>
            </div>
        </div>
        <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="closeModal('editSubjectModal')">Cancel</button><button type="submit" class="btn btn-teal">Save Changes</button></div>
    </form></div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body></html>


