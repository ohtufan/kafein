import Foundation
import Testing

@testable import KafeinCore

@Suite("Preferences Tests")
struct PreferencesTests {
    @Test("Default values")
    func defaults() {
        let testDefaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let prefs = Preferences(defaults: testDefaults)

        #expect(prefs.batteryThreshold == 20)
        #expect(prefs.launchAtLogin == false)
        #expect(prefs.hotKeyEnabled == true)
        #expect(prefs.disableOnBattery == true)
        #expect(prefs.activateAtLaunch == false)
        #expect(prefs.defaultDuration == "indefinite")
        #expect(prefs.defaultPreset == .indefinite)
        #expect(prefs.schedule == nil)
    }

    @Test("Battery threshold persists")
    func batteryThreshold() {
        let suiteName = "test.\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!

        let prefs = Preferences(defaults: testDefaults)
        prefs.batteryThreshold = 15

        let prefs2 = Preferences(defaults: testDefaults)
        #expect(prefs2.batteryThreshold == 15)

        testDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test("Schedule persists")
    func schedulePersistence() {
        let suiteName = "test.\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!

        let prefs = Preferences(defaults: testDefaults)
        prefs.schedule = Schedule(
            isEnabled: true,
            weekdays: [.monday, .friday],
            startHour: 10,
            startMinute: 30,
            endHour: 16,
            endMinute: 0
        )

        let prefs2 = Preferences(defaults: testDefaults)
        #expect(prefs2.schedule?.isEnabled == true)
        #expect(prefs2.schedule?.weekdays == Set([Weekday.monday, Weekday.friday]))
        #expect(prefs2.schedule?.startHour == 10)

        testDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test("Activate at launch persists")
    func activateAtLaunch() {
        let suiteName = "test.\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!

        let prefs = Preferences(defaults: testDefaults)
        prefs.activateAtLaunch = true

        let prefs2 = Preferences(defaults: testDefaults)
        #expect(prefs2.activateAtLaunch == true)

        testDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test("Default duration persists")
    func defaultDuration() {
        let suiteName = "test.\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!

        let prefs = Preferences(defaults: testDefaults)
        prefs.defaultDuration = "30m"

        let prefs2 = Preferences(defaults: testDefaults)
        #expect(prefs2.defaultDuration == "30m")
        #expect(prefs2.defaultPreset == .minutes30)

        testDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test("Schedule removal")
    func scheduleRemoval() {
        let suiteName = "test.\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!

        let prefs = Preferences(defaults: testDefaults)
        prefs.schedule = Schedule(isEnabled: true, weekdays: [.monday])
        prefs.schedule = nil

        let prefs2 = Preferences(defaults: testDefaults)
        #expect(prefs2.schedule == nil)

        testDefaults.removePersistentDomain(forName: suiteName)
    }
}
