@testable import FundamentalParagraph
import Foundation
import Testing

extension PatternResourceTests
{
    @Test(arguments: PatternFixture.languages)
    func rejectsChangedBytesBeforeDecoding(_ locale: String) throws
    {
        let resource = try PatternFixture.resource(locale)
        let invalid = Data([0xFF])
        let checksum = Self.failure
        {
            () throws(PatternFailure) in
            _ = try resource.decode(invalid)
        }
        #expect(checksum == .checksumMismatch)
        let declared = PatternResource(
            locale: resource.locale, filename: resource.filename,
            sourceFilename: resource.sourceFilename,
            revision: resource.revision,
            sourceSHA256: resource.sourceSHA256,
            sha256: PatternResource.digest(invalid),
            left: resource.left, right: resource.right,
            license: resource.license
        )
        let encoding = Self.failure
        {
            () throws(PatternFailure) in
            _ = try declared.decode(invalid)
        }
        #expect(encoding == .invalidEncoding)
        try PatternEvidence.write(locale, group: "integrity", record: [
            "locale": locale,
            "changedBytes": String(reflecting: checksum),
            "declaredInvalidUTF8": String(reflecting: encoding)
        ])
    }

    private static func failure(
        _ body: () throws(PatternFailure) -> Void
    ) -> PatternFailure
    {
        do
        {
            try body()
            Issue.record("The malformed resource was accepted")
            return .invalidResource
        }
        catch
        {
            return error
        }
    }
}
