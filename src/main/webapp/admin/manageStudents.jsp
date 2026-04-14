<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List, model.*" %>
<%
    request.setAttribute("pageTitle", "Manage Students");
    request.setAttribute("activePage", "students");
    List<User>   students = (List<User>)   request.getAttribute("students");
    List<Subject> subjects  = (List<Subject>) request.getAttribute("subjects");
    String msg = request.getParameter("msg");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Students — Edufy</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<div class="layout">
    <%@ include file="../components/sidebar.jsp" %>
    <div class="main-wrapper">
        <%@ include file="../components/header.jsp" %>
        <div class="page-content">

            <% if (msg != null) { %>
            <div class="alert alert-success" data-auto-dismiss>
                ✅ Student <%= msg.equals("added") ? "added" : msg.equals("updated") ? "updated" : "deleted" %> successfully.
            </div>
            <% } %>

            <div class="page-header">
                <div>
                    <h1>👩‍🎓 Students</h1>
                    <p>Manage all registered students</p>
                </div>
                <button class="btn btn-teal" onclick="openModal('addStudentModal')">+ Add Student</button>
            </div>

            <div class="card">
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr><th>#</th><th>Name</th><th>Email</th><th>Enrolled Subject</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                        <% if (students != null && !students.isEmpty()) {
                            int i = 1;
                            for (User s : students) {
                                // Find subject name
                                String cName = "—";
                                if (subjects != null) for (Subject c : subjects) if (c.getId() == s.getSubjectId()) { cName = c.getName(); break; }
                        %>
                            <tr>
                                <td class="text-muted"><%= i++ %></td>
                                <td>
                                    <div class="d-flex align-center gap-8">
                                        <div class="user-avatar" style="width:32px;height:32px;font-size:12px;"><%= String.valueOf(s.getName().charAt(0)).toUpperCase() %></div>
                                        <%= s.getName() %>
                                    </div>
                                </td>
                                <td class="text-muted"><%= s.getEmail() %></td>
                                <td>
                                    <% if (!"—".equals(cName)) { %>
                                        <span class="badge badge-teal"><%= cName %></span>
                                    <% } else { %><span class="badge badge-muted">Not Enrolled</span><% } %>
                                </td>
                                <td>
                                    <button class="btn btn-ghost btn-sm"
                                        data-form="editStudentForm"
                                        data-modal="editStudentModal"
                                        data-id="<%= s.getId() %>"
                                        data-name="<%= s.getName() %>"
                                        data-email="<%= s.getEmail() %>"
                                        data-password="<%= s.getPassword() %>"
                                        data-subject_id="<%= s.getSubjectId() %>"
                                        onclick="populateEdit(this)">✏ Edit</button>
                                    <button class="btn btn-rose btn-sm" onclick="confirmDelete('<%= ctx %>/admin/deleteUser?id=<%= s.getId() %>&from=students','<%= s.getName() %>')">🗑</button>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="5" style="text-align:center;padding:30px;color:var(--muted);">No students found.</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- Add Student Modal -->
<div class="modal-overlay" id="addStudentModal">
    <div class="modal">
        <div class="modal-header">
            <h4>+ Add New Student</h4>
            <button class="modal-close" onclick="closeModal('addStudentModal')">✕</button>
        </div>
        <form action="<%= ctx %>/admin/addStudent" method="post">
            <div class="modal-body">
                <div class="form-group"><label class="form-label">Full Name</label><input name="name" class="form-control" required placeholder="Student name"></div>
                <div class="form-group"><label class="form-label">Email</label><input name="email" type="email" class="form-control" required placeholder="student@email.com"></div>
                <div class="form-group"><label class="form-label">Password</label><input name="password" type="text" class="form-control" required placeholder="Password"></div>
                <div class="form-group">
                    <label class="form-label">Enroll in Subject</label>
                    <select name="subject_id" class="form-control">
                        <option value="">-- Select Subject --</option>
                        <% if (subjects != null) for (Subject c : subjects) { %>
                        <option value="<%= c.getId() %>"><%= c.getName() %></option>
                        <% } %>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addStudentModal')">Cancel</button>
                <button type="submit" class="btn btn-teal">Add Student</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Student Modal -->
<div class="modal-overlay" id="editStudentModal">
    <div class="modal">
        <div class="modal-header">
            <h4>✏ Edit Student</h4>
            <button class="modal-close" onclick="closeModal('editStudentModal')">✕</button>
        </div>
        <form id="editStudentForm" action="<%= ctx %>/admin/updateStudent" method="post">
            <div class="modal-body">
                <input type="hidden" name="id">
                <div class="form-group"><label class="form-label">Full Name</label><input name="name" class="form-control" required></div>
                <div class="form-group"><label class="form-label">Email</label><input name="email" type="email" class="form-control" required></div>
                <div class="form-group"><label class="form-label">Password</label><input name="password" type="text" class="form-control" required></div>
                <div class="form-group">
                    <label class="form-label">Enrolled Subject</label>
                    <select name="subject_id" class="form-control">
                        <option value="">-- No Subject --</option>
                        <% if (subjects != null) for (Subject c : subjects) { %>
                        <option value="<%= c.getId() %>"><%= c.getName() %></option>
                        <% } %>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editStudentModal')">Cancel</button>
                <button type="submit" class="btn btn-teal">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<script src="<%= ctx %>/js/script.js"></script>
</body>
</html>


