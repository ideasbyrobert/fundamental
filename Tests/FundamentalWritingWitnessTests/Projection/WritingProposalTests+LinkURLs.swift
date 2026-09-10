import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("navigation preserves meaningful URL spelling",
          arguments: [
            (" https://example.invalid/e\u{301} ",
             "https://example.invalid/e%CC%81"),
            ("http://127.0.0.1:8123/witness?nonce=123#part",
             "http://127.0.0.1:8123/witness?nonce=123#part"),
            ("mailto:reader@example.invalid?subject=Hello",
             "mailto:reader@example.invalid?subject=Hello"),
            ("HTTPS://example.invalid/A%2fb", "HTTPS://example.invalid/A%2fb")
          ])
    func linkOpeningURL(_ pair: (String, String))
    {
        #expect(WritingLinkRequest.navigationURL(pair.0)?.absoluteString ==
            pair.1)
    }

    @Test("unsupported link metadata is not a navigation instruction",
          arguments: ["", " \n", "Relative", "/file", "//example.invalid",
            "https:", "https:///path", "mailto:", "mailto://example.invalid/A",
            "javascript:alert(1)", "data:text/plain,Hello", "file:///tmp/test",
            "https://example.invalid/a\nb", "https://example.invalid/\u{0}x"])
    func linkOpeningURLRefusal(_ value: String)
    {
        #expect(WritingLinkRequest.navigationURL(value) == nil)
    }

    @Test("navigation preparation preserves exact stored scope spelling")
    func linkOpeningSpelling() throws
    {
        let run = try WritingScopeFixture.run("Ae\u{301}😀", form: 2)
        let source = try WritingTestDocument(blocks: [
            .paragraph(.init(runs: [run]))
        ])
        let request = try #require(WritingLinkRequest(in: source.projection()))
        #expect(request.url.absoluteString == "https://example.invalid/e%CC%81")
        #expect(request.destination.value.utf16.elementsEqual(
            WritingScopeFixture.link.utf16
        ))
    }
}
