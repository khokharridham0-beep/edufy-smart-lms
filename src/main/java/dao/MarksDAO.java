package dao;

import model.Marks;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MarksDAO - Handles all database operations for Marks
 */
public class MarksDAO {

    // Save marks (insert or update)
    public boolean saveMarks(Marks marks) {
        // Check if marks already exist for this student+assignment
        String checkSql = "SELECT id FROM marks WHERE student_id = ? AND assignment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement check = conn.prepareStatement(checkSql)) {
            check.setInt(1, marks.getStudentId());
            check.setInt(2, marks.getAssignmentId());
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                // Update existing
                String updateSql = "UPDATE marks SET marks_obtained=?, max_marks=?, matched_keywords=?, plagiarism_score=? " +
                                   "WHERE student_id=? AND assignment_id=?";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, marks.getMarksObtained());
                    ps.setInt(2, marks.getMaxMarks());
                    ps.setString(3, marks.getMatchedKeywords());
                    ps.setInt(4, marks.getPlagiarismScore());
                    ps.setInt(5, marks.getStudentId());
                    ps.setInt(6, marks.getAssignmentId());
                    return ps.executeUpdate() > 0;
                }
            } else {
                // Insert new
                String insertSql = "INSERT INTO marks (student_id, assignment_id, marks_obtained, max_marks, matched_keywords, plagiarism_score) " +
                                   "VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, marks.getStudentId());
                    ps.setInt(2, marks.getAssignmentId());
                    ps.setInt(3, marks.getMarksObtained());
                    ps.setInt(4, marks.getMaxMarks());
                    ps.setString(5, marks.getMatchedKeywords());
                    ps.setInt(6, marks.getPlagiarismScore());
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Get marks for a student in an assignment
    public Marks getMarks(int studentId, int assignmentId) {
        String sql = "SELECT mk.*, u.name AS student_name, a.title AS assignment_title " +
                     "FROM marks mk " +
                     "JOIN users u ON mk.student_id = u.id " +
                     "JOIN assignments a ON mk.assignment_id = a.id " +
                     "WHERE mk.student_id = ? AND mk.assignment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, assignmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Get all marks for a student
    public List<Marks> getMarksByStudent(int studentId) {
        List<Marks> list = new ArrayList<>();
        String sql = "SELECT mk.*, u.name AS student_name, a.title AS assignment_title " +
                     "FROM marks mk " +
                     "JOIN users u ON mk.student_id = u.id " +
                     "JOIN assignments a ON mk.assignment_id = a.id " +
                     "WHERE mk.student_id = ? ORDER BY mk.evaluated_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get all marks for an assignment (teacher view)
    public List<Marks> getMarksByAssignment(int assignmentId) {
        List<Marks> list = new ArrayList<>();
        String sql = "SELECT mk.*, u.name AS student_name, a.title AS assignment_title " +
                     "FROM marks mk " +
                     "JOIN users u ON mk.student_id = u.id " +
                     "JOIN assignments a ON mk.assignment_id = a.id " +
                     "WHERE mk.assignment_id = ? ORDER BY mk.marks_obtained DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Map row to Marks
    private Marks mapRow(ResultSet rs) throws SQLException {
        Marks m = new Marks();
        m.setId(rs.getInt("id"));
        m.setStudentId(rs.getInt("student_id"));
        m.setAssignmentId(rs.getInt("assignment_id"));
        m.setMarksObtained(rs.getInt("marks_obtained"));
        m.setMaxMarks(rs.getInt("max_marks"));
        m.setMatchedKeywords(rs.getString("matched_keywords"));
        m.setPlagiarismScore(rs.getInt("plagiarism_score"));
        m.setEvaluatedAt(rs.getString("evaluated_at"));
        try { m.setStudentName(rs.getString("student_name")); } catch (Exception ignored) {}
        try { m.setAssignmentTitle(rs.getString("assignment_title")); } catch (Exception ignored) {}
        return m;
    }
}
