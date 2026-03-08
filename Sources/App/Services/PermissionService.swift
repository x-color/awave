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

    static func inputMonitoringAllowed() -> Bool {
        if #available(macOS 10.15, *) {
            return CGPreflightListenEventAccess()
        }
        return true
    }

    static func requestInputMonitoringPermission() {
        if #available(macOS 10.15, *) {
            CGRequestListenEventAccess()
        }
    }

    static func openAccessibilitySettings() {
        openPrivacyPane(anchor: "Privacy_Accessibility")
    }

    static func openInputMonitoringSettings() {
        openPrivacyPane(anchor: "Privacy_InputMonitoring")
    }

    private static func openPrivacyPane(anchor: String) {
        guard
            let url = URL(
                string: "x-apple.systempreferences:com.apple.preference.security?\(anchor)")
        else { return }
        NSWorkspace.shared.open(url)
    }
}
