import Foundation
@preconcurrency import KeyboardShortcuts
import AppKit

extension KeyboardShortcuts.Name {
    static let record = Self("record")
}

final class HotkeyManager: @unchecked Sendable {
    private var isPressed = false
    private let lock = NSLock()

    var onRecordStart: (() -> Void)?
    var onRecordStop: (() -> Void)?

    func setup() {
        if KeyboardShortcuts.getShortcut(for: .record) == nil {
            KeyboardShortcuts.setShortcut(.init(.a, modifiers: [.command, .shift]), for: .record)
        }

        KeyboardShortcuts.onKeyUp(for: .record) { [weak self] in
            self?.handleKeyUp()
        }

        KeyboardShortcuts.onKeyDown(for: .record) { [weak self] in
            self?.handleKeyDown()
        }
    }

    private func handleKeyDown() {
        lock.lock()
        defer { lock.unlock() }
        guard !isPressed else { return }
        isPressed = true
        DispatchQueue.main.async { [weak self] in
            self?.onRecordStart?()
        }
    }

    private func handleKeyUp() {
        lock.lock()
        defer { lock.unlock() }
        guard isPressed else { return }
        isPressed = false
        DispatchQueue.main.async { [weak self] in
            self?.onRecordStop?()
        }
    }
}
