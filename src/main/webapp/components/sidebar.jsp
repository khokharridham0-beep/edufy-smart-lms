<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- sidebar.jsp - Role-aware sidebar navigation (Admin / Teacher / Student) --%>
<%@ page import="model.User" %>
<%
    User sideUser  = (User) session.getAttribute("user");
    String sName   = sideUser != null ? sideUser.getName() : "";
    String sRole   = sideUser != null ? sideUser.getRole() : "";
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
    String sidebarCtx = request.getContextPath();
%>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="brand-icon">🤖</div>
        <h2>Edufy</h2>
        <span>Management Portal</span>
    </div>

    <div class="sidebar-user">
        <div class="user-avatar"><%= sName.length() > 0 ? String.valueOf(sName.charAt(0)).toUpperCase() : "U" %></div>
        <div class="user-info">
            <div class="user-name"><%= sName %></div>
            <div class="user-role">
                <% if ("ADMIN".equals(sRole)) { %><span class="role-badge admin">Administrator</span>
                <% } else if ("TEACHER".equals(sRole)) { %><span class="role-badge teacher">Teacher</span>
                <% } else { %><span class="role-badge student">Student</span><% } %>
            </div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <% if ("ADMIN".equals(sRole)) { %>
        <div class="nav-label">Overview</div>
        <a href="<%= sidebarCtx %>/admin/dashboard" class="nav-item <%= "dashboard".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">🏠</span> Dashboard
        </a>
        <div class="nav-label">Management</div>
        <a href="<%= sidebarCtx %>/admin/students" class="nav-item <%= "students".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">👩‍🎓</span> Students
        </a>
        <a href="<%= sidebarCtx %>/admin/teachers" class="nav-item <%= "teachers".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">👨‍🏫</span> Teachers
        </a>
        <a href="<%= sidebarCtx %>/admin/subjects" class="nav-item <%= "subjects".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">📘</span> Subjects
        </a>
        <a href="<%= sidebarCtx %>/admin/modules" class="nav-item <%= "modules".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">📂</span> Modules
        </a>
        <% } else if ("TEACHER".equals(sRole)) { %>
        <div class="nav-label">Overview</div>
        <a href="<%= sidebarCtx %>/teacher/dashboard" class="nav-item <%= "dashboard".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">🏠</span> Dashboard
        </a>
        <div class="nav-label">Teaching</div>
        <a href="<%= sidebarCtx %>/teacher/subjects" class="nav-item <%= "subjects".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">📘</span> My Subjects
        </a>
        <a href="<%= sidebarCtx %>/teacher/assignments" class="nav-item <%= "assignments".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">📝</span> Assignments
        </a>
        <a href="<%= sidebarCtx %>/teacher/submissions" class="nav-item <%= "submissions".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">📥</span> Submissions
        </a>
        <a href="<%= sidebarCtx %>/teacher/marks" class="nav-item <%= "marks".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">🏆</span> Marks
        </a>
        <% } else { %>
        <div class="nav-label">Overview</div>
        <a href="<%= sidebarCtx %>/student/dashboard" class="nav-item <%= "dashboard".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">🏠</span> Dashboard
        </a>
        <div class="nav-label">Learning</div>
        <a href="<%= sidebarCtx %>/student/subjects" class="nav-item <%= "subjects".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">📘</span> My Subjects
        </a>
        <a href="<%= sidebarCtx %>/student/results" class="nav-item <%= "results".equals(activePage) ? "active" : "" %>">
            <span class="nav-icon">🏆</span> My Results
        </a>
        <% } %>
        <div class="nav-label">Account</div>
        <a href="<%= sidebarCtx %>/logout" class="nav-item danger">
            <span class="nav-icon">⏻</span> Logout
        </a>
    </nav>
</aside>


