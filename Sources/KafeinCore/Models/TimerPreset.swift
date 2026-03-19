import Foundation

public enum TimerPreset: Hashable, Identifiable {
    case minutes15
    case minutes30
    case hours1
    case hours2
    case custom(minutes: Int)
    case indefinite

    public var id: String {
        switch self {
        case .minutes15: return "15m"
        case .minutes30: return "30m"
        case .hours1: return "1h"
        case .hours2: return "2h"
        case .custom(let m): return "custom_\(m)"
        case .indefinite: return "indefinite"
        }
    }

    public var totalSeconds: Int? {
        switch self {
        case .minutes15: return 15 * 60
        case .minutes30: return 30 * 60
        case .hours1: return 3600
        case .hours2: return 7200
        case .custom(let m): return m * 60
        case .indefinite: return nil
        }
    }

    public var displayName: String {
        switch self {
        case .minutes15: return "15 Minutes"
        case .minutes30: return "30 Minutes"
        case .hours1: return "1 Hour"
        case .hours2: return "2 Hours"
        case .custom(let m): return "\(m) Minutes"
        case .indefinite: return "Indefinitely"
        }
    }

    public static let defaultPresets: [TimerPreset] = [
        .minutes15, .minutes30, .hours1, .hours2, .indefinite,
    ]
}
