import Foundation

package struct DocumentFileRecovery: Equatable, Sendable
{
    package let destination: DocumentFileLocation
    package let locations: [URL]
    package let errorDomain: String
    package let errorCode: Int
    package let explanation: String

    init(
        destination: DocumentFileLocation,
        locations: [URL],
        error: Error
    )
    {
        let failure = error as NSError
        var retained = locations
        if let original = failure.userInfo["NSFileOriginalItemLocationKey"]
            as? URL,
           !retained.contains(original)
        {
            retained.append(original)
        }
        self.destination = destination
        self.locations = retained
        errorDomain = failure.domain
        errorCode = failure.code
        explanation = failure.localizedDescription
    }
}
