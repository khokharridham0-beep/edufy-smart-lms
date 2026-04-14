package model;

/**
 * Marks Model - Evaluated marks for a submission
 */
public class Marks {
    private int id;
    private int studentId;
    private int assignmentId;
    private int marksObtained;
    private int maxMarks;
    private String matchedKeywords;
    private int plagiarismScore;
    private String evaluatedAt;
    private String studentName;     // joined
    private String assignmentTitle; // joined

    public Marks() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public int getMarksObtained() { return marksObtained; }
    public void setMarksObtained(int marksObtained) { this.marksObtained = marksObtained; }

    public int getMaxMarks() { return maxMarks; }
    public void setMaxMarks(int maxMarks) { this.maxMarks = maxMarks; }

    public String getMatchedKeywords() { return matchedKeywords; }
    public void setMatchedKeywords(String matchedKeywords) { this.matchedKeywords = matchedKeywords; }

    public int getPlagiarismScore() { return plagiarismScore; }
    public void setPlagiarismScore(int plagiarismScore) { this.plagiarismScore = plagiarismScore; }

    public String getEvaluatedAt() { return evaluatedAt; }
    public void setEvaluatedAt(String evaluatedAt) { this.evaluatedAt = evaluatedAt; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getAssignmentTitle() { return assignmentTitle; }
    public void setAssignmentTitle(String assignmentTitle) { this.assignmentTitle = assignmentTitle; }
}
