import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileStoreTests
{
    @Test("create reopen and repeated saves retain exact canonical spelling")
    func repeatedSaves() async throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        let store = DocumentFileStore()
        let first = try DocumentFileFixture.document("é")
        var receipt = try await store.save(
            first, at: location, condition: .absent
        )
        for revision in UInt64(2)...5
        {
            let text = revision.isMultiple(of: 2) ? "e\u{301}" : "é"
            let document = try DocumentFileFixture.document(
                text, revision: revision
            )
            receipt = try await store.save(
                document, at: receipt.file.location,
                condition: .unchanged(receipt.file.revision)
            )
            let reopened = try await DocumentFileStore().read(location)
            let expected = try DocumentFileFixture.codec.encode(document)
            #expect(try Data(contentsOf: location.url) == expected)
            #expect(reopened.revision == receipt.file.revision)
            #expect(receipt.retainedItems.isEmpty)
        }
    }

    @Test("concurrent creators produce one complete winner without overwrite")
    func competingCreators() async throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        let documents = try [
            DocumentFileFixture.document("First"),
            DocumentFileFixture.document("Second")
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
                            document, at: location, condition: .absent
                        )
                        return true
                    }
                    catch DocumentFileFailure.destinationExists
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
