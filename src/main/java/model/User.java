package model;

/**
 * User Model - Represents Admin, Teacher, or Student
 */
public class User {
    private int id;
    private String name;
    private String email;
    private String password;
    private String role;       // ADMIN, TEACHER, STUDENT
    private int subjectId;
    private String createdAt;

    public User() {}

    public User(int id, String name, String email, String password, String role, int subjectId) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.subjectId = subjectId;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public int getSubjectId() { return subjectId; }
    public void setSubjectId(int subjectId) { this.subjectId = subjectId; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "User{id=" + id + ", name=" + name + ", role=" + role + "}";
    }
}
