package model;

/**
 * Submission Model - Student's assignment submission
 */
public class Submission {
    private int id;
    private int studentId;
    private int assignmentId;
    private String filePath;
    private String textContent;
    private String status;      // PENDING, EVALUATED, COPIED, REJECTED
    private String submittedAt;
    private String studentName; // joined
    private String assignmentTitle; // joined

    public Submission() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public String getTextContent() { return textContent; }
    public void setTextContent(String textContent) { this.textContent = textContent; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(String submittedAt) { this.submittedAt = submittedAt; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getAssignmentTitle() { return assignmentTitle; }
    public void setAssignmentTitle(String assignmentTitle) { this.assignmentTitle = assignmentTitle; }
}
