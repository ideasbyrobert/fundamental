import Darwin
import Testing

@testable import FundamentalStorage

@Suite("Descriptor and pathname agreement")
struct DocumentFileStampTests
{
    @Test("an unchanged regular file has one descriptor and path observation")
    func matchingObservations() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let descriptor = try DocumentFileDescriptor(location: location)
        let stamp = try DocumentFileStamp(descriptor: descriptor.rawValue)
        #expect(try DocumentFileStamp(location: location) == stamp)
        #expect(stamp.byteCount == DocumentFileFixture.record.count)
        #expect(stamp.inode != 0)
    }

    @Test("invalid descriptors and absent paths retain filesystem failures")
    func systemFailures() throws
    {
        let fixture = try DocumentFileFixture()
        let missing = try fixture.location()
        #expect(throws: DocumentFileFailure.fileSystem(EBADF))
        {
            try DocumentFileStamp(descriptor: -1)
        }
        #expect(throws: DocumentFileFailure.fileSystem(ENOENT))
        {
            try DocumentFileStamp(location: missing)
        }
    }
}
