import Foundation

public protocol BatteryMonitoring {
    var batteryLevel: Int? { get }
    var isOnBattery: Bool { get }
    var hasBattery: Bool { get }
    func startMonitoring() async
    func stopMonitoring()
}
