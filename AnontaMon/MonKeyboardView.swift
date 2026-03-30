//
//  MonKeyboardView.swift
//  AnontaMon
//
//  SwiftUI-based Mon keyboard view embedded in UIInputViewController.
//

import SwiftUI
import UIKit

// MARK: - Keyboard State

enum KeyboardState: Int {
    case normal = 0
    case shifted = 1
    case numbers = 2
    case symbols = 3
}

// MARK: - Keyboard Action Protocol

protocol KeyboardActionHandler: AnyObject {
    func insertText(_ text: String)
    func deleteBackward()
    func handleReturn()
    func switchKeyboard()
    func dismissKeyboardAction()
    func getDocumentContext() -> String?
}

// MARK: - Color Constants (match iOS system keyboard)

private struct KBColors {
    // Character key background
    static func charKey(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(white: 0.40)   // dark-mode character keys
            : Color.white           // light-mode character keys
    }
    // Special key background (shift, 123, etc.)
    static func specialKey(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(white: 0.27)
            : Color(red: 0.68, green: 0.70, blue: 0.73)
    }
    // Space bar
    static func spaceBar(_ scheme: ColorScheme) -> Color {
        charKey(scheme)
    }
    // Key text
    static func keyText(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .white : .black
    }
    // Keyboard background
    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.13, green: 0.13, blue: 0.13)
            : Color(red: 0.82, green: 0.84, blue: 0.86)
    }
}

// MARK: - Main Keyboard View

struct MonKeyboardView: View {

    @ObservedObject var settings: KeyboardSettings
    @Environment(\.colorScheme) private var colorScheme
    @State private var keyboardState: KeyboardState = .normal
    @State private var isShiftLocked: Bool = false

    weak var actionHandler: KeyboardActionHandler?
    let needsInputModeSwitchKey: Bool

    private var currentLayout: KeyboardLayout {
        switch keyboardState {
        case .normal:  return MonKeyboardLayouts.normal
        case .shifted: return MonKeyboardLayouts.shifted
        case .numbers: return MonKeyboardLayouts.numbers
        case .symbols: return MonKeyboardLayouts.symbols
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let rowHeight: CGFloat = max(42, (proxy.size.height - 28) / CGFloat(currentLayout.rows.count))
            let totalWidth = proxy.size.width - 6 // horizontal padding

            VStack(spacing: 5) {
                ForEach(Array(currentLayout.rows.enumerated()), id: \.offset) { _, row in
                    buildRow(row, totalWidth: totalWidth, rowHeight: rowHeight)
                }
            }
            .padding(.horizontal, 3)
            .padding(.top, 6)
            .padding(.bottom, 3)
        }
        .background(KBColors.background(colorScheme))
    }

    // MARK: - Row Builder

    /// Calculate exact pixel width for every key based on its .width ratio.
    @ViewBuilder
    private func buildRow(_ row: KeyRow, totalWidth: CGFloat, rowHeight: CGFloat) -> some View {
        let spacing: CGFloat = 4
        let gaps = CGFloat(row.keys.count - 1) * spacing
        let available = totalWidth - gaps
        let totalUnits = row.keys.reduce(CGFloat(0)) { $0 + $1.width }

        HStack(spacing: spacing) {
            ForEach(Array(row.keys.enumerated()), id: \.offset) { _, key in
                let w = available * key.width / totalUnits
                keyButton(for: key)
                    .frame(width: w, height: rowHeight)
            }
        }
    }

    // MARK: - Single Key

    @ViewBuilder
    private func keyButton(for key: KeyModel) -> some View {
        Button(action: { handleKeyPress(key) }) {
            keyLabel(for: key)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(bgColor(for: key))
                        .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Key Label

    @ViewBuilder
    private func keyLabel(for key: KeyModel) -> some View {
        switch key.type {
        case .shift:
            Image(systemName: isShiftLocked ? "capslock.fill"
                  : (keyboardState == .shifted ? "shift.fill" : "shift"))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(fgColor(for: key))

        case .delete:
            Image(systemName: "delete.left.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)

        case .return:
            Image(systemName: "return")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)

        case .globe:
            Image(systemName: "globe")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(fgColor(for: key))

        case .space:
            Color.clear // empty space bar

        case .dismissKeyboard:
            Image(systemName: "keyboard.chevron.compact.down")
                .font(.system(size: 16))
                .foregroundColor(fgColor(for: key))

        default:
            Text(key.label)
                .font(keyFont(for: key))
                .foregroundColor(fgColor(for: key))
                .minimumScaleFactor(0.35)
                .lineLimit(1)
                .padding(.horizontal, 2)
        }
    }

    // MARK: - Colors

    private func bgColor(for key: KeyModel) -> Color {
        switch key.type {
        case .character, .stackedKey:
            return KBColors.charKey(colorScheme)
        case .space:
            return KBColors.spaceBar(colorScheme)
        case .shift:
            if keyboardState == .shifted {
                return isShiftLocked ? .white : Color(white: 0.95)
            }
            return KBColors.specialKey(colorScheme)
        case .delete:
            return .blue
        case .return:
            return Color(red: 0.90, green: 0.35, blue: 0.30) // iOS red-ish
        default:
            return KBColors.specialKey(colorScheme)
        }
    }

    private func fgColor(for key: KeyModel) -> Color {
        switch key.type {
        case .delete, .return:
            return .white
        case .shift where keyboardState == .shifted:
            return .black
        default:
            return KBColors.keyText(colorScheme)
        }
    }

    private func keyFont(for key: KeyModel) -> Font {
        let size: CGFloat
        switch key.type {
        case .character:     size = 22
        case .switchToNumbers, .switchToLetters, .switchToSymbols: size = 14
        default:             size = 16
        }
        if settings.selectedFont != "System",
           UIFont(name: settings.selectedFont, size: size) != nil {
            return .custom(settings.selectedFont, size: size)
        }
        return .system(size: size)
    }

    // MARK: - Key Press Handler

    private func handleKeyPress(_ key: KeyModel) {
        switch key.type {
        case .character(let text):
            KeyboardFeedbackManager.shared.playKeyPress()
            actionHandler?.insertText(text)
            if settings.correctionsEnabled, text == " " || text == "။" {
                checkAndApplyCorrection()
            }
            if keyboardState == .shifted && !isShiftLocked {
                keyboardState = .normal
            }

        case .shift:
            KeyboardFeedbackManager.shared.playSpecialKey()
            if keyboardState == .shifted {
                if isShiftLocked { isShiftLocked = false; keyboardState = .normal }
                else { isShiftLocked = true }
            } else {
                keyboardState = .shifted; isShiftLocked = false
            }

        case .delete:
            KeyboardFeedbackManager.shared.playSpecialKey()
            actionHandler?.deleteBackward()

        case .return:
            KeyboardFeedbackManager.shared.playSpecialKey()
            actionHandler?.handleReturn()

        case .space:
            KeyboardFeedbackManager.shared.playSelection()
            actionHandler?.insertText(" ")

        case .switchToNumbers:
            KeyboardFeedbackManager.shared.playSpecialKey()
            keyboardState = .numbers

        case .switchToLetters:
            KeyboardFeedbackManager.shared.playSpecialKey()
            keyboardState = .normal

        case .switchToSymbols:
            KeyboardFeedbackManager.shared.playSpecialKey()
            keyboardState = .symbols

        case .globe:
            KeyboardFeedbackManager.shared.playSpecialKey()
            actionHandler?.switchKeyboard()

        case .stackedKey:
            KeyboardFeedbackManager.shared.playKeyPress()
            actionHandler?.insertText("္")

        case .dismissKeyboard:
            actionHandler?.dismissKeyboardAction()
        }
    }

    // MARK: - Auto-Correction

    private func checkAndApplyCorrection() {
        guard let context = actionHandler?.getDocumentContext() else { return }
        if let correction = MonCorrections.shared.checkCorrection(for: context) {
            for _ in 0..<correction.original.count {
                actionHandler?.deleteBackward()
            }
            actionHandler?.insertText(correction.replacement)
        }
    }
}
