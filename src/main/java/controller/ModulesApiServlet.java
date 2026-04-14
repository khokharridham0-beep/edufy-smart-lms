package controller;

import dao.ModuleDAO;
import model.Module;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * ModulesApiServlet - Returns modules JSON for a given courseId (AJAX)
 * Used by teacher assignment upload form for dynamic module dropdown.
 */
@WebServlet("/api/modules")
public class ModulesApiServlet extends HttpServlet {

    private final ModuleDAO moduleDAO = new ModuleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String subjectIdStr = req.getParameter("subjectId");
        PrintWriter out = resp.getWriter();

        if (subjectIdStr == null || subjectIdStr.trim().isEmpty()) {
            out.print("[]");
            return;
        }

        try {
            int subjectId = Integer.parseInt(subjectIdStr);
            List<Module> modules = moduleDAO.getModulesBySubject(subjectId);
            // Build JSON manually (no external library needed)
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < modules.size(); i++) {
                Module m = modules.get(i);
                if (i > 0) json.append(",");
                json.append("{\"id\":").append(m.getId())
                    .append(",\"moduleName\":\"").append(escapeJson(m.getModuleName())).append("\"}");
            }
            json.append("]");
            out.print(json.toString());
        } catch (NumberFormatException e) {
            out.print("[]");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
