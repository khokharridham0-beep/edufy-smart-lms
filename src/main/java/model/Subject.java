package model;

/**
 * Subject Model
 */
public class Subject {
    private int id;
    private String name;
    private String description;
    private int teacherId;
    private String teacherName; // joined field
    private String createdAt;

    public Subject() {}

    public Subject(int id, String name, String description, int teacherId) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.teacherId = teacherId;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
