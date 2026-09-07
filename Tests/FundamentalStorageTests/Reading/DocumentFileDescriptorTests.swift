import Darwin
import Foundation
import Testing

@testable import FundamentalStorage

@Suite("Owned descriptor lifetimes")
struct DocumentFileDescriptorTests
{
    @Test("read descriptors neither cross exec nor block on special files")
    func descriptorFlags() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let descriptor = try DocumentFileDescriptor(location: location)
        #expect(fcntl(descriptor.rawValue, F_GETFD) & FD_CLOEXEC != 0)
        #expect(fcntl(descriptor.rawValue, F_GETFL) & O_NONBLOCK != 0)
        #expect(fcntl(descriptor.rawValue, F_GETFL) & O_ACCMODE == O_RDONLY)
    }

    @Test("releasing the owner closes its particular file descriptor")
    func releaseClosesFile() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        var owner: DocumentFileDescriptor? = try DocumentFileDescriptor(
            location: location
        )
        let descriptor = try #require(owner?.rawValue)
        owner = nil
        var path = [CChar](repeating: 0, count: Int(PATH_MAX))
        let result = fcntl(descriptor, F_GETPATH, &path)
        if result == 0
        {
            let bytes = path.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
            let current = String(decoding: bytes, as: UTF8.self)
            #expect(current != location.url.resolvingSymlinksInPath().path)
        }
        else
        {
            #expect(errno == EBADF)
        }
    }
}
