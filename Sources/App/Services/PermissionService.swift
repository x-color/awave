@preconcurrency import AVFoundation
import AppKit
@preconcurrency import ApplicationServices
import Foundation

@MainActor
enum PermissionService {
  static func accessibilityAllowed() -> Bool {
    AXIsProcessTrusted()
  }

  static func requestAccessibilityPermission() {
    let options =
      [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    AXIsProcessTrustedWithOptions(options)
  }

  static func microphoneAllowed() -> Bool {
    AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
  }

  static func requestMicrophonePermission() {
    Task { _ = await AVCaptureDevice.requestAccess(for: .audio) }
  }

  static func openAccessibilitySettings() {
    openPrivacyPane(anchor: "Privacy_Accessibility")
  }

  static func openMicrophoneSettings() {
    openPrivacyPane(anchor: "Privacy_Microphone")
  }

  private static func openPrivacyPane(anchor: String) {
    guard
      let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?\(anchor)")
    else { return }
    NSWorkspace.shared.open(url)
  }
}
