package controller;

import dao.*;
import model.*;
import model.Module;
import utils.*;

import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import javax.imageio.ImageIO;
import java.io.*;
import java.awt.image.BufferedImage;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.apache.pdfbox.text.PDFTextStripper;

/**
 * SubmissionServlet - Handles student assignment submissions with file upload
 * Uses MultipartConfig for file handling
 */
@WebServlet("/submit")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB
    maxFileSize       = 10 * 1024 * 1024,  // 10 MB
    maxRequestSize    = 15 * 1024 * 1024   // 15 MB
)
public class SubmissionServlet extends HttpServlet {

    private final SubmissionDAO submissionDAO = new SubmissionDAO();
    private final AssignmentDAO assignmentDAO = new AssignmentDAO();
    private final MarksDAO      marksDAO      = new MarksDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); return;
        }

        User student = (User) session.getAttribute("user");
        if (!"STUDENT".equals(student.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); return;
        }

        int assignmentId = Integer.parseInt(req.getParameter("assignment_id"));
        Assignment assignment = assignmentDAO.getAssignmentById(assignmentId);
        if (assignment == null) {
            req.getSession().setAttribute("submitMsg", "Assignment not found.");
            resp.sendRedirect(req.getContextPath() + "/student/results");
            return;
        }

        String allowedMethod = normalizeSubmissionMethod(assignment.getSubmissionMethod());
        String requestedMethod = normalizeSubmissionMethod(req.getParameter("submission_method"));
        if (!allowedMethod.equals(requestedMethod)) {
            req.getSession().setAttribute("submitMsg", "Invalid submission type for this assignment.");
            resp.sendRedirect(req.getContextPath() + "/student/submitAssignment?assignmentId=" + assignmentId);
            return;
        }

        String textContent = extractSubmittedText(req);
        String uploadDir = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "submissions";

        // Create uploads directory if not exists
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        // Check if student already submitted
        Submission existing = submissionDAO.getStudentSubmission(student.getId(), assignmentId);
        if (existing != null) {
            req.getSession().setAttribute("submitError", "You have already submitted this assignment.");
            resp.sendRedirect(req.getContextPath() + "/student/results");
            return;
        }

        // Handle file upload
        String savedFilePath = null;
        String uploadedExt = null;
        Part filePart = req.getPart("submission_file");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = extractFileName(filePart);
            if (fileName != null && !fileName.isEmpty()) {
                uploadedExt = getExtension(fileName);

                if ("TEXT".equals(allowedMethod)) {
                    req.getSession().setAttribute("submitMsg", "This assignment accepts text answer only.");
                    resp.sendRedirect(req.getContextPath() + "/student/submitAssignment?assignmentId=" + assignmentId);
                    return;
                }

                if (!isAllowedFileType(allowedMethod, uploadedExt)) {
                    req.getSession().setAttribute("submitMsg", "Invalid file type for selected submission method.");
                    resp.sendRedirect(req.getContextPath() + "/student/submitAssignment?assignmentId=" + assignmentId);
                    return;
                }

                String uniqueName = student.getId() + "_" + assignmentId + "_" + System.currentTimeMillis() + "_" + fileName;
                String filePath = uploadDir + File.separator + uniqueName;
                filePart.write(filePath);
                savedFilePath = "uploads/submissions/" + uniqueName;

                String ext = fileName.toLowerCase();
                if (ext.endsWith(".pdf") || ext.endsWith(".txt") || ext.endsWith(".docx")) {
                    // Extract text from supported files when student didn't provide manual text.
                    if (textContent == null || textContent.trim().isEmpty()) {
                        textContent = extractTextFromFile(filePath, ext);
                    }
                }
            }
        }

        if ("TEXT".equals(allowedMethod) && (textContent == null || textContent.trim().isEmpty())) {
            req.getSession().setAttribute("submitMsg", "This assignment requires text answer.");
            resp.sendRedirect(req.getContextPath() + "/student/submitAssignment?assignmentId=" + assignmentId);
            return;
        }
        if (("FILE".equals(allowedMethod) || "IMAGE".equals(allowedMethod)) && (savedFilePath == null || savedFilePath.trim().isEmpty())) {
            req.getSession().setAttribute("submitMsg", "This assignment requires file upload.");
            resp.sendRedirect(req.getContextPath() + "/student/submitAssignment?assignmentId=" + assignmentId);
            return;
        }

        // Build submission object
        Submission sub = new Submission();
        sub.setStudentId(student.getId());
        sub.setAssignmentId(assignmentId);
        sub.setFilePath(savedFilePath);
        sub.setTextContent(textContent);

        // ─── Plagiarism Check ────────────────────────────────────────────
        List<String> existingTexts = submissionDAO.getAllTextContents(assignmentId, student.getId());
        PlagiarismChecker.PlagiarismResult plagResult = PlagiarismChecker.check(textContent, existingTexts);

        if (plagResult.isCopied()) {
            sub.setStatus("COPIED");
            int submissionId = submissionDAO.addSubmission(sub);

            // Save 0 marks due to plagiarism
            Marks marks = new Marks();
            marks.setStudentId(student.getId());
            marks.setAssignmentId(assignmentId);
            marks.setMarksObtained(0);
            marks.setMaxMarks(assignment != null ? assignment.getMaxMarks() : 10);
            marks.setMatchedKeywords("PLAGIARISM DETECTED");
            marks.setPlagiarismScore(plagResult.getSimilarityScore());
            marksDAO.saveMarks(marks);

            req.getSession().setAttribute("submitMsg",
                "⚠ Your submission was flagged as COPIED (" + plagResult.getSimilarityScore() + "% similar). Marks: 0");
        } else {
            // ─── Keyword Matching Evaluation ─────────────────────────────────
            sub.setStatus("EVALUATED");
            submissionDAO.addSubmission(sub);

            KeywordMatcher.EvaluationResult evalResult = null;
            if (assignment != null && textContent != null && !textContent.trim().isEmpty()) {
                evalResult = KeywordMatcher.evaluate(textContent, assignment.getKeywords(), assignment.getMaxMarks());
            }

            Marks marks = new Marks();
            marks.setStudentId(student.getId());
            marks.setAssignmentId(assignmentId);
            marks.setMarksObtained(evalResult != null ? evalResult.getMarksObtained() : 0);
            marks.setMaxMarks(assignment != null ? assignment.getMaxMarks() : 10);
            marks.setMatchedKeywords(evalResult != null ? evalResult.getMatchedKeywordsAsString() : "");
            marks.setPlagiarismScore(plagResult.getSimilarityScore());
            marksDAO.saveMarks(marks);

            String msg = evalResult != null
                ? "✅ Submitted! Marks: " + evalResult.getMarksObtained() + "/" + evalResult.getMaxMarks()
                  + " | Matched Keywords: " + evalResult.getMatchCount()
                : "✅ Submitted! (File uploaded — text evaluation skipped)";
            req.getSession().setAttribute("submitMsg", msg);
        }

        resp.sendRedirect(req.getContextPath() + "/student/results");
    }

    private String extractFileName(Part part) {
        String submitted = part.getSubmittedFileName();
        if (submitted != null && !submitted.trim().isEmpty()) {
            return new File(submitted).getName();
        }

        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) return null;
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                String name = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                return new File(name).getName(); // strip path if any
            }
        }
        return null;
    }

    private String getExtension(String fileName) {
        if (fileName == null) return "";
        int idx = fileName.lastIndexOf('.');
        if (idx < 0 || idx == fileName.length() - 1) return "";
        return fileName.substring(idx).toLowerCase();
    }

    private boolean isAllowedFileType(String method, String ext) {
        Set<String> fileTypes = new HashSet<>(Arrays.asList(".pdf", ".docx", ".txt"));
        Set<String> imageTypes = new HashSet<>(Arrays.asList(".jpg", ".jpeg", ".png", ".webp", ".jfif"));
        if ("FILE".equals(method)) return fileTypes.contains(ext);
        if ("IMAGE".equals(method)) return imageTypes.contains(ext);
        return false;
    }

    private String readFile(String filePath) {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line).append(" ");
        } catch (IOException ignored) {}
        return sb.toString();
    }

    private String extractTextFromFile(String filePath, String ext) {
        if (ext == null) return null;
        if (ext.endsWith(".txt")) return readFile(filePath);
        if (ext.endsWith(".docx")) return extractDocText(filePath);
        if (ext.endsWith(".pdf")) {
            String pdfText = extractPdfText(filePath);
            if (pdfText != null && !pdfText.trim().isEmpty()) return pdfText;
            return extractPdfTextWithOcr(filePath);
        }
        return null;
    }

    private String extractDocText(String filePath) {
        // .doc parsing is not supported without extra binary parsers.
        if (filePath == null || !filePath.toLowerCase().endsWith(".docx")) return null;
        try (ZipFile zip = new ZipFile(filePath)) {
            StringBuilder text = new StringBuilder();

            // Collect text from the main document and common related parts.
            java.util.Enumeration<? extends ZipEntry> entries = zip.entries();
            while (entries.hasMoreElements()) {
                ZipEntry entry = entries.nextElement();
                String name = entry.getName();
                if (entry.isDirectory()) continue;
                if (!name.startsWith("word/")) continue;
                if (!name.endsWith(".xml")) continue;

                String xml;
                try (InputStream in = zip.getInputStream(entry)) {
                    xml = new String(in.readAllBytes(), StandardCharsets.UTF_8);
                }

                appendDocxText(xml, text);
            }

            String cleaned = text.toString().replaceAll("\\s+", " ").trim();
            return cleaned.isEmpty() ? null : cleaned;
        } catch (Exception ignored) {
            return null;
        }
    }

    private void appendDocxText(String xml, StringBuilder out) {
        if (xml == null || xml.isEmpty()) return;

        Pattern textPattern = Pattern.compile("<w:t[^>]*>(.*?)</w:t>", Pattern.DOTALL);
        Matcher m = textPattern.matcher(xml);
        while (m.find()) {
            String token = decodeXmlEntities(m.group(1));
            if (token != null && !token.trim().isEmpty()) {
                out.append(token).append(' ');
            }
        }
    }

    private String decodeXmlEntities(String s) {
        if (s == null) return null;
        return s.replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">")
                .replace("&quot;", "\"")
                .replace("&apos;", "'");
    }

    private String extractPdfText(String filePath) {
        try (PDDocument document = PDDocument.load(new File(filePath))) {
            PDFTextStripper stripper = new PDFTextStripper();
            String text = stripper.getText(document);
            return text != null ? text.trim() : null;
        } catch (Exception ignored) {
            return null;
        }
    }

    private String extractPdfTextWithOcr(String filePath) {
        try (PDDocument document = PDDocument.load(new File(filePath))) {
            PDFRenderer renderer = new PDFRenderer(document);
            StringBuilder allText = new StringBuilder();

            for (int i = 0; i < document.getNumberOfPages(); i++) {
                BufferedImage image = renderer.renderImageWithDPI(i, 200);
                File tempImage = File.createTempFile("ocr_page_", ".png");
                try {
                    ImageIO.write(image, "png", tempImage);
                    String pageText = runTesseract(tempImage);
                    if (pageText != null && !pageText.trim().isEmpty()) {
                        allText.append(pageText).append(' ');
                    }
                } finally {
                    tempImage.delete();
                }
            }

            String finalText = allText.toString().trim();
            return finalText.isEmpty() ? null : finalText;
        } catch (Exception ignored) {
            return null;
        }
    }

    private String runTesseract(File imageFile) {
        ProcessBuilder pb = new ProcessBuilder("tesseract", imageFile.getAbsolutePath(), "stdout", "-l", "eng");
        pb.redirectErrorStream(true);
        try {
            Process p = pb.start();
            String output;
            try (InputStream is = p.getInputStream()) {
                output = new String(is.readAllBytes());
            }
            int exit = p.waitFor();
            if (exit != 0) return null;
            return output;
        } catch (Exception ignored) {
            return null;
        }
    }

    /**
     * The submission form can send multiple text_content fields (hidden tabs).
     * Pick the first non-empty value so keyword evaluation always gets the real answer text.
     */
    private String extractSubmittedText(HttpServletRequest req) {
        String[] values = req.getParameterValues("text_content");
        if (values == null || values.length == 0) return null;
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }
        return null;
    }

    private String normalizeSubmissionMethod(String method) {
        if (method == null) return "TEXT";
        String normalized = method.trim().toUpperCase();
        switch (normalized) {
            case "TEXT":
            case "FILE":
            case "IMAGE":
                return normalized;
            default:
                return "TEXT";
        }
    }
}
