import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("the Escape key cancels preedit before input-method acceptance")
    func escapeCompositionKey() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        let before = window.storage
        window.mark("˜")
        try window.key("\u{1b}", code: 53)
        #expect(window.storage == before)
        #expect(!window.view.hasMarkedText())
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
        try window.key("n", code: 45)
        try window.expect("AnB", selection: NSRange(location: 2, length: 0))
    }
}
