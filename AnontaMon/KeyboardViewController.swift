//
//  KeyboardViewController.swift
//  AnontaMon
//
//  Mon Language Custom Keyboard Extension
//  Primary view controller for the keyboard extension.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController, KeyboardActionHandler {
    
    // MARK: - Properties
    
    private var keyboardHostingController: UIHostingController<MonKeyboardView>?
    private let settings = KeyboardSettings.shared
    private let feedbackManager = KeyboardFeedbackManager.shared
    
    // Height constraint for the keyboard
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use custom input view that supports keyboard click sounds
        let audioView = AudioEnabledInputView()
        audioView.translatesAutoresizingMaskIntoConstraints = false
        inputView = audioView
        
        setupKeyboardView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload settings each time keyboard appears
        settings.reload()
        feedbackManager.reloadSettings()
        feedbackManager.prepare()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateHeight()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeight()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateHeight()
        })
    }
    
    // MARK: - Setup
    
    private func setupKeyboardView() {
        guard keyboardHostingController == nil else { return }
        
        var keyboardView = MonKeyboardView(
            settings: settings,
            needsInputModeSwitchKey: needsInputModeSwitchKey
        )
        keyboardView.actionHandler = self
        
        let hostingController = UIHostingController(rootView: keyboardView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        self.keyboardHostingController = hostingController
    }
    
    private func updateHeight() {
        let screenBounds = view.window?.windowScene?.screen.bounds ?? UIScreen.main.bounds
        let isLandscape = screenBounds.width > screenBounds.height
        let targetHeight: CGFloat = isLandscape ? 200 : 260
        
        if let existing = heightConstraint {
            existing.constant = targetHeight
        } else {
            let constraint = view.heightAnchor.constraint(equalToConstant: targetHeight)
            constraint.priority = .defaultHigh
            constraint.isActive = true
            heightConstraint = constraint
        }
    }
    
    // MARK: - UITextInputDelegate
    
    override func textWillChange(_ textInput: UITextInput?) {
        // Called before text changes
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // Called after text changes - update any state if needed
    }
    
    // MARK: - KeyboardActionHandler Protocol
    
    func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
    
    func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }
    
    func handleReturn() {
        textDocumentProxy.insertText("\n")
    }
    
    func switchKeyboard() {
        advanceToNextInputMode()
    }
    
    func dismissKeyboardAction() {
        dismissKeyboard()
    }
    
    func getDocumentContext() -> String? {
        return textDocumentProxy.documentContextBeforeInput
    }
}

// MARK: - Custom Input View with Audio Feedback

/// Custom UIInputView subclass that enables standard keyboard click sounds.
class AudioEnabledInputView: UIInputView, UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { return true }
    
    init() {
        super.init(frame: .zero, inputViewStyle: .keyboard)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
