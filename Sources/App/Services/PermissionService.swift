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
}
