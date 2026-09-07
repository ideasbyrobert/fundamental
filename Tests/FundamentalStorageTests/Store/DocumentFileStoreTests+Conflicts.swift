import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileStoreTests
{
    @Test("two updates from one observation cannot overwrite each other")
    func competingUpdates() async throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let previous = try await DocumentFileStore().read(location)
        let documents = try [
            DocumentFileFixture.document("First update."),
            DocumentFileFixture.document("Second update.")
        ]
        let outcomes = try await withThrowingTaskGroup(of: Bool.self)
        {
            group in
            for document in documents
            {
                group.addTask
                {
                    do
                    {
                        _ = try await DocumentFileStore().save(
                            document, at: location,
                            condition: .unchanged(previous.revision)
                        )
                        return true
                    }
                    catch DocumentFileFailure.conflictingRevision
                    {
                        return false
                    }
                }
            }
            var results: [Bool] = []
            for try await outcome in group
            {
                results.append(outcome)
            }
            return results
        }
        #expect(outcomes.filter { $0 }.count == 1)
        #expect(outcomes.filter { !$0 }.count == 1)
        let winner = try await DocumentFileStore().read(location)
        #expect(documents.contains(winner.document))
    }
}
