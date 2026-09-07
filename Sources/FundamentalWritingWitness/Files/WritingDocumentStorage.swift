import FundamentalDocument
import FundamentalStorage

protocol WritingDocumentStorage: Sendable
{
    func read(_ location: DocumentFileLocation) async throws -> DocumentFileRead

    func save(
        _ document: CanonicalDocument,
        at location: DocumentFileLocation,
        condition: DocumentFileWriteCondition
    ) async throws -> DocumentFileSaveReceipt
}
