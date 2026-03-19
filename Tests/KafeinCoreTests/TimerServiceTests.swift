import Testing

@testable import KafeinCore

@Suite("TimerService Tests")
struct TimerServiceTests {
    @Test("Timer starts and can be stopped")
    func startAndStop() async throws {
        let service = TimerService()
        var ticks: [Int] = []

        service.start(
            seconds: 100,
            onTick: { remaining in ticks.append(remaining) },
            onComplete: {}
        )

        #expect(service.isRunning)

        try await Task.sleep(for: .milliseconds(200))
        service.stop()

        #expect(!service.isRunning)
        #expect(!ticks.isEmpty)
    }

    @Test("Timer completes after duration")
    func completion() async throws {
        let service = TimerService()
        var completed = false

        service.start(
            seconds: 1,
            onTick: { _ in },
            onComplete: { completed = true }
        )

        try await Task.sleep(for: .seconds(2))
        #expect(completed)
    }

    @Test("Starting new timer stops previous")
    func restartStopsPrevious() async throws {
        let service = TimerService()
        var firstTicks: [Int] = []
        var secondTicks: [Int] = []

        service.start(
            seconds: 100,
            onTick: { remaining in firstTicks.append(remaining) },
            onComplete: {}
        )

        try await Task.sleep(for: .milliseconds(100))

        service.start(
            seconds: 50,
            onTick: { remaining in secondTicks.append(remaining) },
            onComplete: {}
        )

        try await Task.sleep(for: .milliseconds(200))
        service.stop()

        #expect(!secondTicks.isEmpty)
    }
}
