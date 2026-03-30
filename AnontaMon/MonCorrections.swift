//
//  MonCorrections.swift
//  AnontaMon
//
//  Auto-correction and auto-capitalization engine for Mon language.
//  Uses a dictionary of common corrections and sentence boundary detection.
//

import Foundation

final class MonCorrections {
    
    static let shared = MonCorrections()
    
    // MARK: - Common Mon Corrections Dictionary
    // Maps common misspellings/typos to correct forms
    private var corrections: [String: String] = [
        // Common Mon word corrections
        "ပၟိင်": "ပၟိၚ်",
        "မန်": "မန်",
        // Add more corrections as needed
    ]
    
    // Mon sentence-ending characters
    private let sentenceEndings: Set<Character> = ["။", "?", "!", ".", "\n"]
    
    // Mon word boundary characters  
    private let wordBoundaries: Set<Character> = [" ", "။", "\n", "\t"]
    
    private init() {
        loadCustomDictionary()
    }
    
    // MARK: - Load Custom Dictionary
    
    /// Load corrections from a plain text dictionary file bundled with the extension.
    /// Format: each line is "wrong=correct"
    private func loadCustomDictionary() {
        guard let url = Bundle.main.url(forResource: "MonCorrections", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
            let parts = trimmed.components(separatedBy: "=")
            if parts.count == 2 {
                corrections[parts[0].trimmingCharacters(in: .whitespaces)] =
                    parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
    }
    
    // MARK: - Auto-Correction
    
    /// Check if the last word typed needs correction.
    /// Returns the correction or nil if no correction needed.
    func checkCorrection(for context: String) -> (original: String, replacement: String)? {
        let lastWord = extractLastWord(from: context)
        guard !lastWord.isEmpty else { return nil }
        
        if let corrected = corrections[lastWord], corrected != lastWord {
            return (original: lastWord, replacement: corrected)
        }
        
        return nil
    }
    
    /// Extract the last word from the text context
    private func extractLastWord(from text: String) -> String {
        var word = ""
        for char in text.reversed() {
            if wordBoundaries.contains(char) {
                break
            }
            word.insert(char, at: word.startIndex)
        }
        return word
    }
    
    // MARK: - Auto-Capitalization
    
    /// Determine if the next character should be auto-capitalized.
    /// For Mon language, this checks if we're at the beginning of a sentence.
    func shouldCapitalize(context: String) -> Bool {
        // Mon doesn't have uppercase/lowercase in the same way as Latin scripts.
        // However, we can detect sentence boundaries for potential formatting.
        let trimmed = context.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Capitalize at start of input
        if trimmed.isEmpty { return true }
        
        // Capitalize after sentence-ending punctuation
        if let lastChar = trimmed.last, sentenceEndings.contains(lastChar) {
            return true
        }
        
        return false
    }
    
    // MARK: - Suggestion Engine (Basic)
    
    /// Get word suggestions based on prefix.
    /// Returns up to 3 suggestions.
    func suggestions(for prefix: String) -> [String] {
        guard prefix.count >= 2 else { return [] }
        
        // Simple prefix matching from corrections dictionary values
        let matches = corrections.values.filter { $0.hasPrefix(prefix) && $0 != prefix }
        return Array(Set(matches)).prefix(3).map { String($0) }
    }
}
