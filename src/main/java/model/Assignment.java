package model;

/**
 * Assignment Model
 */
public class Assignment {
    private int id;
    private String title;
    private String question;
    private String keywords;   // comma-separated keywords
    private int moduleId;
    private int subjectId;
    private int teacherId;
    private int maxMarks;
    private String submissionMethod; // TEXT, FILE, IMAGE
    private String moduleName;  // joined
    private String subjectName;  // joined
    private String createdAt;

    public Assignment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getKeywords() { return keywords; }
    public void setKeywords(String keywords) { this.keywords = keywords; }

    public int getModuleId() { return moduleId; }
    public void setModuleId(int moduleId) { this.moduleId = moduleId; }

    public int getSubjectId() { return subjectId; }
    public void setSubjectId(int subjectId) { this.subjectId = subjectId; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public int getMaxMarks() { return maxMarks; }
    public void setMaxMarks(int maxMarks) { this.maxMarks = maxMarks; }

    public String getSubmissionMethod() { return submissionMethod; }
    public void setSubmissionMethod(String submissionMethod) { this.submissionMethod = submissionMethod; }

    public String getModuleName() { return moduleName; }
    public void setModuleName(String moduleName) { this.moduleName = moduleName; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
