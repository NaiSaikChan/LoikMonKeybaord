//
//  ContentView.swift
//  LoikMonKeybaord
//
//  Main app settings view for the Mon keyboard.
//  Allows users to configure appearance, feedback, and assists.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = KeyboardSettings.shared
    @State private var showingFontPicker = false
    @State private var showingKeyboardGuide = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Setup Instructions
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "keyboard")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            Text("LoikMon Keyboard")
                                .font(.headline)
                        }
                        Text("Mon Language Keyboard (mnw-MY)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: { showingKeyboardGuide = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.accentColor)
                            Text("How to Enable Keyboard")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Welcome")
                }
                
                // MARK: - Appearance
                Section {
                    NavigationLink {
                        FontPickerView(settings: settings)
                    } label: {
                        HStack {
                            Image(systemName: "textformat")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Keyboard Font")
                            Spacer()
                            Text(displayFontName)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Picker(selection: $settings.keyboardTheme) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Theme")
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                // MARK: - Keyboard Feedback
                Section {
                    Toggle(isOn: $settings.clickSoundEnabled) {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Click Sound")
                        }
                    }
                    
                    Toggle(isOn: $settings.hapticEnabled) {
                        HStack {
                            Image(systemName: "hand.tap")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Haptic Feedback")
                        }
                    }
                    
                    Toggle(isOn: $settings.popupEnabled) {
                        HStack {
                            Image(systemName: "character.bubble")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Key Popups")
                        }
                    }
                } header: {
                    Text("Keyboard Feedback")
                } footer: {
                    Text("Provides audio, tactile, and visual feedback when pressing keys.")
                }
                
                // MARK: - Assists
                Section {
                    Toggle(isOn: $settings.correctionsEnabled) {
                        HStack {
                            Image(systemName: "text.badge.checkmark")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Corrections")
                        }
                    }
                    
                    Toggle(isOn: $settings.autoCapEnabled) {
                        HStack {
                            Image(systemName: "textformat.abc")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Auto Capitalization")
                        }
                    }
                } header: {
                    Text("Assists")
                } footer: {
                    Text("Auto-correct common Mon misspellings and capitalize at sentence boundaries.")
                }
                
                // MARK: - Extra Features
                Section {
                    Toggle(isOn: $settings.showNumberRow) {
                        HStack {
                            Image(systemName: "number")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Number Row")
                        }
                    }
                } header: {
                    Text("Extra Features")
                } footer: {
                    Text("Show a dedicated Mon number row above the keyboard.")
                }
                
                // MARK: - Keyboard Preview
                Section {
                    KeyboardPreviewView(settings: settings)
                        .frame(height: 200)
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text("Preview")
                }
                
                // MARK: - About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Language")
                        Spacer()
                        Text("Mon (mnw-MY)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("LoikMon Settings")
            .sheet(isPresented: $showingKeyboardGuide) {
                KeyboardGuideView()
            }
        }
    }
    
    private var displayFontName: String {
        KeyboardSettings.availableFonts
            .first(where: { $0.name == settings.selectedFont })?
            .displayName ?? settings.selectedFont
    }
}

// MARK: - Font Picker View

struct FontPickerView: View {
    @ObservedObject var settings: KeyboardSettings
    
    var body: some View {
        List {
            ForEach(KeyboardSettings.availableFonts, id: \.name) { font in
                Button(action: {
                    settings.selectedFont = font.name
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(font.displayName)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            // Show Mon sample text in the font
                            Text("မန် ဘာသာ ကီုဗုတ်")
                                .font(fontForName(font.name, size: 20))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if settings.selectedFont == font.name {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Keyboard Font")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func fontForName(_ name: String, size: CGFloat) -> Font {
        if name == "System" {
            return .system(size: size)
        }
        return .custom(name, size: size)
    }
}

// MARK: - Keyboard Guide View

struct KeyboardGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    GuideStepRow(step: 1, icon: "gear",
                                 title: "Open Settings",
                                 description: "Go to Settings on your device")
                    GuideStepRow(step: 2, icon: "globe",
                                 title: "General → Keyboard",
                                 description: "Navigate to General → Keyboard → Keyboards")
                    GuideStepRow(step: 3, icon: "plus.circle",
                                 title: "Add New Keyboard",
                                 description: "Tap 'Add New Keyboard...' and select 'AnontaMon'")
                    GuideStepRow(step: 4, icon: "lock.shield",
                                 title: "Allow Full Access",
                                 description: "Tap AnontaMon and enable 'Allow Full Access' to share settings")
                    GuideStepRow(step: 5, icon: "keyboard",
                                 title: "Use the Keyboard",
                                 description: "In any text field, tap & hold the 🌐 globe icon and select AnontaMon")
                }
            }
            .navigationTitle("Setup Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct GuideStepRow: View {
    let step: Int
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 32, height: 32)
                Text("\(step)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Keyboard Preview

struct KeyboardPreviewView: View {
    @ObservedObject var settings: KeyboardSettings
    
    private let sampleKeys = [
        ["ဆ", "တ", "န", "မ", "အ", "ပ", "က", "ၚ", "သ", "စ"],
        ["ေ", "ျ", "ိ", "်", "ါ", "့", "ြ", "ု", "ူ", "း"],
        ["ဖ", "ထ", "ခ", "လ", "ဘ", "ည", "ာ", "ယ"],
    ]
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(sampleKeys, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { key in
                        Text(key)
                            .font(previewFont)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(.systemGray5))
                            )
                    }
                }
                .padding(.horizontal, 6)
            }
            
            // Space bar preview
            HStack(spacing: 4) {
                Text("⇧")
                    .frame(width: 44, height: 38)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(.systemGray4)))
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(.systemGray5))
                    .frame(height: 38)
                
                Text("⌫")
                    .frame(width: 44, height: 38)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(.systemBlue)))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 6)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var previewFont: Font {
        if settings.selectedFont != "System" {
            return .custom(settings.selectedFont, size: 18)
        }
        return .system(size: 18)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
