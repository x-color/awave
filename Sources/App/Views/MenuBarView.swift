import AppKit
import KeyboardShortcuts
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var appState: AppState
    @State private var accessibilityAllowed = PermissionService.accessibilityAllowed()
    @State private var inputMonitoringAllowed = PermissionService.inputMonitoringAllowed()

    var body: some View {
        VStack(spacing: 12) {
            statusView
            Divider()
            hotkeySection
            Divider()
            permissionsSection
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(width: 260)
        .onAppear {
            refreshPermissions()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
        ) { _ in
            refreshPermissions()
        }
    }

    @ViewBuilder
    private var statusView: some View {
        VStack(spacing: 4) {
            if appState.isRecording {
                Label("Recording...", systemImage: "waveform")
                    .foregroundColor(.red)
            } else if appState.isTranscribing {
                Label("Transcribing...", systemImage: "arrow.triangle.2.circlepath")
                    .foregroundColor(.orange)
            } else if let error = appState.errorMessage {
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else if let lastTranscription = appState.lastTranscription, !lastTranscription.isEmpty
            {
                VStack(spacing: 4) {
                    Text("Last transcription:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lastTranscription)
                        .font(.caption)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text("Ready")
                    .foregroundColor(.secondary)
                Text("Hold your shortcut to record")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var hotkeySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hotkey")
                .font(.caption)
                .foregroundColor(.secondary)
            KeyboardShortcuts.Recorder(for: .record)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Permissions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Refresh") {
                    refreshPermissions()
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
            permissionRow(
                title: "Accessibility",
                isAllowed: accessibilityAllowed,
                requestAction: PermissionService.requestAccessibilityPermission,
                openAction: PermissionService.openAccessibilitySettings
            )
            permissionRow(
                title: "Input Monitoring",
                isAllowed: inputMonitoringAllowed,
                requestAction: PermissionService.requestInputMonitoringPermission,
                openAction: PermissionService.openInputMonitoringSettings
            )
            if !accessibilityAllowed || !inputMonitoringAllowed {
                Text("Enable permissions for hotkey and paste.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func permissionRow(
        title: String,
        isAllowed: Bool,
        requestAction: @escaping () -> Void,
        openAction: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 6) {
            Label(title, systemImage: isAllowed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isAllowed ? .green : .orange)
                .font(.caption)
            Spacer()
            if !isAllowed {
                Button("Enable") {
                    requestAction()
                    refreshPermissions()
                }
                .buttonStyle(.borderless)
                .font(.caption)
                Button("Open") {
                    openAction()
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
        }
    }

    private func refreshPermissions() {
        accessibilityAllowed = PermissionService.accessibilityAllowed()
        inputMonitoringAllowed = PermissionService.inputMonitoringAllowed()
    }
}
