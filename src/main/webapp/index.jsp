<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Redirect to login page or dashboard based on session
    Object user = session.getAttribute("user");
    if (user != null) {
        model.User u = (model.User) user;
        if ("ADMIN".equals(u.getRole()))   { response.sendRedirect("admin/dashboard"); return; }
        if ("TEACHER".equals(u.getRole())) { response.sendRedirect("teacher/dashboard"); return; }
        if ("STUDENT".equals(u.getRole())) { response.sendRedirect("student/dashboard"); return; }
    }
    response.sendRedirect("login.jsp");
%>


