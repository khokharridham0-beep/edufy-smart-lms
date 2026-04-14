package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection - Provides JDBC connection to MySQL database
 */
public class DBConnection {

    private static final String DRIVER   = "com.mysql.cj.jdbc.Driver";
    private static final String URL      = "jdbc:mysql://localhost:3306/ai_assignment_system?useSSL=false&serverTimezone=UTC";
    private static final String USERNAME = "root";
    private static final String PASSWORD = ""; // Change to your MySQL password

    // Returns a new connection to the database
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(DRIVER);
            return DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found: " + e.getMessage());
        }
    }

    // Closes a connection safely
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignored) {}
        }
    }
}
