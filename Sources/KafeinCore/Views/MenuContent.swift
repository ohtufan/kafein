import SwiftUI

public struct MenuContent: View {
    @Bindable var state: AppState
    let sleepService: SleepPreventable
    let timerService: TimerService
    let batteryMonitor: BatteryMonitor
    let preferences: Preferences

    public init(
        state: AppState,
        sleepService: SleepPreventable,
        timerService: TimerService,
        batteryMonitor: BatteryMonitor,
        preferences: Preferences
    ) {
        self.state = state
        self.sleepService = sleepService
        self.timerService = timerService
        self.batteryMonitor = batteryMonitor
        self.preferences = preferences
    }

    public var body: some View {
        Button(state.isActive ? "Deactivate" : "Activate") {
            toggle(preset: .indefinite)
        }
        .keyboardShortcut("k", modifiers: [.command])

        Divider()

        if state.isActive {
            Text(state.statusText)
                .font(.caption)
            Divider()
        }

        Menu("Activate For...") {
            TimerPicker { preset in
                toggle(preset: preset)
            }
        }

        if let level = state.batteryLevel, state.hasBattery {
            Divider()
            Text("Battery: \(level)%\(state.isOnBattery ? " (Battery)" : " (AC)")")
                .font(.caption)
        }

        Divider()

        Button("Preferences...") {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        .keyboardShortcut(",", modifiers: [.command])

        Button("Quit Kafein") {
            deactivate()
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: [.command])
    }

    private func toggle(preset: TimerPreset) {
        if state.isActive {
            deactivate()
        } else {
            activate(preset: preset)
        }
    }

    private func activate(preset: TimerPreset) {
        do {
            try sleepService.activate()
            state.isActive = true
            state.selectedPreset = preset

            if let seconds = preset.totalSeconds {
                state.remainingSeconds = seconds
                timerService.start(
                    seconds: seconds,
                    onTick: { remaining in
                        Task { @MainActor in
                            state.remainingSeconds = remaining
                        }
                    },
                    onComplete: {
                        Task { @MainActor in
                            deactivate()
                        }
                    }
                )
            }
        } catch {
            // Activation failed silently — state remains inactive
        }
    }

    private func deactivate() {
        sleepService.deactivate()
        timerService.stop()
        state.isActive = false
        state.selectedPreset = nil
        state.remainingSeconds = 0
    }
}
