package model;

/**
 * Module Model - Belongs to a Course
 */
public class Module {
    private int id;
    private String moduleName;
    private String chapterName;
    private String description;
    private int subjectId;
    private String subjectName; // joined field
    private String createdAt;

    public Module() {}

    public Module(int id, String moduleName, String chapterName, String description, int subjectId) {
        this.id = id;
        this.moduleName = moduleName;
        this.chapterName = chapterName;
        this.description = description;
        this.subjectId = subjectId;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getModuleName() { return moduleName; }
    public void setModuleName(String moduleName) { this.moduleName = moduleName; }

    public String getChapterName() { return chapterName; }
    public void setChapterName(String chapterName) { this.chapterName = chapterName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getSubjectId() { return subjectId; }
    public void setSubjectId(int subjectId) { this.subjectId = subjectId; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
