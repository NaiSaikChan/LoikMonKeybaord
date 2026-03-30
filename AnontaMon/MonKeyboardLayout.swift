//
//  MonKeyboardLayout.swift
//  AnontaMon
//
//  Defines all 4 keyboard states for the Mon language keyboard.
//  Based on keyboardLayout.md and pasted screenshots.
//

import Foundation

// MARK: - Key Model

/// Represents the type of a keyboard key
enum KeyType: Equatable {
    case character(String)      // Regular character key
    case shift                  // Shift / Caps toggle
    case delete                 // Backspace / Delete
    case `return`               // Return / Enter
    case space                  // Space bar
    case switchToNumbers        // Switch to numbers/symbols layout
    case switchToLetters        // Switch back to letters
    case switchToSymbols        // Switch to more symbols
    case globe                  // Next keyboard / Globe
    case stackedKey             // Stacked consonant marker (္)
    case dismissKeyboard        // Dismiss keyboard
}

/// Represents a single key on the keyboard
struct KeyModel: Identifiable {
    let id = UUID()
    let label: String           // Display text
    let type: KeyType           // Key type
    let width: CGFloat          // Relative width (1.0 = standard key)
    
    init(_ label: String, type: KeyType = .character(""), width: CGFloat = 1.0) {
        switch type {
        case .character(""):
            self.label = label
            self.type = .character(label)
            self.width = width
        default:
            self.label = label
            self.type = type
            self.width = width
        }
    }
}

/// Represents a row of keys
struct KeyRow: Identifiable {
    let id = UUID()
    let keys: [KeyModel]
}

/// Represents a complete keyboard layout state
struct KeyboardLayout {
    let rows: [KeyRow]
}

// MARK: - Mon Keyboard Layouts

struct MonKeyboardLayouts {
    
    // MARK: - State 1: Normal (Default)
    static let normal = KeyboardLayout(rows: [
        // Row 1: ဆ တ န မ အ ပ က င သ စ ဟ
        KeyRow(keys: [
            KeyModel("ဆ"), KeyModel("တ"), KeyModel("န"), KeyModel("မ"),
            KeyModel("အ"), KeyModel("ပ"), KeyModel("က"), KeyModel("င"),
            KeyModel("သ"), KeyModel("စ"), KeyModel("ဟ"),
        ]),
        // Row 2: ေ ျ ိ ် ါ ့ ြ ု ူ း ဒ
        KeyRow(keys: [
            KeyModel("ေ"), KeyModel("ျ"), KeyModel("ိ"), KeyModel("်"),
            KeyModel("ါ"), KeyModel("့"), KeyModel("ြ"), KeyModel("ု"),
            KeyModel("ူ"), KeyModel("း"), KeyModel("ဒ"),
        ]),
        // Row 3: Shift ဖ ထ ခ လ ဘ ည ာ ယ Delete
        KeyRow(keys: [
            KeyModel("⇧", type: .shift, width: 1.3),
            KeyModel("ဖ"), KeyModel("ထ"), KeyModel("ခ"), KeyModel("လ"),
            KeyModel("ဘ"), KeyModel("ည"), KeyModel("ာ"), KeyModel("ယ"),
            KeyModel("⌫", type: .delete, width: 1.3),
        ]),
        // Row 4: 123 Globe ္ Space ရ Return
        KeyRow(keys: [
            KeyModel("၁၂၃", type: .switchToNumbers, width: 1.2),
            KeyModel("🌐", type: .globe, width: 1.0),
            KeyModel("္", type: .character("္"), width: 1.0),
            KeyModel(" ", type: .space, width: 4.0),
            KeyModel("ရ"),
            KeyModel("⏎", type: .return, width: 1.8),
        ]),
    ])
    
    // MARK: - State 2: Shift
    static let shifted = KeyboardLayout(rows: [
        // Row 1: ၛ ဝ ဣ ၟ ဳ ၠ ဥ ၝ ဿ ဏ ဨ
        KeyRow(keys: [
            KeyModel("ၛ"), KeyModel("ဝ"), KeyModel("ဣ"), KeyModel("ၟ"),
            KeyModel("ဳ"), KeyModel("ၠ"), KeyModel("ဥ"), KeyModel("ၝ"),
            KeyModel("ဿ"), KeyModel("ဏ"), KeyModel("ဨ"),
        ]),
        // Row 2: ဗ ှ ီ ္ ွ ဴ ဲ ဒ ဓ ဂ ဵ
        KeyRow(keys: [
            KeyModel("ဗ"), KeyModel("ှ"), KeyModel("ီ"), KeyModel("္"),
            KeyModel("ွ"), KeyModel("ဴ"), KeyModel("ဲ"), KeyModel("ဒ"),
            KeyModel("ဓ"), KeyModel("ဂ"), KeyModel("ဵ"),
        ]),
        // Row 3: Shift ဇ ဌ ဃ ဠ ၜ ဉ ၞ ဋ Delete
        KeyRow(keys: [
            KeyModel("⇪", type: .shift, width: 1.3),
            KeyModel("ဇ"), KeyModel("ဌ"), KeyModel("ဃ"), KeyModel("ဠ"),
            KeyModel("ၜ"), KeyModel("ဉ"), KeyModel("ၞ"), KeyModel("ဋ"),
            KeyModel("⌫", type: .delete, width: 1.3),
        ]),
        // Row 4: 123 Globe ဩ Space ။ Return
        KeyRow(keys: [
            KeyModel("၁၂၃", type: .switchToNumbers, width: 1.2),
            KeyModel("🌐", type: .globe, width: 1.0),
            KeyModel("ဩ"),
            KeyModel(" ", type: .space, width: 4.0),
            KeyModel("။"),
            KeyModel("⏎", type: .return, width: 1.8),
        ]),
    ])
    
    // MARK: - State 3: Numbers & Punctuation
    static let numbers = KeyboardLayout(rows: [
        // Row 1: Mon digits ၁ ၂ ၃ ၄ ၅ ၆ ၇ ၈ ၉ ၀
        KeyRow(keys: [
            KeyModel("၁"), KeyModel("၂"), KeyModel("၃"), KeyModel("၄"),
            KeyModel("၅"), KeyModel("၆"), KeyModel("၇"), KeyModel("၈"),
            KeyModel("၉"), KeyModel("၀"),
        ]),
        // Row 2: - / : ; ( ) $ & @ "
        KeyRow(keys: [
            KeyModel("-"), KeyModel("/"), KeyModel(":"), KeyModel(";"),
            KeyModel("("), KeyModel(")"), KeyModel("$"), KeyModel("&"),
            KeyModel("@"), KeyModel("\""),
        ]),
        // Row 3: #+= . , ? ! '  Delete
        KeyRow(keys: [
            KeyModel("#+=", type: .switchToSymbols, width: 1.3),
            KeyModel("."), KeyModel(","), KeyModel("?"), KeyModel("!"),
            KeyModel("'"),
            KeyModel("⌫", type: .delete, width: 1.6),
        ]),
        // Row 4: ကခဂ Globe Space Return
        KeyRow(keys: [
            KeyModel("ကခဂ", type: .switchToLetters, width: 1.2),
            KeyModel("🌐", type: .globe, width: 1.0),
            KeyModel(" ", type: .space, width: 5.0),
            KeyModel("⏎", type: .return, width: 1.8),
        ]),
    ])
    
    // MARK: - State 4: More Symbols
    static let symbols = KeyboardLayout(rows: [
        // Row 1: [ ] { } # % ^ * + =
        KeyRow(keys: [
            KeyModel("["), KeyModel("]"), KeyModel("{"), KeyModel("}"),
            KeyModel("#"), KeyModel("%"), KeyModel("^"), KeyModel("*"),
            KeyModel("+"), KeyModel("="),
        ]),
        // Row 2: _ \ | ~ < > € £ ¥ •
        KeyRow(keys: [
            KeyModel("_"), KeyModel("\\"), KeyModel("|"), KeyModel("~"),
            KeyModel("<"), KeyModel(">"), KeyModel("€"), KeyModel("£"),
            KeyModel("¥"), KeyModel("•"),
        ]),
        // Row 3: ၁၂၃ × ÷ . , ? ! ' Delete
        KeyRow(keys: [
            KeyModel("၁၂၃", type: .switchToNumbers, width: 1.3),
            KeyModel("×"), KeyModel("÷"), KeyModel("."), KeyModel(","),
            KeyModel("?"), KeyModel("!"), KeyModel("'"),
            KeyModel("⌫", type: .delete, width: 1.3),
        ]),
        // Row 4: ကခဂ Globe Space Return
        KeyRow(keys: [
            KeyModel("ကခဂ", type: .switchToLetters, width: 1.2),
            KeyModel("🌐", type: .globe, width: 1.0),
            KeyModel(" ", type: .space, width: 5.0),
            KeyModel("⏎", type: .return, width: 1.8),
        ]),
    ])
}
