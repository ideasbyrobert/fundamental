import Darwin
import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileReaderTests
{
    @Test("directories and fifos are refused before reading their contents")
    func nonregularFiles() throws
    {
        let fixture = try DocumentFileFixture()
        let directory = try #require(DocumentFileLocation(fixture.root))
        let fifo = try fixture.location("Pipe")
        #expect(mkfifo(fifo.url.path, 0o600) == 0)
        for location in [directory, fifo]
        {
            #expect(throws: DocumentFileFailure.notRegularFile)
            {
                try DocumentFileReader(
                    location: location, codec: DocumentFileFixture.codec
                ).read()
            }
        }
    }

    @Test("a final symbolic link is not followed to another document")
    func finalSymbolicLink() throws
    {
        let fixture = try DocumentFileFixture()
        let original = try fixture.write()
        let link = try fixture.location("Link.fundamental")
        try FileManager.default.createSymbolicLink(
            at: link.url, withDestinationURL: original.url
        )
        #expect(throws: DocumentFileFailure.fileSystem(ELOOP))
        {
            try DocumentFileReader(
                location: link, codec: DocumentFileFixture.codec
            ).read()
        }
    }
}
