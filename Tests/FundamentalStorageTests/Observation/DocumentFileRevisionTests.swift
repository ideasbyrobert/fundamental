import Foundation
import Testing

@testable import FundamentalStorage

@Suite("Exact observed file revisions")
struct DocumentFileRevisionTests
{
    @Test("equal metadata cannot hide different observed bytes")
    func digestSeparatesContent() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let stamp = try DocumentFileStamp(location: location)
        let first = DocumentFileRevision(stamp: stamp, bytes: Data("abc".utf8))
        let second = DocumentFileRevision(stamp: stamp, bytes: Data("abd".utf8))
        #expect(first.stamp == second.stamp)
        #expect(first != second)
        let digest = first.digest.map { String(format: "%02x", $0) }.joined()
        #expect(digest ==
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }

    @Test("the same bytes in a replacement file have a different revision")
    func replacementSeparatesIdentity() throws
    {
        let fixture = try DocumentFileFixture()
        let first = try fixture.write()
        let second = try fixture.write(name: "Replacement.fundamental")
        let bytes = DocumentFileFixture.record
        let a = DocumentFileRevision(
            stamp: try DocumentFileStamp(location: first),
            bytes: bytes
        )
        let b = DocumentFileRevision(
            stamp: try DocumentFileStamp(location: second),
            bytes: bytes
        )
        #expect(a.digest == b.digest)
        #expect(a != b)
    }
}
