import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
  private enum SettingsKey {
    static let apiEndpoint = "transcription.apiEndpoint"
    static let modelName = "transcription.modelName"
  }

  static let defaultAPIEndpoint = "http://localhost:8000"
  static let defaultModelName = "Systran/faster-whisper-small"

  @Published var isRecording: Bool = false
  @Published var currentLevel: Float = 0
  @Published var isTranscribing: Bool = false
  @Published var lastTranscription: String?
  @Published var errorMessage: String?
  @Published var apiEndpoint: String {
    didSet {
      UserDefaults.standard.set(apiEndpoint, forKey: SettingsKey.apiEndpoint)
    }
  }
  @Published var modelName: String {
    didSet {
      UserDefaults.standard.set(modelName, forKey: SettingsKey.modelName)
    }
  }

  init() {
    let defaults = UserDefaults.standard
    apiEndpoint = defaults.string(forKey: SettingsKey.apiEndpoint) ?? Self.defaultAPIEndpoint
    modelName = defaults.string(forKey: SettingsKey.modelName) ?? Self.defaultModelName
  }

  var apiBaseURL: URL? {
    let trimmed = apiEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let url = URL(string: trimmed), let scheme = url.scheme else {
      return nil
    }

    let isAllowedScheme = scheme == "http" || scheme == "https"
    return isAllowedScheme ? url : nil
  }

  var isAPIEndpointValid: Bool {
    apiBaseURL != nil
  }

  func updateAudioLevel(_ level: Float) {
    currentLevel = max(0, min(level, 1))
  }

  func resetAudioLevel() {
    currentLevel = 0
  }

  func startRecording() {
    isRecording = true
    resetAudioLevel()
    errorMessage = nil
  }

  func stopRecording() {
    isRecording = false
  }

  func startTranscribing() {
    isTranscribing = true
    errorMessage = nil
  }

  func finishTranscribing(text: String?) {
    isTranscribing = false
    lastTranscription = text
  }

  func setError(_ message: String) {
    errorMessage = message
    isRecording = false
    isTranscribing = false
  }
}
