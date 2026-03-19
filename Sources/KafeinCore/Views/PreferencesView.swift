import SwiftUI

public struct PreferencesView: View {
    @Bindable var preferences: Preferences
    let launchAtLogin: LaunchAtLogin

    public init(preferences: Preferences, launchAtLogin: LaunchAtLogin) {
        self.preferences = preferences
        self.launchAtLogin = launchAtLogin
    }

    public var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gear") }

            batteryTab
                .tabItem { Label("Battery", systemImage: "battery.100") }

            scheduleTab
                .tabItem { Label("Schedule", systemImage: "calendar") }
        }
        .frame(width: 400, height: 250)
    }

    private var generalTab: some View {
        Form {
            Toggle("Launch at Login", isOn: Binding(
                get: { preferences.launchAtLogin },
                set: { newValue in
                    if launchAtLogin.setEnabled(newValue) {
                        preferences.launchAtLogin = newValue
                    }
                }
            ))

            Toggle("Activate at Launch", isOn: $preferences.activateAtLaunch)

            Toggle("Global Hotkey (Cmd+Shift+K)", isOn: $preferences.hotKeyEnabled)

            Toggle("Check for Updates", isOn: $preferences.checkForUpdates)

            HStack {
                Text("Default Duration:")
                Picker("", selection: $preferences.defaultDuration) {
                    ForEach(TimerPreset.allCases) { preset in
                        Text(preset.displayName).tag(preset.id)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
            }
        }
        .padding()
    }

    private var batteryTab: some View {
        Form {
            Toggle("Disable on Battery Power", isOn: $preferences.disableOnBattery)

            if preferences.disableOnBattery {
                HStack {
                    Text("Battery Threshold:")
                    Picker("", selection: $preferences.batteryThreshold) {
                        Text("10%").tag(10)
                        Text("15%").tag(15)
                        Text("20%").tag(20)
                        Text("25%").tag(25)
                        Text("30%").tag(30)
                    }
                    .labelsHidden()
                    .frame(width: 80)
                }
            }
        }
        .padding()
    }

    private var scheduleTab: some View {
        VStack {
            let scheduleBinding = Binding<Schedule>(
                get: { preferences.schedule ?? Schedule() },
                set: { preferences.schedule = $0 }
            )
            ScheduleEditor(schedule: scheduleBinding)
        }
        .padding()
    }
}
