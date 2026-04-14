package dao;

import model.Subject;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * SubjectDAO - Handles all database operations for Subjects
 */
public class SubjectDAO {

    // Get all subjects with teacher name
    public List<Subject> getAllSubjects() {
        List<Subject> list = new ArrayList<>();
        String sql = "SELECT c.*, u.name AS teacher_name FROM subjects c " +
                     "LEFT JOIN users u ON c.teacher_id = u.id";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get subject by ID
    public Subject getSubjectById(int id) {
        String sql = "SELECT c.*, u.name AS teacher_name FROM subjects c " +
                     "LEFT JOIN users u ON c.teacher_id = u.id WHERE c.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Get subjects assigned to a teacher
    public List<Subject> getSubjectsByTeacher(int teacherId) {
        List<Subject> list = new ArrayList<>();
        String sql = "SELECT c.*, u.name AS teacher_name FROM subjects c " +
                     "LEFT JOIN users u ON c.teacher_id = u.id WHERE c.teacher_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Add subject
    public boolean addSubject(Subject subject) {
        String sql = "INSERT INTO subjects (name, description, teacher_id) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subject.getName());
            ps.setString(2, subject.getDescription());
            if (subject.getTeacherId() > 0) ps.setInt(3, subject.getTeacherId());
            else ps.setNull(3, Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Update subject
    public boolean updateSubject(Subject subject) {
        String sql = "UPDATE subjects SET name=?, description=?, teacher_id=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subject.getName());
            ps.setString(2, subject.getDescription());
            if (subject.getTeacherId() > 0) ps.setInt(3, subject.getTeacherId());
            else ps.setNull(3, Types.INTEGER);
            ps.setInt(4, subject.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Delete subject
    public boolean deleteSubject(int id) {
        String sql = "DELETE FROM subjects WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Count total subjects
    public int countSubjects() {
        String sql = "SELECT COUNT(*) FROM subjects";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // Map row to Subject
    private Subject mapRow(ResultSet rs) throws SQLException {
        Subject c = new Subject();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setDescription(rs.getString("description"));
        c.setTeacherId(rs.getInt("teacher_id"));
        try { c.setTeacherName(rs.getString("teacher_name")); } catch (Exception ignored) {}
        return c;
    }
}
