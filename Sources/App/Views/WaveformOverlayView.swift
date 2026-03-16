import AppKit
import SwiftUI

struct WaveformOverlayView: View {
  @ObservedObject var appState: AppState
  private let cornerRadius: CGFloat = 16
  private let viewSize = CGSize(width: 170, height: 110)

  var body: some View {
    ZStack {
      WaveformView(level: appState.currentLevel, isTranscribing: appState.isTranscribing)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    .frame(width: viewSize.width, height: viewSize.height)
    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
    .opacity(appState.isRecording || appState.isTranscribing ? 1 : 0)
    .animation(.easeInOut(duration: 0.2), value: appState.isRecording)
    .animation(.easeInOut(duration: 0.2), value: appState.isTranscribing)
    .padding(6)
  }
}

@MainActor
final class OverlayWindowController: NSObject {
  private var window: NSWindow?
  private var hostingView: NSHostingView<WaveformOverlayView>?

  func show(appState: AppState) {
    guard window == nil else {
      window?.orderFront(nil)
      return
    }

    let overlayView = WaveformOverlayView(appState: appState)
    let hostingView = NSHostingView(rootView: overlayView)
    self.hostingView = hostingView

    let screenFrame = NSScreen.main?.visibleFrame ?? .zero
    let windowSize = NSSize(width: 190, height: 90)
    let windowOrigin = NSPoint(
      x: screenFrame.midX - windowSize.width / 2,
      y: screenFrame.minY + 50
    )

    let window = NSWindow(
      contentRect: NSRect(origin: windowOrigin, size: windowSize),
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )

    window.isOpaque = false
    window.backgroundColor = .clear
    window.level = .floating
    window.hasShadow = true
    window.contentView = hostingView
    window.ignoresMouseEvents = true
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    window.orderFront(nil)
    self.window = window
  }

  func hide() {
    window?.orderOut(nil)
    window = nil
    hostingView = nil
  }

  func update(appState: AppState) {
    hostingView?.rootView = WaveformOverlayView(appState: appState)
  }
}
