import AppKit
import Combine
import SwiftUI

@main
struct AwaveApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusItem: NSStatusItem?
  private var popover: NSPopover?
  private var overlayWindowController: OverlayWindowController?
  private var cancellables = Set<AnyCancellable>()

  private let appState = AppState()
  private let audioRecorder = AudioRecorderService()
  nonisolated private let transcriptionService = TranscriptionService()
  private let hotkeyManager = HotkeyManager()
  private let pasteService = PasteService()

  func applicationDidFinishLaunching(_ notification: Notification) {
    setupStatusItem()
    setupOverlayWindow()
    setupServices()
  }

  private func setupStatusItem() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    if let button = statusItem?.button {
      button.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Awave")
      button.image?.isTemplate = true
      button.action = #selector(togglePopover)
      button.target = self
    }

    let popover = NSPopover()
    popover.contentSize = NSSize(width: 260, height: 280)
    popover.behavior = .transient
    popover.contentViewController = NSHostingController(
      rootView: MenuBarView(appState: appState)
    )
    self.popover = popover

    bindStatusItemAppearance()
  }

  private func setupOverlayWindow() {
    overlayWindowController = OverlayWindowController()
  }

  private func setupServices() {
    audioRecorder.onAudioLevel = { [weak self] level in
      Task { @MainActor in
        guard let self else { return }
        self.appState.updateAudioLevel(level)
        self.overlayWindowController?.update(appState: self.appState)
      }
    }

    audioRecorder.onError = { [weak self] error in
      Task { @MainActor in
        self?.appState.setError(error.localizedDescription)
      }
    }

    hotkeyManager.onRecordStart = { [weak self] in
      Task { @MainActor in
        await self?.startRecording()
      }
    }

    hotkeyManager.onRecordStop = { [weak self] in
      Task { @MainActor in
        await self?.stopRecording()
      }
    }

    hotkeyManager.setup()
  }

  private func bindStatusItemAppearance() {
    appState.$isRecording
      .combineLatest(appState.$isTranscribing)
      .combineLatest(appState.$errorMessage)
      .receive(on: RunLoop.main)
      .sink { [weak self] _, _ in
        self?.updateStatusItemAppearance(animated: true)
      }
      .store(in: &cancellables)

    updateStatusItemAppearance(animated: false)
  }

  private func updateStatusItemAppearance(animated: Bool) {
    guard let button = statusItem?.button else { return }

    let image: NSImage?

    if appState.isRecording || appState.isTranscribing {
      image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Awave")?
        .withSymbolConfiguration(NSImage.SymbolConfiguration(paletteColors: [NSColor.systemGreen]))
      image?.isTemplate = false
    } else if appState.errorMessage != nil {
      image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Awave")?
        .withSymbolConfiguration(NSImage.SymbolConfiguration(paletteColors: [NSColor.systemYellow]))
      image?.isTemplate = false
    } else {
      image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Awave")
      image?.isTemplate = true
    }

    if animated {
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.25
        context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        button.animator().image = image
      }
    } else {
      button.image = image
    }
  }

  private func startRecording() async {
    appState.startRecording()
    overlayWindowController?.show(appState: appState)
    overlayWindowController?.update(appState: appState)

    do {
      try await audioRecorder.startRecording()
    } catch {
      appState.setError(error.localizedDescription)
      overlayWindowController?.hide()
    }
  }

  private func stopRecording() async {
    guard appState.isRecording else { return }

    let audioURL = audioRecorder.stopRecording()
    appState.stopRecording()
    overlayWindowController?.update(appState: appState)

    guard let url = audioURL else {
      appState.setError("Failed to save recording")
      return
    }

    await transcribe(audioURL: url)
  }

  private func transcribe(audioURL: URL) async {
    guard let baseURL = appState.apiBaseURL else {
      appState.setError("Invalid API endpoint URL")
      overlayWindowController?.update(appState: appState)
      overlayWindowController?.hide()
      return
    }

    let modelName = appState.modelName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !modelName.isEmpty else {
      appState.setError("Model name is required")
      overlayWindowController?.update(appState: appState)
      overlayWindowController?.hide()
      return
    }

    appState.startTranscribing()
    overlayWindowController?.update(appState: appState)

    // Capture a local reference to avoid data races
    let transcriptionService = self.transcriptionService

    do {
      let apiKey = appState.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
      let text = try await transcriptionService.transcribe(
        audioURL: audioURL,
        baseURL: baseURL,
        model: modelName,
        apiKey: apiKey.isEmpty ? nil : apiKey
      )
      appState.finishTranscribing(text: text)
      overlayWindowController?.update(appState: appState)
      overlayWindowController?.hide()
      pasteService.paste(text)
    } catch {
      appState.setError(error.localizedDescription)
      overlayWindowController?.update(appState: appState)
      overlayWindowController?.hide()
    }
  }

  @objc private func togglePopover() {
    guard let button = statusItem?.button, let popover = popover else { return }

    if popover.isShown {
      popover.performClose(nil)
    } else {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
  }
}
