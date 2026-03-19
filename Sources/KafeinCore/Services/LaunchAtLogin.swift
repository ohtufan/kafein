import Foundation
import ServiceManagement

public final class LaunchAtLogin {
    public init() {}

    public func setEnabled(_ enabled: Bool) -> Bool {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            return true
        } catch {
            return false
        }
    }

    public var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
}
