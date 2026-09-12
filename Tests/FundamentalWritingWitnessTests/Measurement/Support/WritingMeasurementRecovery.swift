import Foundation
import Testing

@testable import FundamentalWritingWitness

@MainActor
struct WritingMeasurementRecovery
{
    let coordinator: WritingRecoveryCoordinator

    init(window: WritingTestWindow) throws
    {
        let directory = FileManager.default.temporaryDirectory.appending(
            path: "WritingMeasurement-" + UUID().uuidString
        )
        let store = WritingRecoveryStore(directory: directory)
        window.controller.installRecovery(using: store)
        coordinator = try #require(window.controller.fileOwner.recovery)
    }

    func expectObserved(_ window: WritingTestWindow) throws
    {
        let projection = try #require(WritingProjection(window.session.state))
        #expect(coordinator.observed == projection.snapshot)
        #expect(coordinator.observedUnsaved)
        #expect(coordinator.pending != nil)
        #expect(coordinator.lastError == nil)
    }

    func stop()
    {
        coordinator.stop()
    }
}
