package dao;

import model.Quiz;
import model.QuizAttempt;
import model.QuizQuestion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * QuizDAO - DB operations for quizzes, questions and attempts.
 */
public class QuizDAO {

    public List<Quiz> getQuizzesByTeacher(int teacherId) {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT q.*, m.module_name, s.name AS subject_name, " +
                     "(SELECT COUNT(*) FROM quiz_questions qq WHERE qq.quiz_id=q.id) AS question_count " +
                     "FROM quizzes q " +
                     "JOIN modules m ON q.module_id = m.id " +
                     "JOIN subjects s ON q.subject_id = s.id " +
                     "WHERE q.teacher_id = ? ORDER BY q.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapQuiz(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Quiz> getQuizzesByModule(int moduleId) {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT q.*, m.module_name, s.name AS subject_name, " +
                     "(SELECT COUNT(*) FROM quiz_questions qq WHERE qq.quiz_id=q.id) AS question_count " +
                     "FROM quizzes q " +
                     "JOIN modules m ON q.module_id = m.id " +
                     "JOIN subjects s ON q.subject_id = s.id " +
                     "WHERE q.module_id = ? ORDER BY q.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, moduleId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapQuiz(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Quiz getQuizById(int quizId) {
        String sql = "SELECT q.*, m.module_name, s.name AS subject_name, " +
                     "(SELECT COUNT(*) FROM quiz_questions qq WHERE qq.quiz_id=q.id) AS question_count " +
                     "FROM quizzes q " +
                     "JOIN modules m ON q.module_id = m.id " +
                     "JOIN subjects s ON q.subject_id = s.id " +
                     "WHERE q.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapQuiz(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<QuizQuestion> getQuizQuestions(int quizId) {
        List<QuizQuestion> list = new ArrayList<>();
        String sql = "SELECT * FROM quiz_questions WHERE quiz_id = ? ORDER BY id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapQuestion(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean createQuizWithQuestions(Quiz quiz, List<QuizQuestion> questions) {
        if (questions == null || questions.isEmpty()) return false;

        String quizSql = "INSERT INTO quizzes (title, description, module_id, subject_id, teacher_id, duration_minutes) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
        String qSql = "INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement qz = conn.prepareStatement(quizSql, Statement.RETURN_GENERATED_KEYS)) {
                qz.setString(1, quiz.getTitle());
                qz.setString(2, quiz.getDescription());
                qz.setInt(3, quiz.getModuleId());
                qz.setInt(4, quiz.getSubjectId());
                qz.setInt(5, quiz.getTeacherId());
                qz.setInt(6, quiz.getDurationMinutes());
                qz.executeUpdate();

                ResultSet keys = qz.getGeneratedKeys();
                if (!keys.next()) {
                    conn.rollback();
                    return false;
                }
                int quizId = keys.getInt(1);

                try (PreparedStatement qq = conn.prepareStatement(qSql)) {
                    for (QuizQuestion question : questions) {
                        qq.setInt(1, quizId);
                        qq.setString(2, question.getQuestionText());
                        qq.setString(3, question.getOptionA());
                        qq.setString(4, question.getOptionB());
                        qq.setString(5, question.getOptionC());
                        qq.setString(6, question.getOptionD());
                        qq.setString(7, question.getCorrectOption());
                        qq.setInt(8, question.getMarks());
                        qq.addBatch();
                    }
                    qq.executeBatch();
                }
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteQuiz(int quizId) {
        String sql = "DELETE FROM quizzes WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean isQuizOwnedByTeacher(int quizId, int teacherId) {
        String sql = "SELECT id FROM quizzes WHERE id = ? AND teacher_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ps.setInt(2, teacherId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public int getTotalQuestionCount(int quizId) {
        String sql = "SELECT COUNT(*) FROM quiz_questions WHERE quiz_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int getMaxScore(int quizId) {
        String sql = "SELECT COALESCE(SUM(marks), 0) FROM quiz_questions WHERE quiz_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public QuizAttempt getQuizAttempt(int quizId, int studentId) {
        String sql = "SELECT * FROM quiz_attempts WHERE quiz_id = ? AND student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ps.setInt(2, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapAttempt(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean startQuizAttempt(int quizId, int studentId, int totalQuestions, int maxScore) {
        String sql = "INSERT INTO quiz_attempts (quiz_id, student_id, score, max_score, answered_count, total_questions, auto_submitted, started_at, submitted_at) " +
                     "VALUES (?, ?, 0, ?, -1, ?, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) " +
                     "ON DUPLICATE KEY UPDATE id=id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ps.setInt(2, studentId);
            ps.setInt(3, maxScore);
            ps.setInt(4, totalQuestions);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public List<QuizAttempt> getQuizAttemptsByQuiz(int quizId, int teacherId) {
        List<QuizAttempt> list = new ArrayList<>();
        String sql = "SELECT qa.*, u.name AS student_name, q.title AS quiz_title " +
                     "FROM quiz_attempts qa " +
                     "JOIN users u ON qa.student_id = u.id " +
                     "JOIN quizzes q ON qa.quiz_id = q.id " +
                     "WHERE qa.quiz_id = ? AND q.teacher_id = ? " +
                     "ORDER BY qa.submitted_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ps.setInt(2, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapAttempt(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean submitQuizAttempt(int quizId, int studentId, int score, int maxScore,
                                     int answeredCount, int totalQuestions, boolean autoSubmitted) {
        String sql = "UPDATE quiz_attempts SET score=?, max_score=?, answered_count=?, total_questions=?, " +
                     "auto_submitted=?, submitted_at=CURRENT_TIMESTAMP WHERE quiz_id=? AND student_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, score);
            ps.setInt(2, maxScore);
            ps.setInt(3, answeredCount);
            ps.setInt(4, totalQuestions);
            ps.setBoolean(5, autoSubmitted);
            ps.setInt(6, quizId);
            ps.setInt(7, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private Quiz mapQuiz(ResultSet rs) throws SQLException {
        Quiz q = new Quiz();
        q.setId(rs.getInt("id"));
        q.setTitle(rs.getString("title"));
        q.setDescription(rs.getString("description"));
        q.setModuleId(rs.getInt("module_id"));
        q.setSubjectId(rs.getInt("subject_id"));
        q.setTeacherId(rs.getInt("teacher_id"));
        q.setDurationMinutes(rs.getInt("duration_minutes"));
        q.setCreatedAt(rs.getString("created_at"));
        try { q.setModuleName(rs.getString("module_name")); } catch (Exception ignored) {}
        try { q.setSubjectName(rs.getString("subject_name")); } catch (Exception ignored) {}
        try { q.setQuestionCount(rs.getInt("question_count")); } catch (Exception ignored) {}
        return q;
    }

    private QuizQuestion mapQuestion(ResultSet rs) throws SQLException {
        QuizQuestion q = new QuizQuestion();
        q.setId(rs.getInt("id"));
        q.setQuizId(rs.getInt("quiz_id"));
        q.setQuestionText(rs.getString("question_text"));
        q.setOptionA(rs.getString("option_a"));
        q.setOptionB(rs.getString("option_b"));
        q.setOptionC(rs.getString("option_c"));
        q.setOptionD(rs.getString("option_d"));
        q.setCorrectOption(rs.getString("correct_option"));
        q.setMarks(rs.getInt("marks"));
        return q;
    }

    private QuizAttempt mapAttempt(ResultSet rs) throws SQLException {
        QuizAttempt a = new QuizAttempt();
        a.setId(rs.getInt("id"));
        a.setQuizId(rs.getInt("quiz_id"));
        a.setStudentId(rs.getInt("student_id"));
        try { a.setStudentName(rs.getString("student_name")); } catch (Exception ignored) {}
        try { a.setQuizTitle(rs.getString("quiz_title")); } catch (Exception ignored) {}
        a.setScore(rs.getInt("score"));
        a.setMaxScore(rs.getInt("max_score"));
        a.setAnsweredCount(rs.getInt("answered_count"));
        a.setTotalQuestions(rs.getInt("total_questions"));
        a.setAutoSubmitted(rs.getBoolean("auto_submitted"));
        a.setStartedAt(rs.getString("started_at"));
        a.setSubmittedAt(rs.getString("submitted_at"));
        return a;
    }
}
