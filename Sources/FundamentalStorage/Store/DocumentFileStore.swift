import Foundation
import FundamentalDocument

package actor DocumentFileStore
{
    let codec: DocumentRecordCodec

    package init(limits: DocumentRecordLimits = DocumentRecordLimits())
    {
        codec = DocumentRecordCodec(limits: limits)
    }

    package func read(
        _ location: DocumentFileLocation
    ) throws -> DocumentFileRead
    {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordinationError: NSError?
        var result: Result<DocumentFileRead, Error>?
        coordinator.coordinate(
            readingItemAt: location.url,
            options: .withoutChanges,
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
                return try DocumentFileReader(
                    location: coordinated,
                    codec: codec
                ).read()
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
