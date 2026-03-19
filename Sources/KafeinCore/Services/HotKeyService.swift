import Carbon
import Foundation

public final class HotKeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var onToggle: (() -> Void)?

    // Default: Cmd+Shift+K
    private let defaultKeyCode: UInt32 = 0x28  // kVK_ANSI_K
    private let defaultModifiers: UInt32 = UInt32(cmdKey | shiftKey)

    public init() {}

    public func register(onToggle: @escaping () -> Void) -> Bool {
        self.onToggle = onToggle
        return registerHotKey(keyCode: defaultKeyCode, modifiers: defaultModifiers)
    }

    public func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    private func registerHotKey(keyCode: UInt32, modifiers: UInt32) -> Bool {
        let hotKeyID = EventHotKeyID(signature: OSType(0x4B46_4E00), id: 1)  // "KFN\0"

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData -> OSStatus in
                guard let userData else { return OSStatus(eventNotHandledErr) }
                let service = Unmanaged<HotKeyService>.fromOpaque(userData).takeUnretainedValue()
                service.onToggle?()
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &eventHandler
        )

        guard status == noErr else { return false }

        let regStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        return regStatus == noErr
    }

    deinit {
        unregister()
    }
}
