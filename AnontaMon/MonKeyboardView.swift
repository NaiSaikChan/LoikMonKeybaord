//
//  MonKeyboardView.swift
//  AnontaMon
//
//  SwiftUI-based Mon keyboard view embedded in UIInputViewController.
//

import SwiftUI

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

// MARK: - Main Keyboard View

struct MonKeyboardView: View {
    
    @ObservedObject var settings: KeyboardSettings
    @State private var keyboardState: KeyboardState = .normal
    @State private var popupKey: String? = nil
    @State private var popupPosition: CGPoint = .zero
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
        ZStack {
            VStack(spacing: 6) {
                ForEach(currentLayout.rows) { row in
                    keyRow(row)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 4)
            
            // Popup preview
            if settings.popupEnabled, let popup = popupKey {
                KeyPopupView(text: popup, position: popupPosition)
            }
        }
    }
    
    @ViewBuilder
    private func keyRow(_ row: KeyRow) -> some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width - CGFloat(row.keys.count - 1) * 4 // spacing
            let totalUnits = row.keys.reduce(CGFloat(0)) { $0 + $1.width }
            let unitWidth = totalWidth / totalUnits
            
            HStack(spacing: 4) {
                ForEach(row.keys) { key in
                    KeyButtonView(
                        key: key,
                        keyboardState: $keyboardState,
                        isShiftLocked: $isShiftLocked,
                        popupKey: $popupKey,
                        popupPosition: $popupPosition,
                        settings: settings,
                        needsInputModeSwitchKey: needsInputModeSwitchKey,
                        onKeyPress: { handleKeyPress(key) }
                    )
                    .frame(width: unitWidth * key.width)
                }
            }
        }
        .frame(height: 42)
        .padding(.horizontal, 3)
    }
    
    // MARK: - Key Press Handler
    
    private func handleKeyPress(_ key: KeyModel) {
        switch key.type {
        case .character(let text):
            KeyboardFeedbackManager.shared.playKeyPress()
            actionHandler?.insertText(text)
            
            // Auto-correction check
            if settings.correctionsEnabled, text == " " || text == "။" {
                checkAndApplyCorrection()
            }
            
            // Return to normal state after typing in shifted (but not shift-locked)
            if keyboardState == .shifted && !isShiftLocked {
                keyboardState = .normal
            }
            
        case .shift:
            KeyboardFeedbackManager.shared.playSpecialKey()
            if keyboardState == .shifted {
                if isShiftLocked {
                    isShiftLocked = false
                    keyboardState = .normal
                } else {
                    isShiftLocked = true
                }
            } else {
                keyboardState = .shifted
                isShiftLocked = false
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
            
            // Check for double-space → period
            if let context = actionHandler?.getDocumentContext(),
               context.hasSuffix("  ") {
                actionHandler?.deleteBackward()
                actionHandler?.deleteBackward()
                actionHandler?.insertText("။ ")
            }
            
            // Auto-correction on space
            if settings.correctionsEnabled {
                checkAndApplyCorrection()
            }
            
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
            // Delete the original word
            for _ in 0..<correction.original.count {
                actionHandler?.deleteBackward()
            }
            // Insert corrected word
            actionHandler?.insertText(correction.replacement)
        }
    }
}

// MARK: - Key Button View

struct KeyButtonView: View {
    
    let key: KeyModel
    @Binding var keyboardState: KeyboardState
    @Binding var isShiftLocked: Bool
    @Binding var popupKey: String?
    @Binding var popupPosition: CGPoint
    let settings: KeyboardSettings
    let needsInputModeSwitchKey: Bool
    let onKeyPress: () -> Void
    
    @State private var isPressed = false
    @GestureState private var longPressActive = false
    
    // Delete repeat timer
    @State private var deleteTimer: Timer? = nil
    
    private var keyBackgroundColor: Color {
        switch key.type {
        case .character:
            return Color(.systemGray2).opacity(isPressed ? 0.5 : 1.0)
        case .shift:
            if keyboardState == .shifted {
                return isShiftLocked
                    ? Color.blue
                    : Color.blue.opacity(0.7)
            }
            return Color(.systemGray3).opacity(isPressed ? 0.5 : 1.0)
        case .delete:
            return Color(.systemBlue).opacity(isPressed ? 0.5 : 1.0)
        case .return:
            return Color(.systemRed).opacity(isPressed ? 0.5 : 0.8)
        case .space:
            return Color(.systemGray3).opacity(isPressed ? 0.5 : 1.0)
        default:
            return Color(.systemGray3).opacity(isPressed ? 0.5 : 1.0)
        }
    }
    
    private var keyForegroundColor: Color {
        switch key.type {
        case .return, .delete:
            return .white
        default:
            return Color(.label)
        }
    }
    
    private var fontSize: CGFloat {
        switch key.type {
        case .character:
            return 22
        case .switchToNumbers, .switchToLetters, .switchToSymbols:
            return 14
        default:
            return 16
        }
    }
    
    private var keyFont: Font {
        if settings.selectedFont != "System",
           let _ = UIFont(name: settings.selectedFont, size: fontSize) {
            return .custom(settings.selectedFont, size: fontSize)
        }
        return .system(size: fontSize)
    }
    
    var body: some View {
        GeometryReader { geo in
            Button(action: {
                onKeyPress()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(keyBackgroundColor)
                        .shadow(color: Color.black.opacity(0.3), radius: 0, x: 0, y: 1)
                    
                    keyContent
                }
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPressed {
                            isPressed = true
                            showPopup(in: geo)
                            
                            // Start delete repeat for delete key
                            if case .delete = key.type {
                                startDeleteRepeat()
                            }
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        popupKey = nil
                        stopDeleteRepeat()
                    }
            )
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    @ViewBuilder
    private var keyContent: some View {
        switch key.type {
        case .shift:
            Image(systemName: isShiftLocked ? "capslock.fill" :
                    (keyboardState == .shifted ? "shift.fill" : "shift"))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(keyForegroundColor)
            
        case .delete:
            Image(systemName: "delete.left.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            
        case .return:
            Image(systemName: "return")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            
        case .globe:
            if needsInputModeSwitchKey {
                Image(systemName: "globe")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(keyForegroundColor)
            } else {
                EmptyView()
            }
            
        case .space:
            Text("")
                .font(.system(size: 14))
                .foregroundColor(keyForegroundColor)
            
        case .dismissKeyboard:
            Image(systemName: "keyboard.chevron.compact.down")
                .font(.system(size: 16))
                .foregroundColor(keyForegroundColor)
            
        default:
            Text(key.label)
                .font(keyFont)
                .foregroundColor(keyForegroundColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
    }
    
    // MARK: - Popup
    
    private func showPopup(in geo: GeometryProxy) {
        guard settings.popupEnabled else { return }
        if case .character = key.type {
            popupKey = key.label
            let frame = geo.frame(in: .global)
            popupPosition = CGPoint(x: frame.midX, y: frame.minY - 30)
        }
    }
    
    // MARK: - Delete Repeat
    
    private func startDeleteRepeat() {
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            onKeyPress()
        }
    }
    
    private func stopDeleteRepeat() {
        deleteTimer?.invalidate()
        deleteTimer = nil
    }
}

// MARK: - Key Popup View

struct KeyPopupView: View {
    let text: String
    let position: CGPoint
    
    var body: some View {
        Text(text)
            .font(.system(size: 34, weight: .regular))
            .foregroundColor(Color(.label))
            .frame(width: 52, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            )
            .position(position)
            .allowsHitTesting(false)
            .animation(.easeOut(duration: 0.05), value: text)
    }
}
