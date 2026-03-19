import Foundation
import IOKit.ps

public final class BatteryMonitor: BatteryMonitoring {
    public private(set) var batteryLevel: Int?
    public private(set) var isOnBattery: Bool = false
    public private(set) var hasBattery: Bool = false

    private var monitorTask: Task<Void, Never>?

    public init() {
        updateBatteryInfo()
    }

    public func startMonitoring() async {
        stopMonitoring()
        monitorTask = Task {
            while !Task.isCancelled {
                updateBatteryInfo()
                try? await Task.sleep(for: .seconds(60))
            }
        }
    }

    public func stopMonitoring() {
        monitorTask?.cancel()
        monitorTask = nil
    }

    private func updateBatteryInfo() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [Any],
              !sources.isEmpty
        else {
            hasBattery = false
            batteryLevel = nil
            isOnBattery = false
            return
        }

        hasBattery = true

        for source in sources {
            guard let info = IOPSGetPowerSourceDescription(snapshot, source as CFTypeRef)?
                .takeUnretainedValue() as? [String: Any]
            else { continue }

            if let capacity = info[kIOPSCurrentCapacityKey] as? Int {
                batteryLevel = capacity
            }

            if let powerSource = info[kIOPSPowerSourceStateKey] as? String {
                isOnBattery = powerSource == kIOPSBatteryPowerValue
            }
        }
    }
}
