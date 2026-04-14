<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- header.jsp - Reusable top header bar --%>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String userName  = currentUser != null ? currentUser.getName() : "Guest";
    String userRole  = currentUser != null ? currentUser.getRole() : "";
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) pageTitle = "Dashboard";
%>
<header class="topbar">
    <div class="d-flex align-center gap-12">
        <button id="sidebarToggle" class="btn btn-ghost btn-icon" style="display:none;" title="Toggle Menu">☰</button>
        <h2 class="topbar-title"><%= pageTitle %></h2>
    </div>
    <div class="topbar-right">
        <span class="topbar-badge">
            <%= userRole.equals("ADMIN") ? "🛡" : userRole.equals("TEACHER") ? "🎓" : "📚" %>
            <%= userName %>
        </span>
        <a href="<%= request.getContextPath() %>/logout" class="btn btn-ghost btn-sm">
            ⏻ Logout
        </a>
    </div>
</header>


