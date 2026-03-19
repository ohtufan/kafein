import KafeinCore
import SwiftUI

@main
struct KafeinApp: App {
    @State private var appState = AppState()
    @State private var preferences = Preferences()

    private let sleepPrevention = SleepPrevention()
    private let timerService = TimerService()
    private let batteryMonitor = BatteryMonitor()
    private let scheduleService = ScheduleService()
    private let hotKeyService = HotKeyService()
    private let launchAtLogin = LaunchAtLogin()

    var body: some Scene {
        MenuBarExtra {
            MenuContent(
                state: appState,
                sleepService: sleepPrevention,
                timerService: timerService,
                batteryMonitor: batteryMonitor,
                preferences: preferences
            )
        } label: {
            Image(systemName: StatusIcon.name(isActive: appState.isActive))
        }
        .menuBarExtraStyle(.menu)

        Settings {
            PreferencesView(preferences: preferences, launchAtLogin: launchAtLogin)
        }
    }

    init() {
        setupHotKey()
        setupBatteryMonitoring()
        setupSchedule()
    }

    private func setupHotKey() {
        guard preferences.hotKeyEnabled else { return }
        _ = hotKeyService.register { [sleepPrevention, timerService] in
            Task { @MainActor in
                if appState.isActive {
                    sleepPrevention.deactivate()
                    timerService.stop()
                    appState.isActive = false
                    appState.selectedPreset = nil
                    appState.remainingSeconds = 0
                } else {
                    try? sleepPrevention.activate()
                    appState.isActive = true
                    appState.selectedPreset = .indefinite
                }
            }
        }
    }

    private func setupBatteryMonitoring() {
        Task {
            await batteryMonitor.startMonitoring()
            // Periodically sync battery state
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                await MainActor.run {
                    appState.batteryLevel = batteryMonitor.batteryLevel
                    appState.isOnBattery = batteryMonitor.isOnBattery
                    appState.hasBattery = batteryMonitor.hasBattery

                    // Auto-deactivate on low battery
                    if preferences.disableOnBattery,
                       appState.isActive,
                       appState.isOnBattery,
                       let level = appState.batteryLevel,
                       level <= preferences.batteryThreshold
                    {
                        sleepPrevention.deactivate()
                        timerService.stop()
                        appState.isActive = false
                        appState.selectedPreset = nil
                        appState.remainingSeconds = 0
                    }
                }
            }
        }
    }

    private func setupSchedule() {
        guard let schedule = preferences.schedule, schedule.isEnabled else { return }
        scheduleService.start(schedule: schedule) { [sleepPrevention] shouldBeActive in
            Task { @MainActor in
                if shouldBeActive && !appState.isActive {
                    try? sleepPrevention.activate()
                    appState.isActive = true
                    appState.isScheduleActive = true
                    appState.selectedPreset = .indefinite
                } else if !shouldBeActive && appState.isScheduleActive {
                    sleepPrevention.deactivate()
                    timerService.stop()
                    appState.isActive = false
                    appState.isScheduleActive = false
                    appState.selectedPreset = nil
                    appState.remainingSeconds = 0
                }
            }
        }
    }
}
