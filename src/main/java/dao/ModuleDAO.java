package dao;

import model.Module;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ModuleDAO - Handles all database operations for Modules
 */
public class ModuleDAO {

    // Get all modules
    public List<Module> getAllModules() {
        List<Module> list = new ArrayList<>();
        String sql = "SELECT m.*, c.name AS subject_name FROM modules m " +
                     "JOIN subjects c ON m.subject_id = c.id ORDER BY m.subject_id, m.id";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get modules by course ID
    public List<Module> getModulesBySubject(int subjectId) {
        List<Module> list = new ArrayList<>();
        String sql = "SELECT m.*, c.name AS subject_name FROM modules m " +
                     "JOIN subjects c ON m.subject_id = c.id WHERE m.subject_id = ? ORDER BY m.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, subjectId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get module by ID
    public Module getModuleById(int id) {
        String sql = "SELECT m.*, c.name AS subject_name FROM modules m " +
                     "JOIN subjects c ON m.subject_id = c.id WHERE m.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Add module
    public boolean addModule(Module module) {
        String sql = "INSERT INTO modules (module_name, chapter_name, description, subject_id) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, module.getModuleName());
            ps.setString(2, module.getChapterName());
            ps.setString(3, module.getDescription());
            ps.setInt(4, module.getSubjectId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Update module
    public boolean updateModule(Module module) {
        String sql = "UPDATE modules SET module_name=?, chapter_name=?, description=?, subject_id=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, module.getModuleName());
            ps.setString(2, module.getChapterName());
            ps.setString(3, module.getDescription());
            ps.setInt(4, module.getSubjectId());
            ps.setInt(5, module.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Delete module
    public boolean deleteModule(int id) {
        String sql = "DELETE FROM modules WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Map row to Module
    private Module mapRow(ResultSet rs) throws SQLException {
        Module m = new Module();
        m.setId(rs.getInt("id"));
        m.setModuleName(rs.getString("module_name"));
        m.setChapterName(rs.getString("chapter_name"));
        m.setDescription(rs.getString("description"));
        m.setSubjectId(rs.getInt("subject_id"));
        try { m.setSubjectName(rs.getString("subject_name")); } catch (Exception ignored) {}
        return m;
    }
}
