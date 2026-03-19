import KafeinCore
import SwiftUI

@main
struct KafeinApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView(
                preferences: appDelegate.preferences,
                launchAtLogin: appDelegate.launchAtLogin
            )
        }
    }
}
