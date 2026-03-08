import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var currentLevel: Float = 0
    @Published var isTranscribing: Bool = false
    @Published var lastTranscription: String?
    @Published var errorMessage: String?

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
