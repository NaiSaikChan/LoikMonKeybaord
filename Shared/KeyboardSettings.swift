//
//  KeyboardSettings.swift
//  LoikMonKeybaord
//
//  Shared settings model between main app and keyboard extension.
//  Uses App Group UserDefaults for cross-process communication.
//

import Foundation
import Combine

/// App Group identifier for sharing data between the main app and keyboard extension.
/// Configure this in Xcode under Signing & Capabilities > App Groups for BOTH targets.
let kAppGroupID = "group.com.loikmon.keyboard"

/// Manages all keyboard settings using UserDefaults (App Group).
final class KeyboardSettings: ObservableObject {
    
    static let shared = KeyboardSettings()
    
    private let defaults: UserDefaults
    
    // MARK: - Keys
    private enum Keys {
        static let selectedFont        = "selectedFont"
        static let clickSoundEnabled   = "clickSoundEnabled"
        static let hapticEnabled       = "hapticEnabled"
        static let popupEnabled        = "popupEnabled"
        static let correctionsEnabled  = "correctionsEnabled"
        static let autoCapEnabled      = "autoCapEnabled"
        static let keyboardTheme       = "keyboardTheme"
        static let showNumberRow       = "showNumberRow"
    }
    
    // MARK: - Published Properties
    
    /// Selected font name for keyboard keys
    @Published var selectedFont: String {
        didSet { defaults.set(selectedFont, forKey: Keys.selectedFont) }
    }
    
    /// Enable key click sounds
    @Published var clickSoundEnabled: Bool {
        didSet { defaults.set(clickSoundEnabled, forKey: Keys.clickSoundEnabled) }
    }
    
    /// Enable haptic feedback on key press
    @Published var hapticEnabled: Bool {
        didSet { defaults.set(hapticEnabled, forKey: Keys.hapticEnabled) }
    }
    
    /// Enable key popup preview on press
    @Published var popupEnabled: Bool {
        didSet { defaults.set(popupEnabled, forKey: Keys.popupEnabled) }
    }
    
    /// Enable auto-corrections
    @Published var correctionsEnabled: Bool {
        didSet { defaults.set(correctionsEnabled, forKey: Keys.correctionsEnabled) }
    }
    
    /// Enable auto-capitalization
    @Published var autoCapEnabled: Bool {
        didSet { defaults.set(autoCapEnabled, forKey: Keys.autoCapEnabled) }
    }
    
    /// Keyboard color theme (0 = system, 1 = light, 2 = dark)
    @Published var keyboardTheme: Int {
        didSet { defaults.set(keyboardTheme, forKey: Keys.keyboardTheme) }
    }
    
    /// Show dedicated number row on top
    @Published var showNumberRow: Bool {
        didSet { defaults.set(showNumberRow, forKey: Keys.showNumberRow) }
    }
    
    // MARK: - Available Fonts
    
    /// Fonts that support Mon script (Myanmar Unicode block)
    static let availableFonts: [(name: String, displayName: String)] = [
        ("MyanmarSansPro", "Myanmar Sans Pro"),
        ("MyanmarMN", "Myanmar MN"),
        ("MyanmarMN-Bold", "Myanmar MN Bold"),
        ("Padauk", "Padauk"),
        ("NotoSansMyanmar-Regular", "Noto Sans Myanmar"),
        ("NotoSansMyanmar-Bold", "Noto Sans Myanmar Bold"),
        ("System", "System Default"),
    ]
    
    // MARK: - Init
    
    init() {
        // Use App Group UserDefaults if available, otherwise standard
        if let groupDefaults = UserDefaults(suiteName: kAppGroupID) {
            self.defaults = groupDefaults
        } else {
            self.defaults = .standard
        }
        
        // Load saved values with defaults
        self.selectedFont       = defaults.string(forKey: Keys.selectedFont) ?? "System"
        self.clickSoundEnabled  = defaults.object(forKey: Keys.clickSoundEnabled) as? Bool ?? true
        self.hapticEnabled      = defaults.object(forKey: Keys.hapticEnabled) as? Bool ?? true
        self.popupEnabled       = defaults.object(forKey: Keys.popupEnabled) as? Bool ?? true
        self.correctionsEnabled = defaults.object(forKey: Keys.correctionsEnabled) as? Bool ?? true
        self.autoCapEnabled     = defaults.object(forKey: Keys.autoCapEnabled) as? Bool ?? true
        self.keyboardTheme      = defaults.integer(forKey: Keys.keyboardTheme)
        self.showNumberRow      = defaults.object(forKey: Keys.showNumberRow) as? Bool ?? false
    }
    
    /// Reload settings from disk (call in keyboard extension when it appears)
    func reload() {
        selectedFont       = defaults.string(forKey: Keys.selectedFont) ?? "System"
        clickSoundEnabled  = defaults.object(forKey: Keys.clickSoundEnabled) as? Bool ?? true
        hapticEnabled      = defaults.object(forKey: Keys.hapticEnabled) as? Bool ?? true
        popupEnabled       = defaults.object(forKey: Keys.popupEnabled) as? Bool ?? true
        correctionsEnabled = defaults.object(forKey: Keys.correctionsEnabled) as? Bool ?? true
        autoCapEnabled     = defaults.object(forKey: Keys.autoCapEnabled) as? Bool ?? true
        keyboardTheme      = defaults.integer(forKey: Keys.keyboardTheme)
        showNumberRow      = defaults.object(forKey: Keys.showNumberRow) as? Bool ?? false
    }
}
