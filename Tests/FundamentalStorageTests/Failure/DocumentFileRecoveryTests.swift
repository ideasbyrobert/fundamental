import Foundation
import Testing

@testable import FundamentalStorage

@Suite("Truthful recovery descriptions")
struct DocumentFileRecoveryTests
{
    @Test("foundation original locations and error facts survive wrapping")
    func reportedOriginalLocation() throws
    {
        let fixture = try DocumentFileFixture()
        let destination = try fixture.location()
        let moved = fixture.root.appending(path: "Retained.fundamental")
        let failure = NSError(
            domain: NSCocoaErrorDomain,
            code: NSFileWriteUnknownError,
            userInfo: [
                "NSFileOriginalItemLocationKey": moved,
                NSLocalizedDescriptionKey: "The publication was interrupted."
            ]
        )
        let recovery = DocumentFileRecovery(
            destination: destination, locations: [fixture.root], error: failure
        )
        #expect(recovery.locations == [fixture.root, moved])
        #expect(recovery.errorDomain == NSCocoaErrorDomain)
        #expect(recovery.errorCode == NSFileWriteUnknownError)
        #expect(recovery.explanation == "The publication was interrupted.")
    }
}
