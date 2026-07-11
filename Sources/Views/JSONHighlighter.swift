//
//  JSONHighlighter.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 11/07/26.
//

import SwiftUI

public struct JSONHighlighter {
    
    /// Highlights a JSON string with monochrome style and returns a styled AttributedString.
    public static func highlight(_ jsonString: String) -> AttributedString {
        // Try to pretty-print first
        let formattedString: String
        if let data = jsonString.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            formattedString = prettyString
        } else {
            formattedString = jsonString
        }
        
        var attributed = AttributedString(formattedString)
        attributed.foregroundColor = Color.white.opacity(0.4) // Default punctuation is mid-gray
        attributed.font = .system(.caption, design: .monospaced)
        
        let length = formattedString.count
        guard length > 0 else { return attributed }
        
        // Monochrome palette
        let keyColor = Color.white // Bold Pure White
        let stringColor = Color.white.opacity(0.85) // High-readability light gray
        let numberColor = Color.white.opacity(0.65) // Light-mid gray
        let booleanColor = Color.white.opacity(0.65) // Light-mid gray
        let nullColor = Color.white.opacity(0.3) // Faint gray
        
        // 1. Highlight Keys: "key":
        if let keyRegex = try? NSRegularExpression(pattern: "\"([^\"]+)\"\\s*:", options: []) {
            let matches = keyRegex.matches(in: formattedString, options: [], range: NSRange(location: 0, length: length))
            for match in matches {
                if let matchRange = Range(match.range, in: formattedString) {
                    if let colonIndex = formattedString[matchRange].firstIndex(of: ":") {
                        let keyRange = matchRange.lowerBound..<colonIndex
                        if let attrRange = Range<AttributedString.Index>(keyRange, in: attributed) {
                            attributed[attrRange].foregroundColor = keyColor
                            attributed[attrRange].inlinePresentationIntent = .stronglyEmphasized // Bold keys
                        }
                    }
                }
            }
        }
        
        // 2. Highlight String Values: "value" (excluding keys)
        if let stringRegex = try? NSRegularExpression(pattern: "\"([^\"]*)\"", options: []) {
            let matches = stringRegex.matches(in: formattedString, options: [], range: NSRange(location: 0, length: length))
            for match in matches {
                if let matchRange = Range(match.range, in: formattedString) {
                    let nextIndex = matchRange.upperBound
                    let remainingRange = nextIndex..<formattedString.endIndex
                    var isKey = false
                    if let colonRange = formattedString.range(of: ":", options: [], range: remainingRange) {
                        let intermediate = formattedString[nextIndex..<colonRange.lowerBound]
                        if intermediate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            isKey = true
                        }
                    }
                    
                    if !isKey {
                        if let attrRange = Range<AttributedString.Index>(matchRange, in: attributed) {
                            attributed[attrRange].foregroundColor = stringColor
                        }
                    }
                }
            }
        }
        
        // 3. Highlight Numbers, Booleans and Null
        if let valRegex = try? NSRegularExpression(pattern: "\\b(-?\\d+(\\.\\d+)?([eE][+-]?\\d+)?|true|false|null)\\b", options: []) {
            let matches = valRegex.matches(in: formattedString, options: [], range: NSRange(location: 0, length: length))
            let nsString = formattedString as NSString
            for match in matches {
                let word = nsString.substring(with: match.range)
                let color: Color
                if word == "true" || word == "false" {
                    color = booleanColor
                } else if word == "null" {
                    color = nullColor
                } else {
                    color = numberColor
                }
                
                if let matchRange = Range(match.range, in: formattedString) {
                    if let attrRange = Range<AttributedString.Index>(matchRange, in: attributed) {
                        // Only apply color if the token currently has the default punctuation color
                        if attributed[attrRange].foregroundColor == Color.white.opacity(0.4) {
                            attributed[attrRange].foregroundColor = color
                        }
                    }
                }
            }
        }
        
        return attributed
    }
}
