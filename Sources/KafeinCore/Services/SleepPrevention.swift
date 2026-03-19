import Foundation
import IOKit
import IOKit.pwr_mgt

public final class SleepPrevention: SleepPreventable {
    private var assertionID: IOPMAssertionID = 0
    public private(set) var isActive: Bool = false

    public init() {}

    public func activate() throws {
        guard !isActive else { return }

        let reason = "Kafein is preventing sleep" as CFString

        // Prevent display sleep (also prevents system sleep and screen saver)
        let status = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        guard status == kIOReturnSuccess else {
            throw SleepPreventionError.assertionFailed(status)
        }

        isActive = true
    }

    public func deactivate() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isActive = false
    }

    deinit {
        deactivate()
    }
}

public enum SleepPreventionError: LocalizedError {
    case assertionFailed(IOReturn)

    public var errorDescription: String? {
        switch self {
        case .assertionFailed(let code):
            return "Failed to create sleep assertion (code: \(code))"
        }
    }
}
