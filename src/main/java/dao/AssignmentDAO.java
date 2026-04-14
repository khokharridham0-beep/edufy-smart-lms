package dao;

import model.Assignment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * AssignmentDAO - Handles all database operations for Assignments
 */
public class AssignmentDAO {

    // Get all assignments with joined info
    public List<Assignment> getAllAssignments() {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, m.module_name, c.name AS subject_name FROM assignments a " +
                     "JOIN modules m ON a.module_id = m.id " +
                     "JOIN subjects c ON a.subject_id = c.id ORDER BY a.id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get assignments by module
    public List<Assignment> getAssignmentsByModule(int moduleId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, m.module_name, c.name AS subject_name FROM assignments a " +
                     "JOIN modules m ON a.module_id = m.id " +
                     "JOIN subjects c ON a.subject_id = c.id WHERE a.module_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, moduleId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get assignments by course
    public List<Assignment> getAssignmentsBySubject(int subjectId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, m.module_name, c.name AS subject_name FROM assignments a " +
                     "JOIN modules m ON a.module_id = m.id " +
                     "JOIN subjects c ON a.subject_id = c.id WHERE a.subject_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, subjectId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get assignments by teacher
    public List<Assignment> getAssignmentsByTeacher(int teacherId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, m.module_name, c.name AS subject_name FROM assignments a " +
                     "JOIN modules m ON a.module_id = m.id " +
                     "JOIN subjects c ON a.subject_id = c.id WHERE a.teacher_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get single assignment by ID
    public Assignment getAssignmentById(int id) {
        String sql = "SELECT a.*, m.module_name, c.name AS subject_name FROM assignments a " +
                     "JOIN modules m ON a.module_id = m.id " +
                     "JOIN subjects c ON a.subject_id = c.id WHERE a.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Add assignment
    public boolean addAssignment(Assignment a) {
        String sql = "INSERT INTO assignments (title, question, keywords, module_id, subject_id, teacher_id, max_marks, submission_method) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getQuestion());
            ps.setString(3, a.getKeywords());
            ps.setInt(4, a.getModuleId());
            ps.setInt(5, a.getSubjectId());
            ps.setInt(6, a.getTeacherId());
            ps.setInt(7, a.getMaxMarks());
            ps.setString(8, a.getSubmissionMethod());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Update assignment
    public boolean updateAssignment(Assignment a) {
        String sql = "UPDATE assignments SET title=?, question=?, keywords=?, max_marks=?, submission_method=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getQuestion());
            ps.setString(3, a.getKeywords());
            ps.setInt(4, a.getMaxMarks());
            ps.setString(5, a.getSubmissionMethod());
            ps.setInt(6, a.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Delete assignment
    public boolean deleteAssignment(int id) {
        String sql = "DELETE FROM assignments WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Map row to Assignment
    private Assignment mapRow(ResultSet rs) throws SQLException {
        Assignment a = new Assignment();
        a.setId(rs.getInt("id"));
        a.setTitle(rs.getString("title"));
        a.setQuestion(rs.getString("question"));
        a.setKeywords(rs.getString("keywords"));
        a.setModuleId(rs.getInt("module_id"));
        a.setSubjectId(rs.getInt("subject_id"));
        a.setTeacherId(rs.getInt("teacher_id"));
        a.setMaxMarks(rs.getInt("max_marks"));
        a.setSubmissionMethod(rs.getString("submission_method"));
        try { a.setModuleName(rs.getString("module_name")); } catch (Exception ignored) {}
        try { a.setSubjectName(rs.getString("subject_name")); } catch (Exception ignored) {}
        return a;
    }
}
