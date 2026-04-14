package utils;

import java.util.*;

/**
 * PlagiarismChecker - Compares new submission against existing ones
 * Uses simple word-overlap similarity (Jaccard similarity) — no external API.
 */
public class PlagiarismChecker {

    // Threshold above which content is considered "copied" (80% similarity)
    private static final double PLAGIARISM_THRESHOLD = 0.80;

    /**
     * Check if a new submission is plagiarised
     * @param newText        - text content of new submission
     * @param existingTexts  - list of previously submitted texts for same assignment
     * @return PlagiarismResult with score and verdict
     */
    public static PlagiarismResult check(String newText, List<String> existingTexts) {
        if (newText == null || newText.trim().isEmpty() || existingTexts == null || existingTexts.isEmpty()) {
            return new PlagiarismResult(0, false);
        }

        double maxSimilarity = 0.0;

        for (String existing : existingTexts) {
            if (existing == null || existing.trim().isEmpty()) continue;
            double similarity = computeJaccardSimilarity(newText, existing);
            if (similarity > maxSimilarity) {
                maxSimilarity = similarity;
            }
        }

        int similarityScore = (int) Math.round(maxSimilarity * 100);
        boolean isCopied = maxSimilarity >= PLAGIARISM_THRESHOLD;

        return new PlagiarismResult(similarityScore, isCopied);
    }

    /**
     * Compute Jaccard Similarity between two texts
     * Jaccard = |Intersection| / |Union| of word sets
     */
    private static double computeJaccardSimilarity(String text1, String text2) {
        Set<String> set1 = tokenize(text1);
        Set<String> set2 = tokenize(text2);

        if (set1.isEmpty() && set2.isEmpty()) return 1.0;
        if (set1.isEmpty() || set2.isEmpty()) return 0.0;

        Set<String> intersection = new HashSet<>(set1);
        intersection.retainAll(set2);

        Set<String> union = new HashSet<>(set1);
        union.addAll(set2);

        return (double) intersection.size() / union.size();
    }

    /**
     * Tokenize and normalize text into a set of words
     */
    private static Set<String> tokenize(String text) {
        Set<String> words = new HashSet<>();
        if (text == null) return words;

        // Normalize: lowercase, remove punctuation, split by whitespace
        String[] tokens = text.toLowerCase()
                              .replaceAll("[^a-z0-9\\s]", " ")
                              .trim()
                              .split("\\s+");

        // Filter out very short words (stop words simplification)
        for (String token : tokens) {
            if (token.length() > 2) words.add(token);
        }
        return words;
    }

    /**
     * Inner class for plagiarism result
     */
    public static class PlagiarismResult {
        private final int similarityScore; // 0–100
        private final boolean copied;

        public PlagiarismResult(int similarityScore, boolean copied) {
            this.similarityScore = similarityScore;
            this.copied = copied;
        }

        public int getSimilarityScore() { return similarityScore; }
        public boolean isCopied() { return copied; }

        public String getVerdict() {
            if (copied) return "COPIED";
            if (similarityScore >= 50) return "SUSPICIOUS";
            return "ORIGINAL";
        }
    }
}
