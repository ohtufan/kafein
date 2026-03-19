import Foundation

public struct Schedule: Codable, Equatable {
    public var isEnabled: Bool
    public var weekdays: Set<Weekday>
    public var startHour: Int
    public var startMinute: Int
    public var endHour: Int
    public var endMinute: Int

    public init(
        isEnabled: Bool = false,
        weekdays: Set<Weekday> = [],
        startHour: Int = 9,
        startMinute: Int = 0,
        endHour: Int = 17,
        endMinute: Int = 0
    ) {
        self.isEnabled = isEnabled
        self.weekdays = weekdays
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
    }

    public func isActiveNow(calendar: Calendar = .current, date: Date = .now) -> Bool {
        guard isEnabled, !weekdays.isEmpty else { return false }

        let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        guard let currentWeekday = components.weekday,
              let hour = components.hour,
              let minute = components.minute,
              let weekday = Weekday(calendarWeekday: currentWeekday)
        else { return false }

        guard weekdays.contains(weekday) else { return false }

        let currentMinutes = hour * 60 + minute
        let startMinutes = startHour * 60 + self.startMinute
        let endMinutes = endHour * 60 + self.endMinute

        return currentMinutes >= startMinutes && currentMinutes < endMinutes
    }
}

public enum Weekday: Int, Codable, CaseIterable, Identifiable, Comparable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7

    public var id: Int { rawValue }

    public var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }

    public init?(calendarWeekday: Int) {
        // Calendar weekday: 1=Sunday, 2=Monday, ...
        switch calendarWeekday {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }

    public static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
