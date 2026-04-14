package controller;

import dao.QuizDAO;
import model.Quiz;
import model.QuizAttempt;
import model.QuizQuestion;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.util.List;

/**
 * QuizServlet - Student quiz start/submit with timer-based auto submission.
 */
@WebServlet("/quiz/*")
public class QuizServlet extends HttpServlet {

    private final QuizDAO quizDAO = new QuizDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User student = requireStudent(req, resp);
        if (student == null) return;

        String path = req.getPathInfo();
        if (path == null) path = "/start";

        switch (path) {
            case "/start":
                showQuiz(req, resp, student);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User student = requireStudent(req, resp);
        if (student == null) return;

        String path = req.getPathInfo();
        if (path == null) path = "";

        if ("/submit".equals(path)) {
            submitQuiz(req, resp, student);
        } else {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }

    private void showQuiz(HttpServletRequest req, HttpServletResponse resp, User student)
            throws IOException, ServletException {
        int quizId;
        try {
            quizId = Integer.parseInt(req.getParameter("quizId"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }

        Quiz quiz = quizDAO.getQuizById(quizId);
        if (quiz == null) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }

        List<QuizQuestion> questions = quizDAO.getQuizQuestions(quizId);
        if (questions == null || questions.isEmpty()) {
            String msg = URLEncoder.encode("Quiz has no questions.", StandardCharsets.UTF_8.name());
            resp.sendRedirect(req.getContextPath() + "/student/subjectDetails?subjectId=" + quiz.getSubjectId() + "&quizMsg=" + msg);
            return;
        }

        QuizAttempt attempt = quizDAO.getQuizAttempt(quizId, student.getId());
        int totalQuestions = quizDAO.getTotalQuestionCount(quizId);
        int maxScore = quizDAO.getMaxScore(quizId);

        if (attempt == null) {
            quizDAO.startQuizAttempt(quizId, student.getId(), totalQuestions, maxScore);
            attempt = quizDAO.getQuizAttempt(quizId, student.getId());
        }

        if (attempt != null && isFinalized(attempt)) {
            String msg = URLEncoder.encode("You already attempted this quiz.", StandardCharsets.UTF_8.name());
            resp.sendRedirect(req.getContextPath() + "/student/subjectDetails?subjectId=" + quiz.getSubjectId() + "&quizMsg=" + msg);
            return;
        }

        int remainingSeconds = computeRemainingSeconds(quiz.getDurationMinutes(), attempt);
        if (remainingSeconds <= 0) {
            quizDAO.submitQuizAttempt(quizId, student.getId(), 0, maxScore, 0, totalQuestions, true);
            String msg = URLEncoder.encode("Time over. Quiz auto-submitted with 0 marks.", StandardCharsets.UTF_8.name());
            resp.sendRedirect(req.getContextPath() + "/student/subjectDetails?subjectId=" + quiz.getSubjectId() + "&quizMsg=" + msg);
            return;
        }

        req.setAttribute("quiz", quiz);
        req.setAttribute("questions", questions);
        req.setAttribute("remainingSeconds", remainingSeconds);
        req.getRequestDispatcher("/student/takeQuiz.jsp").forward(req, resp);
    }

    private void submitQuiz(HttpServletRequest req, HttpServletResponse resp, User student)
            throws IOException {
        int quizId;
        try {
            quizId = Integer.parseInt(req.getParameter("quizId"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }

        Quiz quiz = quizDAO.getQuizById(quizId);
        if (quiz == null) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            return;
        }

        List<QuizQuestion> questions = quizDAO.getQuizQuestions(quizId);
        int totalQuestions = questions.size();
        int maxScore = quizDAO.getMaxScore(quizId);

        QuizAttempt attempt = quizDAO.getQuizAttempt(quizId, student.getId());
        if (attempt == null) {
            quizDAO.startQuizAttempt(quizId, student.getId(), totalQuestions, maxScore);
            attempt = quizDAO.getQuizAttempt(quizId, student.getId());
        }

        if (attempt != null && isFinalized(attempt)) {
            String msg = URLEncoder.encode("You already submitted this quiz.", StandardCharsets.UTF_8.name());
            resp.sendRedirect(req.getContextPath() + "/student/subjectDetails?subjectId=" + quiz.getSubjectId() + "&quizMsg=" + msg);
            return;
        }

        int remainingSeconds = computeRemainingSeconds(quiz.getDurationMinutes(), attempt);
        if (remainingSeconds <= 0) {
            quizDAO.submitQuizAttempt(quizId, student.getId(), 0, maxScore, 0, totalQuestions, true);
            String msg = URLEncoder.encode("Time over. Quiz auto-submitted with 0 marks.", StandardCharsets.UTF_8.name());
            resp.sendRedirect(req.getContextPath() + "/student/subjectDetails?subjectId=" + quiz.getSubjectId() + "&quizMsg=" + msg);
            return;
        }

        int answered = 0;
        int score = 0;

        for (QuizQuestion q : questions) {
            String ans = req.getParameter("q_" + q.getId());
            if (ans != null && !ans.trim().isEmpty()) {
                answered++;
                if (ans.trim().equalsIgnoreCase(q.getCorrectOption())) {
                    score += q.getMarks();
                }
            }
        }

        quizDAO.submitQuizAttempt(quizId, student.getId(), score, maxScore, answered, totalQuestions, false);
        String msg = URLEncoder.encode("Quiz submitted. Score: " + score + "/" + maxScore,
                StandardCharsets.UTF_8.name());
        resp.sendRedirect(req.getContextPath() + "/student/subjectDetails?subjectId=" + quiz.getSubjectId() + "&quizMsg=" + msg);
    }

    private int computeRemainingSeconds(int durationMinutes, QuizAttempt attempt) {
        if (attempt == null || attempt.getStartedAt() == null) return durationMinutes * 60;
        try {
            long started = Timestamp.valueOf(attempt.getStartedAt()).getTime();
            long elapsedSec = (System.currentTimeMillis() - started) / 1000L;
            return (durationMinutes * 60) - (int) elapsedSec;
        } catch (Exception e) {
            return durationMinutes * 60;
        }
    }

    private boolean isFinalized(QuizAttempt attempt) {
        if (attempt == null) return false;
        // answered_count starts at -1 while in progress; 0+ means submitted (even blank submit).
        return attempt.isAutoSubmitted() || attempt.getAnsweredCount() >= 0;
    }

    private User requireStudent(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!"STUDENT".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return null;
        }
        return user;
    }
}
