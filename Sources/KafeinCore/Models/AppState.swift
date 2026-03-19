import Foundation
import SwiftUI

@Observable
public final class AppState {
    public var isActive: Bool = false
    public var selectedPreset: TimerPreset?
    public var remainingSeconds: Int = 0
    public var batteryLevel: Int?
    public var isOnBattery: Bool = false
    public var hasBattery: Bool = false
    public var schedule: Schedule?
    public var isScheduleActive: Bool = false

    public var remainingFormatted: String {
        guard remainingSeconds > 0 else { return "" }
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    public var statusText: String {
        if isActive {
            if remainingSeconds > 0 {
                return "Active — \(remainingFormatted)"
            }
            return "Active — Indefinite"
        }
        return "Inactive"
    }

    public init() {}
}
