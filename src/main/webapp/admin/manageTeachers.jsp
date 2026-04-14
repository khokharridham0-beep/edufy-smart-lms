<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "Manage Teachers");
    request.setAttribute("activePage", "teachers");
    List<User>   teachers = (List<User>)   request.getAttribute("teachers");
    List<Subject> subjects  = (List<Subject>) request.getAttribute("subjects");
    String msg = request.getParameter("msg");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Teachers</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<div class="layout">
    <%@ include file="../components/sidebar.jsp" %>
    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">
            <% if (msg != null) { %><div class="alert alert-success" data-auto-dismiss>✅ Teacher <%= msg %> successfully.</div><% } %>
            <div class="page-header">
                <div><h1>👨‍🏫 Teachers</h1><p>Assign teachers to subjects</p></div>
                <button class="btn btn-amber" onclick="openModal('addTeacherModal')">+ Add Teacher</button>
            </div>

            <div class="card">
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>#</th><th>Name</th><th>Email</th><th>Assigned Subject</th><th>Actions</th></tr></thead>
                        <tbody>
                        <% if (teachers != null && !teachers.isEmpty()) { int i=1; for (User t : teachers) {
                            String cName = "—";
                            if (subjects != null) for (Subject c : subjects) if (c.getId() == t.getSubjectId()) { cName = c.getName(); break; }
                        %>
                            <tr>
                                <td class="text-muted"><%= i++ %></td>
                                <td><div class="d-flex align-center gap-8">
                                    <div class="user-avatar" style="width:32px;height:32px;font-size:12px;background:linear-gradient(135deg,var(--amber),var(--rose));"><%= String.valueOf(t.getName().charAt(0)).toUpperCase() %></div>
                                    <%= t.getName() %>
                                </div></td>
                                <td class="text-muted"><%= t.getEmail() %></td>
                                <td><% if (!"—".equals(cName)) { %><span class="badge badge-amber"><%= cName %></span><% } else { %><span class="badge badge-muted">Unassigned</span><% } %></td>
                                <td>
                                    <button class="btn btn-ghost btn-sm"
                                        data-form="editTeacherForm" data-modal="editTeacherModal"
                                        data-id="<%= t.getId() %>" data-name="<%= t.getName() %>"
                                        data-email="<%= t.getEmail() %>" data-password="<%= t.getPassword() %>"
                                        data-subject_id="<%= t.getSubjectId() %>" onclick="populateEdit(this)">✏ Edit</button>
                                    <button class="btn btn-rose btn-sm" onclick="confirmDelete('<%= ctx %>/admin/deleteUser?id=<%= t.getId() %>&from=teachers','<%= t.getName() %>')">🗑</button>
                                </td>
                            </tr>
                        <% } } else { %><tr><td colspan="5" style="text-align:center;padding:30px;color:var(--muted);">No teachers found.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add Teacher Modal -->
<div class="modal-overlay" id="addTeacherModal">
    <div class="modal"><div class="modal-header"><h4>+ Add Teacher</h4><button class="modal-close" onclick="closeModal('addTeacherModal')">✕</button></div>
    <form action="<%= ctx %>/admin/addTeacher" method="post">
        <div class="modal-body">
            <div class="form-group"><label class="form-label">Full Name</label><input name="name" class="form-control" required placeholder="Prof. Name"></div>
            <div class="form-group"><label class="form-label">Email</label><input name="email" type="email" class="form-control" required></div>
            <div class="form-group"><label class="form-label">Password</label><input name="password" type="text" class="form-control" required></div>
            <div class="form-group"><label class="form-label">Assign Subject</label>
                <select name="subject_id" class="form-control">
                    <option value="">-- Select Subject --</option>
                    <% if (subjects != null) for (Subject c : subjects) { %><option value="<%= c.getId() %>"><%= c.getName() %></option><% } %>
                </select>
            </div>
        </div>
        <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="closeModal('addTeacherModal')">Cancel</button><button type="submit" class="btn btn-amber">Add Teacher</button></div>
    </form></div>
</div>

<!-- Edit Teacher Modal -->
<div class="modal-overlay" id="editTeacherModal">
    <div class="modal"><div class="modal-header"><h4>✏ Edit Teacher</h4><button class="modal-close" onclick="closeModal('editTeacherModal')">✕</button></div>
    <form id="editTeacherForm" action="<%= ctx %>/admin/updateTeacher" method="post">
        <div class="modal-body">
            <input type="hidden" name="id">
            <div class="form-group"><label class="form-label">Full Name</label><input name="name" class="form-control" required></div>
            <div class="form-group"><label class="form-label">Email</label><input name="email" type="email" class="form-control" required></div>
            <div class="form-group"><label class="form-label">Password</label><input name="password" type="text" class="form-control" required></div>
            <div class="form-group"><label class="form-label">Assigned Subject</label>
                <select name="subject_id" class="form-control">
                    <option value="">-- No Subject --</option>
                    <% if (subjects != null) for (Subject c : subjects) { %><option value="<%= c.getId() %>"><%= c.getName() %></option><% } %>
                </select>
            </div>
        </div>
        <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="closeModal('editTeacherModal')">Cancel</button><button type="submit" class="btn btn-amber">Save Changes</button></div>
    </form></div>
</div>
<script src="<%= ctx %>/js/script.js"></script>
</body></html>


