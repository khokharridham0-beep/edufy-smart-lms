package dao;

import model.Submission;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * SubmissionDAO - Handles all database operations for Submissions
 */
public class SubmissionDAO {

    // Add new submission, returns generated ID
    public int addSubmission(Submission sub) {
        String sql = "INSERT INTO submissions (student_id, assignment_id, file_path, text_content, status) " +
                     "VALUES (?, ?, ?, ?, 'PENDING')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, sub.getStudentId());
            ps.setInt(2, sub.getAssignmentId());
            ps.setString(3, sub.getFilePath());
            ps.setString(4, sub.getTextContent());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    // Get submission by ID
    public Submission getSubmissionById(int id) {
        String sql = "SELECT s.*, u.name AS student_name, a.title AS assignment_title " +
                     "FROM submissions s " +
                     "JOIN users u ON s.student_id = u.id " +
                     "JOIN assignments a ON s.assignment_id = a.id WHERE s.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Get all submissions for an assignment (for teacher/plagiarism check)
    public List<Submission> getSubmissionsByAssignment(int assignmentId) {
        List<Submission> list = new ArrayList<>();
        String sql = "SELECT s.*, u.name AS student_name, a.title AS assignment_title " +
                     "FROM submissions s " +
                     "JOIN users u ON s.student_id = u.id " +
                     "JOIN assignments a ON s.assignment_id = a.id WHERE s.assignment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Get submissions by student
    public List<Submission> getSubmissionsByStudent(int studentId) {
        List<Submission> list = new ArrayList<>();
        String sql = "SELECT s.*, u.name AS student_name, a.title AS assignment_title " +
                     "FROM submissions s " +
                     "JOIN users u ON s.student_id = u.id " +
                     "JOIN assignments a ON s.assignment_id = a.id WHERE s.student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Check if student already submitted for an assignment
    public Submission getStudentSubmission(int studentId, int assignmentId) {
        String sql = "SELECT s.*, u.name AS student_name, a.title AS assignment_title " +
                     "FROM submissions s " +
                     "JOIN users u ON s.student_id = u.id " +
                     "JOIN assignments a ON s.assignment_id = a.id " +
                     "WHERE s.student_id = ? AND s.assignment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, assignmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Update submission status
    public boolean updateStatus(int submissionId, String status) {
        String sql = "UPDATE submissions SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, submissionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Get all text content for a given assignment (for plagiarism check)
    public List<String> getAllTextContents(int assignmentId, int excludeStudentId) {
        List<String> texts = new ArrayList<>();
        String sql = "SELECT text_content FROM submissions WHERE assignment_id = ? AND student_id != ? AND text_content IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ps.setInt(2, excludeStudentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) texts.add(rs.getString("text_content"));
        } catch (SQLException e) { e.printStackTrace(); }
        return texts;
    }

    // Map row to Submission
    private Submission mapRow(ResultSet rs) throws SQLException {
        Submission s = new Submission();
        s.setId(rs.getInt("id"));
        s.setStudentId(rs.getInt("student_id"));
        s.setAssignmentId(rs.getInt("assignment_id"));
        s.setFilePath(rs.getString("file_path"));
        s.setTextContent(rs.getString("text_content"));
        s.setStatus(rs.getString("status"));
        s.setSubmittedAt(rs.getString("submitted_at"));
        try { s.setStudentName(rs.getString("student_name")); } catch (Exception ignored) {}
        try { s.setAssignmentTitle(rs.getString("assignment_title")); } catch (Exception ignored) {}
        return s;
    }
}
