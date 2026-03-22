import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
  private enum SettingsKey {
    static let apiEndpoint = "transcription.apiEndpoint"
    static let modelName = "transcription.modelName"
    static let apiKey = "transcription.apiKey"
  }

  private static let keychainServiceName = Bundle.main.bundleIdentifier ?? "com.awave"

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
  @Published var apiKey: String {
    didSet {
      let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
      if trimmed.isEmpty {
        KeychainService.deletePassword(
          service: Self.keychainServiceName,
          account: SettingsKey.apiKey
        )
      } else {
        KeychainService.savePassword(
          trimmed,
          service: Self.keychainServiceName,
          account: SettingsKey.apiKey
        )
      }
    }
  }

  init() {
    let defaults = UserDefaults.standard
    apiEndpoint = defaults.string(forKey: SettingsKey.apiEndpoint) ?? ""
    modelName = defaults.string(forKey: SettingsKey.modelName) ?? ""
    apiKey =
      KeychainService.readPassword(
        service: Self.keychainServiceName,
        account: SettingsKey.apiKey
      )
      ?? ""
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

  var isModelNameValid: Bool {
    !modelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
