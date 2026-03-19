import Foundation

public final class ScheduleService {
    private var checkTask: Task<Void, Never>?

    public init() {}

    public func start(schedule: Schedule, onStateChange: @escaping @Sendable (Bool) -> Void) {
        stop()

        checkTask = Task {
            while !Task.isCancelled {
                let shouldBeActive = schedule.isActiveNow()
                onStateChange(shouldBeActive)
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }

    public func stop() {
        checkTask?.cancel()
        checkTask = nil
    }
}
