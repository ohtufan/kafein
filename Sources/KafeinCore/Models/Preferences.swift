import Foundation

@Observable
public final class Preferences {
    private let defaults: UserDefaults
    private let scheduleKey = "kafein.schedule"
    private let batteryThresholdKey = "kafein.batteryThreshold"
    private let launchAtLoginKey = "kafein.launchAtLogin"
    private let hotKeyEnabledKey = "kafein.hotKeyEnabled"
    private let disableOnBatteryKey = "kafein.disableOnBattery"
    private let activateAtLaunchKey = "kafein.activateAtLaunch"
    private let defaultDurationKey = "kafein.defaultDuration"
    private let checkForUpdatesKey = "kafein.checkForUpdates"

    public var batteryThreshold: Int {
        didSet { defaults.set(batteryThreshold, forKey: batteryThresholdKey) }
    }

    public var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: launchAtLoginKey) }
    }

    public var hotKeyEnabled: Bool {
        didSet { defaults.set(hotKeyEnabled, forKey: hotKeyEnabledKey) }
    }

    public var disableOnBattery: Bool {
        didSet { defaults.set(disableOnBattery, forKey: disableOnBatteryKey) }
    }

    public var activateAtLaunch: Bool {
        didSet { defaults.set(activateAtLaunch, forKey: activateAtLaunchKey) }
    }

    public var defaultDuration: String {
        didSet { defaults.set(defaultDuration, forKey: defaultDurationKey) }
    }

    public var checkForUpdates: Bool {
        didSet { defaults.set(checkForUpdates, forKey: checkForUpdatesKey) }
    }

    public var defaultPreset: TimerPreset {
        TimerPreset.allCases.first { $0.id == defaultDuration } ?? .indefinite
    }

    public var schedule: Schedule? {
        didSet { saveSchedule() }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let threshold = defaults.integer(forKey: batteryThresholdKey)
        self.batteryThreshold = threshold > 0 ? threshold : 20

        self.launchAtLogin = defaults.bool(forKey: launchAtLoginKey)
        self.hotKeyEnabled = defaults.object(forKey: hotKeyEnabledKey) == nil
            ? true : defaults.bool(forKey: hotKeyEnabledKey)
        self.disableOnBattery = defaults.object(forKey: disableOnBatteryKey) == nil
            ? true : defaults.bool(forKey: disableOnBatteryKey)
        self.activateAtLaunch = defaults.bool(forKey: activateAtLaunchKey)
        self.defaultDuration = defaults.string(forKey: defaultDurationKey) ?? "indefinite"
        self.checkForUpdates = defaults.object(forKey: checkForUpdatesKey) == nil
            ? true : defaults.bool(forKey: checkForUpdatesKey)

        self.schedule = loadSchedule()
    }

    private func loadSchedule() -> Schedule? {
        guard let data = defaults.data(forKey: scheduleKey) else { return nil }
        return try? JSONDecoder().decode(Schedule.self, from: data)
    }

    private func saveSchedule() {
        if let schedule {
            defaults.set(try? JSONEncoder().encode(schedule), forKey: scheduleKey)
        } else {
            defaults.removeObject(forKey: scheduleKey)
        }
    }
}
