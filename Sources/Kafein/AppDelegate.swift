import AppKit
import KafeinCore
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    private var preferencesWindow: NSWindow?

    let appState = AppState()
    let preferences = Preferences()
    let sleepPrevention = SleepPrevention()
    let timerService = TimerService()
    let batteryMonitor = BatteryMonitor()
    let scheduleService = ScheduleService()
    let hotKeyService = HotKeyService()
    let launchAtLogin = LaunchAtLogin()
    let updateChecker = UpdateChecker()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupHotKey()
        setupBatteryMonitoring()
        setupSchedule()

        checkForUpdates()

        if preferences.activateAtLaunch {
            activate(preset: preferences.defaultPreset)
        }
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: StatusIcon.name(isActive: false),
                accessibilityDescription: "Kafein"
            )
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        rebuildMenu()
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            toggleDefault()
        }
    }

    private func showMenu() {
        rebuildMenu()
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        // Remove menu after showing so left click works next time
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.menu = nil
        }
    }

    // MARK: - Menu

    func rebuildMenu() {
        menu = NSMenu()

        // Toggle
        let toggleTitle = appState.isActive ? "Deactivate" : "Activate"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(menuToggle), keyEquivalent: "k")
        toggleItem.keyEquivalentModifierMask = [.command]
        toggleItem.target = self
        menu.addItem(toggleItem)

        // Status
        if appState.isActive {
            let statusItem = NSMenuItem(title: appState.statusText, action: nil, keyEquivalent: "")
            statusItem.isEnabled = false
            menu.addItem(statusItem)
        }

        menu.addItem(.separator())

        // Timer presets
        let timerMenu = NSMenu()
        for preset in TimerPreset.defaultPresets {
            let item = NSMenuItem(title: preset.displayName, action: #selector(timerPresetSelected(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = preset.id
            timerMenu.addItem(item)
        }
        let timerItem = NSMenuItem(title: "Activate For...", action: nil, keyEquivalent: "")
        timerItem.submenu = timerMenu
        menu.addItem(timerItem)

        // Battery
        if let level = appState.batteryLevel, appState.hasBattery {
            let suffix = appState.isOnBattery ? " (Battery)" : " (AC)"
            let battItem = NSMenuItem(title: "Battery: \(level)%\(suffix)", action: nil, keyEquivalent: "")
            battItem.isEnabled = false
            menu.addItem(battItem)
        }

        menu.addItem(.separator())

        // Update
        if let version = appState.availableUpdate {
            let updateItem = NSMenuItem(title: "Update Available (v\(version))", action: #selector(openReleasesPage), keyEquivalent: "")
            updateItem.target = self
            menu.addItem(updateItem)
            menu.addItem(.separator())
        }

        // Settings & Quit
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openPreferences), keyEquivalent: ",")
        settingsItem.keyEquivalentModifierMask = [.command]
        settingsItem.target = self
        menu.addItem(settingsItem)

        let quitItem = NSMenuItem(title: "Quit Kafein", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self
        menu.addItem(quitItem)
    }

    // MARK: - Actions

    @objc private func menuToggle() {
        toggleDefault()
    }

    @objc private func timerPresetSelected(_ sender: NSMenuItem) {
        guard let presetID = sender.representedObject as? String,
              let preset = TimerPreset.defaultPresets.first(where: { $0.id == presetID })
        else { return }

        if appState.isActive {
            deactivate()
        }
        activate(preset: preset)
    }

    @objc private func openPreferences() {
        if let window = preferencesWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = PreferencesView(preferences: preferences, launchAtLogin: launchAtLogin)
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: 400, height: 250)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 250),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Kafein Settings"
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindow = window
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc private func quitApp() {
        deactivate()
        NSApplication.shared.terminate(nil)
    }

    @objc private func openReleasesPage() {
        NSWorkspace.shared.open(UpdateChecker.releasesURL)
    }

    // MARK: - Toggle / Activate / Deactivate

    private func toggleDefault() {
        if appState.isActive {
            deactivate()
        } else {
            activate(preset: preferences.defaultPreset)
        }
    }

    func activate(preset: TimerPreset) {
        do {
            try sleepPrevention.activate()
            appState.isActive = true
            appState.selectedPreset = preset
            updateIcon()

            if let seconds = preset.totalSeconds {
                appState.remainingSeconds = seconds
                timerService.start(
                    seconds: seconds,
                    onTick: { [weak self] remaining in
                        Task { @MainActor in
                            self?.appState.remainingSeconds = remaining
                        }
                    },
                    onComplete: { [weak self] in
                        Task { @MainActor in
                            self?.deactivate()
                        }
                    }
                )
            }
        } catch {
            // Activation failed — state remains inactive
        }
    }

    func deactivate() {
        sleepPrevention.deactivate()
        timerService.stop()
        appState.isActive = false
        appState.selectedPreset = nil
        appState.remainingSeconds = 0
        updateIcon()
    }

    private func updateIcon() {
        statusItem?.button?.image = NSImage(
            systemSymbolName: StatusIcon.name(isActive: appState.isActive),
            accessibilityDescription: "Kafein"
        )
    }

    // MARK: - Setup

    private func setupHotKey() {
        guard preferences.hotKeyEnabled else { return }
        _ = hotKeyService.register { [weak self] in
            Task { @MainActor in
                self?.toggleDefault()
            }
        }
    }

    private func checkForUpdates() {
        guard preferences.checkForUpdates else { return }
        Task {
            if let version = await updateChecker.checkForUpdate() {
                await MainActor.run {
                    appState.availableUpdate = version
                }
            }
        }
    }

    private func setupBatteryMonitoring() {
        Task {
            await batteryMonitor.startMonitoring()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    appState.batteryLevel = batteryMonitor.batteryLevel
                    appState.isOnBattery = batteryMonitor.isOnBattery
                    appState.hasBattery = batteryMonitor.hasBattery

                    if preferences.disableOnBattery,
                       appState.isActive,
                       appState.isOnBattery,
                       let level = appState.batteryLevel,
                       level <= preferences.batteryThreshold
                    {
                        deactivate()
                    }
                }
            }
        }
    }

    private func setupSchedule() {
        guard let schedule = preferences.schedule, schedule.isEnabled else { return }
        scheduleService.start(schedule: schedule) { [weak self] shouldBeActive in
            Task { @MainActor in
                guard let self else { return }
                if shouldBeActive && !self.appState.isActive {
                    try? self.sleepPrevention.activate()
                    self.appState.isActive = true
                    self.appState.isScheduleActive = true
                    self.appState.selectedPreset = .indefinite
                    self.updateIcon()
                } else if !shouldBeActive && self.appState.isScheduleActive {
                    self.deactivate()
                    self.appState.isScheduleActive = false
                }
            }
        }
    }
}
