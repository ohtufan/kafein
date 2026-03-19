import Foundation

public protocol SleepPreventable {
    func activate() throws
    func deactivate()
    var isActive: Bool { get }
}
