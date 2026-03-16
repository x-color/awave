import AppKit
import KeyboardShortcuts
import SwiftUI

struct MenuBarView: View {
  @ObservedObject var appState: AppState
  @State private var accessibilityAllowed = PermissionService.accessibilityAllowed()
  @State private var inputMonitoringAllowed = PermissionService.inputMonitoringAllowed()

  var body: some View {
    VStack(spacing: 2) {
      statusView

      Form {
        Section("Hotkey") {
          KeyboardShortcuts.Recorder(for: .record)
        }
        Section("Transcription") {
          VStack(alignment: .leading, spacing: 4) {
            Text("Endpoint")
              .frame(maxWidth: .infinity, alignment: .leading)
            TextField(
              "",
              text: $appState.apiEndpoint,
              prompt: Text(AppState.defaultAPIEndpoint)
            )
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: .infinity)
          }
          VStack(alignment: .leading, spacing: 4) {
            Text("Model")
              .frame(maxWidth: .infinity, alignment: .leading)
            TextField(
              "",
              text: $appState.modelName,
              prompt: Text(AppState.defaultModelName)
            )
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: .infinity)
          }
          if !appState.isAPIEndpointValid {
            Text("Enter a valid http/https URL.")
              .font(.caption2)
              .foregroundColor(.orange)
          }
        }
        Section {
          permissionsSection
        } header: {
          HStack(spacing: 8) {
            Text("Permissions")
            Spacer()
            Button("Refresh") {
              refreshPermissions()
            }
            .buttonStyle(.borderless)
            .font(.caption)
          }
        }

        Section {
          Button("Quit", role: .destructive) {
            NSApplication.shared.terminate(nil)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }
      }
      .formStyle(.grouped)
      .controlSize(.small)
    }
    .padding(8)
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
      Label("Awave", systemImage: "waveform")
        .font(.subheadline)
        .foregroundColor(.primary)

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
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
        }
      } else if let lastTranscription = appState.lastTranscription, !lastTranscription.isEmpty {
        VStack(spacing: 4) {
          Text("Last transcription:")
            .font(.caption2)
            .foregroundColor(.secondary)
          Text(lastTranscription)
            .font(.caption2)
            .lineLimit(2)
            .multilineTextAlignment(.center)
        }
      } else {
        Text("Ready")
          .font(.caption)
          .foregroundColor(.secondary)
        Text("Hold your shortcut to record")
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .multilineTextAlignment(.center)
    .padding(6)
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(Color(nsColor: .controlBackgroundColor))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
    )
  }

  private var permissionsSection: some View {
    VStack(spacing: 6) {
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
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding(.top, 1)
  }

  private func permissionRow(
    title: String,
    isAllowed: Bool,
    requestAction: @escaping () -> Void,
    openAction: @escaping () -> Void
  ) -> some View {
    LabeledContent {
      if isAllowed {
        Text("Allowed")
          .foregroundColor(.secondary)
      } else {
        HStack(spacing: 8) {
          Button("Enable") {
            requestAction()
            refreshPermissions()
          }
          Button("Open") {
            openAction()
          }
        }
        .buttonStyle(.borderless)
      }
    } label: {
      Label(title, systemImage: isAllowed ? "checkmark.circle.fill" : "xmark.circle.fill")
        .foregroundColor(isAllowed ? .green : .orange)
    }
    .font(.caption)
  }

  private func refreshPermissions() {
    accessibilityAllowed = PermissionService.accessibilityAllowed()
    inputMonitoringAllowed = PermissionService.inputMonitoringAllowed()
  }
}
