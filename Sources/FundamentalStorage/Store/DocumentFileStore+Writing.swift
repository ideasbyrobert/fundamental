import Foundation
import FundamentalDocument

extension DocumentFileStore
{
    package func save(
        _ document: CanonicalDocument,
        at location: DocumentFileLocation,
        condition: DocumentFileWriteCondition
    ) throws -> DocumentFileSaveReceipt
    {
        let options: NSFileCoordinator.WritingOptions
        switch condition
        {
        case .absent:
            options = .forReplacing
        case .unchanged:
            options = []
        }
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordinationError: NSError?
        var result: Result<DocumentFileSaveReceipt, Error>?
        coordinator.coordinate(
            writingItemAt: location.url,
            options: options,
            error: &coordinationError
        )
        {
            url in
            result = Result
            {
                guard let coordinated = DocumentFileLocation(url)
                else
                {
                    throw DocumentFileFailure.invalidLocation
                }
                return try DocumentFileWriter(
                    document: document,
                    location: coordinated,
                    condition: condition,
                    codec: codec
                ).write()
            }
        }
        if let coordinationError
        {
            throw coordinationError
        }
        guard let result
        else
        {
            throw DocumentFileFailure.coordinationUnavailable
        }
        return try result.get()
    }
}
