import Foundation
import AppKit

protocol PasteServiceProtocol: AnyObject {
    func paste(_ text: String)
}

final class PasteService: PasteServiceProtocol {
    func paste(_ text: String) {
        let pasteboard = NSPasteboard.general
        let previousContents = pasteboard.string(forType: .string)

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        simulatePaste()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let previous = previousContents {
                pasteboard.clearContents()
                pasteboard.setString(previous, forType: .string)
            }
        }
    }

    private func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(9), keyDown: true)
        keyDownEvent?.flags = .maskCommand
        keyDownEvent?.post(tap: .cghidEventTap)

        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(9), keyDown: false)
        keyUpEvent?.flags = .maskCommand
        keyUpEvent?.post(tap: .cghidEventTap)
    }
}
