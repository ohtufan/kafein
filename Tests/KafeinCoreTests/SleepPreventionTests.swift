import Testing

@testable import KafeinCore

final class MockSleepPrevention: SleepPreventable {
    var isActive: Bool = false
    var activateCallCount = 0
    var deactivateCallCount = 0
    var shouldThrow = false

    func activate() throws {
        activateCallCount += 1
        if shouldThrow {
            throw SleepPreventionError.assertionFailed(1)
        }
        isActive = true
    }

    func deactivate() {
        deactivateCallCount += 1
        isActive = false
    }
}

@Suite("SleepPrevention Tests")
struct SleepPreventionTests {
    @Test("Mock activate and deactivate")
    func activateDeactivate() throws {
        let mock = MockSleepPrevention()
        #expect(!mock.isActive)

        try mock.activate()
        #expect(mock.isActive)
        #expect(mock.activateCallCount == 1)

        mock.deactivate()
        #expect(!mock.isActive)
        #expect(mock.deactivateCallCount == 1)
    }

    @Test("Mock activate throws")
    func activateThrows() {
        let mock = MockSleepPrevention()
        mock.shouldThrow = true
        #expect(throws: SleepPreventionError.self) {
            try mock.activate()
        }
        #expect(!mock.isActive)
    }

    @Test("Real SleepPrevention activate/deactivate")
    func realSleepPrevention() throws {
        let service = SleepPrevention()
        try service.activate()
        #expect(service.isActive)
        service.deactivate()
        #expect(!service.isActive)
    }

    @Test("Double activate is idempotent")
    func doubleActivate() throws {
        let service = SleepPrevention()
        try service.activate()
        try service.activate()
        #expect(service.isActive)
        service.deactivate()
        #expect(!service.isActive)
    }

    @Test("Double deactivate is safe")
    func doubleDeactivate() {
        let service = SleepPrevention()
        service.deactivate()
        service.deactivate()
        #expect(!service.isActive)
    }
}
