package utils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * KeywordMatcher - Evaluates student submissions by matching keywords
 * This is the MAIN evaluation method. No AI or external API is used.
 */
public class KeywordMatcher {

    /**
     * Match keywords in student's answer text
     * @param answerText  - student's submitted text
     * @param keywordsCsv - comma-separated keywords from teacher
     * @param maxMarks    - maximum marks for this assignment
     * @return EvaluationResult with marks and matched keywords
     */
    public static EvaluationResult evaluate(String answerText, String keywordsCsv, int maxMarks) {
        if (answerText == null || answerText.trim().isEmpty() ||
            keywordsCsv == null || keywordsCsv.trim().isEmpty()) {
            return new EvaluationResult(0, maxMarks, new ArrayList<>());
        }

        // Normalize text for comparison
        String normalizedAnswer = answerText.toLowerCase().replaceAll("[^a-z0-9\\s]", " ");

        // Parse keywords
        String[] keywords = keywordsCsv.split(",");
        List<String> matchedKeywords = new ArrayList<>();
        int totalKeywords = keywords.length;

        for (String keyword : keywords) {
            String kw = keyword.trim().toLowerCase();
            if (!kw.isEmpty() && normalizedAnswer.contains(kw)) {
                matchedKeywords.add(keyword.trim());
            }
        }

        // Calculate marks proportionally
        int marksObtained = 0;
        if (totalKeywords > 0) {
            marksObtained = (int) Math.round(((double) matchedKeywords.size() / totalKeywords) * maxMarks);
        }

        return new EvaluationResult(marksObtained, maxMarks, matchedKeywords);
    }

    /**
     * Inner class to hold evaluation result
     */
    public static class EvaluationResult {
        private final int marksObtained;
        private final int maxMarks;
        private final List<String> matchedKeywords;

        public EvaluationResult(int marksObtained, int maxMarks, List<String> matchedKeywords) {
            this.marksObtained = marksObtained;
            this.maxMarks = maxMarks;
            this.matchedKeywords = matchedKeywords;
        }

        public int getMarksObtained() { return marksObtained; }
        public int getMaxMarks() { return maxMarks; }
        public List<String> getMatchedKeywords() { return matchedKeywords; }

        public String getMatchedKeywordsAsString() {
            return String.join(", ", matchedKeywords);
        }

        public int getMatchCount() { return matchedKeywords.size(); }

        public double getPercentage() {
            if (maxMarks == 0) return 0;
            return ((double) marksObtained / maxMarks) * 100;
        }
    }
}
