//
//  KeyboardFeedbackManager.swift
//  AnontaMon
//
//  Manages sound and haptic feedback for key presses.
//

import UIKit
import AudioToolbox

final class KeyboardFeedbackManager {
    
    static let shared = KeyboardFeedbackManager()
    
    private var settings: KeyboardSettings
    
    // Haptic generators (reuse for performance)
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    private init() {
        self.settings = KeyboardSettings.shared
    }
    
    /// Prepare haptic engines (call in viewDidAppear for better response)
    func prepare() {
        lightImpact.prepare()
        selectionFeedback.prepare()
    }
    
    /// Play feedback for a regular character key press
    func playKeyPress() {
        if settings.clickSoundEnabled {
            playInputClick()
        }
        if settings.hapticEnabled {
            lightImpact.impactOccurred()
            lightImpact.prepare()
        }
    }
    
    /// Play feedback for a special key (delete, return, shift)
    func playSpecialKey() {
        if settings.clickSoundEnabled {
            playInputClick()
        }
        if settings.hapticEnabled {
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        }
    }
    
    /// Play feedback for selection changes (space, etc.)
    func playSelection() {
        if settings.hapticEnabled {
            selectionFeedback.selectionChanged()
            selectionFeedback.prepare()
        }
    }
    
    /// Play the standard keyboard click sound using system API
    private func playInputClick() {
        // Use the system keyboard click sound (ID 1104)
        AudioServicesPlaySystemSound(1104)
    }
    
    /// Reload settings (call when keyboard appears)
    func reloadSettings() {
        settings.reload()
    }
}

// MARK: - UIInputViewAudioFeedback conformance
// The keyboard view should conform to UIInputViewAudioFeedback
// to enable standard keyboard clicks via UIDevice.current.playInputClick()
