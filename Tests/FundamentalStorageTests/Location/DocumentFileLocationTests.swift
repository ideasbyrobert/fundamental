import Foundation
import Testing

@testable import FundamentalStorage

@Suite("Explicit local document locations")
struct DocumentFileLocationTests
{
    @Test("local locations retain their supplied path and spelling")
    func localLocations() throws
    {
        let url = URL(fileURLWithPath: "/tmp/alias/e\u{301} Հայ.fundamental")
        let location = try #require(DocumentFileLocation(url))
        #expect(location.url == url)
        #expect(Array(location.url.path.utf8) == Array(url.path.utf8))
        #expect(DocumentFileLocation(url) == location)
    }

    @Test("nonlocal addresses and ambiguous file requests are refused")
    func refusedLocations() throws
    {
        let spellings = [
            "https://example.invalid/Witness.fundamental",
            "file://server/tmp/Witness.fundamental",
            "file://user@localhost/tmp/Witness.fundamental",
            "file://localhost:123/tmp/Witness.fundamental",
            "file:///tmp/Witness.fundamental?variant=1",
            "file:///tmp/Witness.fundamental#fragment",
            "file:///tmp/Witness%00.fundamental",
            "file:///"
        ]
        for spelling in spellings
        {
            let url = try #require(URL(string: spelling))
            #expect(DocumentFileLocation(url) == nil, "\(spelling)")
        }
    }
}
