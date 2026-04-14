package model;

/**
 * QuizAttempt Model - one attempt per student per quiz.
 */
public class QuizAttempt {
    private int id;
    private int quizId;
    private int studentId;
    private String studentName;
    private String quizTitle;
    private int score;
    private int maxScore;
    private int answeredCount;
    private int totalQuestions;
    private int timeTakenSeconds;
    private boolean autoSubmitted;
    private String startedAt;
    private String submittedAt;

    public QuizAttempt() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getQuizId() { return quizId; }
    public void setQuizId(int quizId) { this.quizId = quizId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getQuizTitle() { return quizTitle; }
    public void setQuizTitle(String quizTitle) { this.quizTitle = quizTitle; }

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public int getMaxScore() { return maxScore; }
    public void setMaxScore(int maxScore) { this.maxScore = maxScore; }

    public int getAnsweredCount() { return answeredCount; }
    public void setAnsweredCount(int answeredCount) { this.answeredCount = answeredCount; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    public int getTimeTakenSeconds() { return timeTakenSeconds; }
    public void setTimeTakenSeconds(int timeTakenSeconds) { this.timeTakenSeconds = timeTakenSeconds; }

    public boolean isAutoSubmitted() { return autoSubmitted; }
    public void setAutoSubmitted(boolean autoSubmitted) { this.autoSubmitted = autoSubmitted; }

    public String getStartedAt() { return startedAt; }
    public void setStartedAt(String startedAt) { this.startedAt = startedAt; }

    public String getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(String submittedAt) { this.submittedAt = submittedAt; }
}
