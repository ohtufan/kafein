import Foundation
import Testing

@testable import KafeinCore

@Suite("Schedule Tests")
struct ScheduleServiceTests {
    @Test("Schedule inactive when disabled")
    func disabledSchedule() {
        let schedule = Schedule(isEnabled: false, weekdays: [.monday])
        #expect(!schedule.isActiveNow())
    }

    @Test("Schedule inactive when no weekdays")
    func noWeekdays() {
        let schedule = Schedule(isEnabled: true, weekdays: [])
        #expect(!schedule.isActiveNow())
    }

    @Test("Schedule active during matching time")
    func activeMatch() {
        var calendar = Calendar.current
        calendar.timeZone = .current

        // Create a date for Wednesday at 12:00
        let components = DateComponents(
            year: 2025, month: 1, day: 8,  // Wednesday
            hour: 12, minute: 0
        )
        let date = calendar.date(from: components)!

        let schedule = Schedule(
            isEnabled: true,
            weekdays: [.wednesday],
            startHour: 9,
            startMinute: 0,
            endHour: 17,
            endMinute: 0
        )

        #expect(schedule.isActiveNow(calendar: calendar, date: date))
    }

    @Test("Schedule inactive outside time range")
    func outsideRange() {
        var calendar = Calendar.current
        calendar.timeZone = .current

        let components = DateComponents(
            year: 2025, month: 1, day: 8,  // Wednesday
            hour: 18, minute: 0
        )
        let date = calendar.date(from: components)!

        let schedule = Schedule(
            isEnabled: true,
            weekdays: [.wednesday],
            startHour: 9,
            startMinute: 0,
            endHour: 17,
            endMinute: 0
        )

        #expect(!schedule.isActiveNow(calendar: calendar, date: date))
    }

    @Test("Schedule inactive on wrong weekday")
    func wrongWeekday() {
        var calendar = Calendar.current
        calendar.timeZone = .current

        let components = DateComponents(
            year: 2025, month: 1, day: 7,  // Tuesday
            hour: 12, minute: 0
        )
        let date = calendar.date(from: components)!

        let schedule = Schedule(
            isEnabled: true,
            weekdays: [.wednesday],
            startHour: 9,
            startMinute: 0,
            endHour: 17,
            endMinute: 0
        )

        #expect(!schedule.isActiveNow(calendar: calendar, date: date))
    }

    @Test("Weekday init from calendar weekday")
    func weekdayInit() {
        #expect(Weekday(calendarWeekday: 1) == .sunday)
        #expect(Weekday(calendarWeekday: 2) == .monday)
        #expect(Weekday(calendarWeekday: 7) == .saturday)
        #expect(Weekday(calendarWeekday: 0) == nil)
        #expect(Weekday(calendarWeekday: 8) == nil)
    }
}
