import Foundation

public final class TimerService {
    private var timerTask: Task<Void, Never>?

    public init() {}

    public func start(seconds: Int, onTick: @escaping @Sendable (Int) -> Void, onComplete: @escaping @Sendable () -> Void) {
        stop()

        timerTask = Task { [weak self] in
            var remaining = seconds
            while remaining > 0 {
                if Task.isCancelled { return }
                onTick(remaining)
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                remaining -= 1
            }
            onTick(0)
            onComplete()
            self?.timerTask = nil
        }
    }

    public func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    public var isRunning: Bool {
        timerTask != nil && !timerTask!.isCancelled
    }
}
