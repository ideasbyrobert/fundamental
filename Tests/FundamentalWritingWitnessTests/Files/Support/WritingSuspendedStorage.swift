import FundamentalDocument
import FundamentalStorage

@testable import FundamentalWritingWitness

actor WritingSuspendedStorage: WritingDocumentStorage
{
    let store = DocumentFileStore()
    var started = false
    var arrival: CheckedContinuation<Void, Never>?
    var resume: CheckedContinuation<Void, Never>?

    func read(_ location: DocumentFileLocation) async throws -> DocumentFileRead
    {
        try await store.read(location)
    }

    func save(
        _ document: CanonicalDocument,
        at location: DocumentFileLocation,
        condition: DocumentFileWriteCondition
    ) async throws -> DocumentFileSaveReceipt
    {
        await withCheckedContinuation
        {
            continuation in
            resume = continuation
            started = true
            arrival?.resume()
            arrival = nil
        }
        return try await store.save(
            document, at: location, condition: condition
        )
    }

    func waitForSave() async
    {
        if !started
        {
            await withCheckedContinuation
            {
                arrival = $0
            }
        }
    }

    func continueSave()
    {
        resume?.resume()
        resume = nil
    }
}
