import AppKit
import KeyboardShortcuts
import SwiftUI

extension Color {
  static let tertiaryLabel = Color(nsColor: .tertiaryLabelColor)
  static let secondaryLabel = Color(nsColor: .secondaryLabelColor)
}

struct MenuBarView: View {
  @ObservedObject var appState: AppState
  @State private var accessibilityAllowed = PermissionService.accessibilityAllowed()
  @State private var inputMonitoringAllowed = PermissionService.inputMonitoringAllowed()

  var body: some View {
    VStack(spacing: 0) {
      statusView
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 10)

      Divider()
        .padding(.horizontal, 10)

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          sectionBlock(title: "HOTKEY") {
            KeyboardShortcuts.Recorder(for: .record)
              .frame(maxWidth: .infinity, alignment: .leading)
          }

          thinDivider

          sectionBlock(title: "TRANSCRIPTION") {
            fieldRow(label: "Endpoint") {
              TextField(
                "",
                text: $appState.apiEndpoint,
                prompt: Text("https://xxx")
                  .foregroundColor(.tertiaryLabel)
              )
              .disableAutocorrection(true)
              .textFieldStyle(.plain)
              .font(.system(size: 11, design: .monospaced))
              .padding(.horizontal, 8)
              .padding(.vertical, 5)
              .background(
                RoundedRectangle(cornerRadius: 5)
                  .fill(Color(nsColor: .controlBackgroundColor))
              )
              .overlay(
                RoundedRectangle(cornerRadius: 5)
                  .stroke(
                    appState.isAPIEndpointValid
                      ? Color(nsColor: .separatorColor)
                      : Color.orange.opacity(0.6),
                    lineWidth: 0.75
                  )
              )
            }

            fieldRow(label: "Model") {
              TextField(
                "",
                text: $appState.modelName,
                prompt: Text("Model Name")
                  .foregroundColor(.tertiaryLabel)
              )
              .disableAutocorrection(true)
              .textFieldStyle(.plain)
              .font(.system(size: 11, design: .monospaced))
              .padding(.horizontal, 8)
              .padding(.vertical, 5)
              .background(
                RoundedRectangle(cornerRadius: 5)
                  .fill(Color(nsColor: .controlBackgroundColor))
              )
              .overlay(
                RoundedRectangle(cornerRadius: 5)
                  .stroke(
                    appState.isModelNameValid
                      ? Color(nsColor: .separatorColor)
                      : Color.orange.opacity(0.6),
                    lineWidth: 0.75
                  )
              )
            }

            fieldRow(label: "API Key") {
              SecureField(
                "",
                text: $appState.apiKey,
                prompt: Text("Optional")
                  .foregroundColor(.tertiaryLabel)
              )
              .textFieldStyle(.plain)
              .font(.system(size: 11, design: .monospaced))
              .padding(.horizontal, 8)
              .padding(.vertical, 5)
              .background(
                RoundedRectangle(cornerRadius: 5)
                  .fill(Color(nsColor: .controlBackgroundColor))
              )
              .overlay(
                RoundedRectangle(cornerRadius: 5)
                  .stroke(
                    Color(nsColor: .separatorColor),
                    lineWidth: 0.75
                  )
              )
            }

            if !appState.isAPIEndpointValid {
              HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                  .font(.system(size: 9))
                Text("Enter a valid http/https URL.")
                  .font(.system(size: 10))
              }
              .foregroundColor(.orange)
              .padding(.top, 2)
            }

            if !appState.isModelNameValid {
              HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                  .font(.system(size: 9))
                Text("Enter a model name.")
                  .font(.system(size: 10))
              }
              .foregroundColor(.orange)
              .padding(.top, 2)
            }
          }

          thinDivider

          sectionBlock(title: "PERMISSIONS") {
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
            }
            if !accessibilityAllowed || !inputMonitoringAllowed {
              HStack(spacing: 4) {
                Image(systemName: "info.circle.fill")
                  .font(.system(size: 9))
                Text("Required for hotkey and paste.")
                  .font(.system(size: 10))
              }
              .foregroundColor(.secondary)
              .padding(.top, 2)
            }
          }
        }
      }
      .frame(maxHeight: 320)

      Divider()
        .padding(.horizontal, 10)

      HStack {
        Button {
          refreshPermissions()
        } label: {
          Label("Refresh", systemImage: "arrow.clockwise")
            .font(.system(size: 10))
            .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)

        Spacer()

        Button("Quit") {
          NSApplication.shared.terminate(nil)
        }
        .buttonStyle(.plain)
        .font(.system(size: 10))
        .foregroundColor(.red.opacity(0.8))
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
    }
    .frame(width: 270)
    .background(Color(nsColor: .windowBackgroundColor))
    .onAppear { refreshPermissions() }
    .onReceive(
      NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
    ) { _ in refreshPermissions() }
  }

  // MARK: - Status

  @ViewBuilder
  private var statusView: some View {
    HStack(spacing: 8) {
      ZStack {
        Circle()
          .fill(statusColor.opacity(0.15))
          .frame(width: 28, height: 28)
        Image(systemName: statusIcon)
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(statusColor)
      }

      VStack(alignment: .leading, spacing: 1) {
        Text("Awave")
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(.primary)
        Text(statusText)
          .font(.system(size: 10))
          .foregroundColor(.secondary)
          .lineLimit(1)
      }

      Spacer()
    }
    .animation(.easeInOut(duration: 0.2), value: statusColorStyle)
  }

  private var statusIcon: String {
    if appState.isRecording { return "waveform" }
    if appState.isTranscribing { return "arrow.triangle.2.circlepath" }
    if appState.errorMessage != nil { return "exclamationmark.triangle.fill" }
    return "checkmark.circle.fill"
  }

  private var statusColor: Color {
    switch statusColorStyle {
    case .recording:
      return Color(nsColor: .systemGreen)
    case .error:
      return Color(nsColor: .systemYellow)
    case .idle:
      return .primary
    }
  }

  private var statusColorStyle: StatusColorStyle {
    if appState.errorMessage != nil { return .error }
    if appState.isRecording { return .recording }
    return .idle
  }

  private enum StatusColorStyle: Equatable {
    case idle
    case recording
    case error
  }

  private var statusText: String {
    if appState.isRecording { return "Recording…" }
    if appState.isTranscribing { return "Transcribing…" }
    if let error = appState.errorMessage { return error }
    if let last = appState.lastTranscription, !last.isEmpty {
      return last
    }
    return "Hold shortcut to record"
  }

  // MARK: - Layout helpers

  private var thinDivider: some View {
    Divider()
      .padding(.horizontal, 14)
      .opacity(0.5)
  }

  @ViewBuilder
  private func sectionBlock<Content: View>(
    title: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.system(size: 9, weight: .semibold, design: .monospaced))
        .tracking(1.2)
        .foregroundColor(.tertiaryLabel)

      content()
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
  }

  @ViewBuilder
  private func fieldRow<Content: View>(
    label: String,
    @ViewBuilder field: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(label)
        .font(.system(size: 10, weight: .medium))
        .foregroundColor(.secondaryLabel)
      field()
    }
  }

  // MARK: - Permission row

  private func permissionRow(
    title: String,
    isAllowed: Bool,
    requestAction: @escaping () -> Void,
    openAction: @escaping () -> Void
  ) -> some View {
    HStack(spacing: 6) {
      Circle()
        .fill(isAllowed ? Color.green : Color.orange)
        .frame(width: 6, height: 6)

      Text(title)
        .font(.system(size: 11))
        .foregroundColor(.primary)

      Spacer()

      if isAllowed {
        Text("Allowed")
          .font(.system(size: 10))
          .foregroundColor(.secondary)
      } else {
        HStack(spacing: 4) {
          Button("Enable") {
            requestAction()
            refreshPermissions()
          }
          .buttonStyle(ChipButtonStyle())

          Button("Open") {
            openAction()
          }
          .buttonStyle(ChipButtonStyle())
        }
      }
    }
  }

  private func refreshPermissions() {
    accessibilityAllowed = PermissionService.accessibilityAllowed()
    inputMonitoringAllowed = PermissionService.inputMonitoringAllowed()
  }
}

// MARK: - Chip Button Style

struct ChipButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 10))
      .foregroundColor(configuration.isPressed ? .primary : .secondary)
      .padding(.horizontal, 7)
      .padding(.vertical, 3)
      .background(
        RoundedRectangle(cornerRadius: 4)
          .fill(Color(nsColor: .controlColor).opacity(configuration.isPressed ? 0.8 : 1))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 4)
          .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
      )
  }
}
