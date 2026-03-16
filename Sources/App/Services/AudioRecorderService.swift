@preconcurrency import AVFoundation
import Foundation

final class AudioRecorderService: @unchecked Sendable {
  private var audioEngine: AVAudioEngine?
  private var audioFile: AVAudioFile?
  private var tempFileURL: URL?
  private let audioQueue = DispatchQueue(label: "com.awave.audio", qos: .userInitiated)
  private let stateQueue = DispatchQueue(label: "com.awave.audio.state")

  var onAudioLevel: ((Float) -> Void)?
  var onError: ((Error) -> Void)?

  init() {
    setupTempFile()
  }

  private func setupTempFile() {
    let tempDir = FileManager.default.temporaryDirectory
    let url = tempDir.appendingPathComponent("awave_recording_\(UUID().uuidString).wav")
    stateQueue.sync {
      tempFileURL = url
    }
  }

  nonisolated func startRecording() async throws {
    let permission = await AVAudioApplication.requestRecordPermission()
    guard permission else {
      throw AudioRecorderError.microphonePermissionDenied
    }

    let engine = AVAudioEngine()
    let inputNode = engine.inputNode
    let format = inputNode.outputFormat(forBus: 0)

    guard let fileURL = setupTempFileSync() else {
      throw AudioRecorderError.fileCreationFailed
    }

    let audioFormat = AVAudioFormat(
      commonFormat: .pcmFormatFloat32,
      sampleRate: format.sampleRate,
      channels: 1,
      interleaved: false
    )!

    let file = try AVAudioFile(
      forWriting: fileURL,
      settings: audioFormat.settings
    )

    stateQueue.sync {
      audioEngine = engine
      audioFile = file
    }

    inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
      self.processAudioBuffer(buffer)
    }

    try engine.start()
  }

  private func setupTempFileSync() -> URL? {
    let tempDir = FileManager.default.temporaryDirectory
    let url = tempDir.appendingPathComponent("awave_recording_\(UUID().uuidString).wav")
    stateQueue.sync {
      tempFileURL = url
    }
    return url
  }

  private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
    guard let channelData = buffer.floatChannelData?[0] else { return }
    let frameLength = Int(buffer.frameLength)

    var sum: Float = 0
    for i in 0..<frameLength {
      sum += abs(channelData[i])
    }
    let average = sum / Float(frameLength)
    let db = 20 * log10(max(average, 0.0001))
    let normalizedLevel = max(0, min(1, (db + 60) / 60))

    let level = normalizedLevel
    DispatchQueue.main.async { [weak self] in
      self?.onAudioLevel?(level)
    }

    let file = stateQueue.sync { audioFile }
    audioQueue.async {
      try? file?.write(from: buffer)
    }
  }

  nonisolated func stopRecording() -> URL? {
    let snapshot = stateQueue.sync { () -> (AVAudioEngine?, URL?) in
      let engine = audioEngine
      let fileURL = tempFileURL
      audioEngine = nil
      audioFile = nil
      return (engine, fileURL)
    }

    snapshot.0?.inputNode.removeTap(onBus: 0)
    snapshot.0?.stop()

    return snapshot.1
  }
}

enum AudioRecorderError: LocalizedError {
  case microphonePermissionDenied
  case fileCreationFailed

  var errorDescription: String? {
    switch self {
    case .microphonePermissionDenied:
      return "Microphone permission denied. Please enable in System Settings."
    case .fileCreationFailed:
      return "Failed to create audio file."
    }
  }
}
