package dao;

import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO - Handles all database operations for Users
 */
public class UserDAO {

    // Authenticate user by email and password
    public User authenticate(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Get user by ID
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Get user by email
    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Update password by email
    public boolean updatePasswordByEmail(String email, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // Get all users by role
    public List<User> getUsersByRole(String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, c.name AS subject_name FROM users u " +
                     "LEFT JOIN subjects c ON u.subject_id = c.id WHERE u.role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) users.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return users;
    }

    // Get all students
    public List<User> getAllStudents() { return getUsersByRole("STUDENT"); }

    // Get all teachers
    public List<User> getAllTeachers() { return getUsersByRole("TEACHER"); }

    // Add new user
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (name, email, password, role, subject_id) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getRole());
            if (user.getSubjectId() > 0) ps.setInt(5, user.getSubjectId());
            else ps.setNull(5, Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Update user
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET name=?, email=?, password=?, role=?, subject_id=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getRole());
            if (user.getSubjectId() > 0) ps.setInt(5, user.getSubjectId());
            else ps.setNull(5, Types.INTEGER);
            ps.setInt(6, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Delete user
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Count users by role
    public int countByRole(String role) {
        String sql = "SELECT COUNT(*) FROM users WHERE role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // Map ResultSet row to User object
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        
        String dbRole = rs.getString("role");
        u.setRole(dbRole != null ? dbRole.trim().toUpperCase() : null);
        
        u.setSubjectId(rs.getInt("subject_id"));
        return u;
    }
}
