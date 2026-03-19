import SwiftUI

public struct PreferencesView: View {
    @Bindable var preferences: Preferences
    let launchAtLogin: LaunchAtLogin

    public init(preferences: Preferences, launchAtLogin: LaunchAtLogin) {
        self.preferences = preferences
        self.launchAtLogin = launchAtLogin
    }

    public var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: Binding(
                    get: { preferences.launchAtLogin },
                    set: { newValue in
                        if launchAtLogin.setEnabled(newValue) {
                            preferences.launchAtLogin = newValue
                        }
                    }
                ))
                Toggle("Activate at Launch", isOn: $preferences.activateAtLaunch)
                Picker("Default Duration", selection: $preferences.defaultDuration) {
                    ForEach(TimerPreset.allCases) { preset in
                        Text(preset.displayName).tag(preset.id)
                    }
                }
            }

            Section {
                Toggle("Disable on Battery Power", isOn: $preferences.disableOnBattery)
                if preferences.disableOnBattery {
                    Picker("Battery Threshold", selection: $preferences.batteryThreshold) {
                        Text("10%").tag(10)
                        Text("15%").tag(15)
                        Text("20%").tag(20)
                        Text("25%").tag(25)
                        Text("30%").tag(30)
                    }
                }
            }

            Section {
                scheduleSection
            }

            Section {
                Toggle("Global Hotkey (Cmd+Shift+K)", isOn: $preferences.hotKeyEnabled)
                Toggle("Check for Updates", isOn: $preferences.checkForUpdates)
            }
        }
        .formStyle(.grouped)
        .frame(width: 360, height: 420)
    }

    @ViewBuilder
    private var scheduleSection: some View {
        let scheduleBinding = Binding<Schedule>(
            get: { preferences.schedule ?? Schedule() },
            set: { preferences.schedule = $0 }
        )

        Toggle("Enable Schedule", isOn: scheduleBinding.isEnabled)

        if scheduleBinding.wrappedValue.isEnabled {
            HStack(spacing: 4) {
                ForEach(Weekday.allCases) { day in
                    Toggle(day.shortName, isOn: Binding(
                        get: { scheduleBinding.wrappedValue.weekdays.contains(day) },
                        set: { isOn in
                            if isOn {
                                scheduleBinding.wrappedValue.weekdays.insert(day)
                            } else {
                                scheduleBinding.wrappedValue.weekdays.remove(day)
                            }
                        }
                    ))
                    .toggleStyle(.button)
                    .controlSize(.small)
                }
            }

            DatePicker("Start", selection: Binding(
                get: {
                    Calendar.current.date(from: DateComponents(
                        hour: scheduleBinding.wrappedValue.startHour,
                        minute: scheduleBinding.wrappedValue.startMinute)) ?? .now
                },
                set: { date in
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                    scheduleBinding.wrappedValue.startHour = comps.hour ?? 9
                    scheduleBinding.wrappedValue.startMinute = comps.minute ?? 0
                }
            ), displayedComponents: .hourAndMinute)

            DatePicker("End", selection: Binding(
                get: {
                    Calendar.current.date(from: DateComponents(
                        hour: scheduleBinding.wrappedValue.endHour,
                        minute: scheduleBinding.wrappedValue.endMinute)) ?? .now
                },
                set: { date in
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                    scheduleBinding.wrappedValue.endHour = comps.hour ?? 17
                    scheduleBinding.wrappedValue.endMinute = comps.minute ?? 0
                }
            ), displayedComponents: .hourAndMinute)
        }
    }
}
