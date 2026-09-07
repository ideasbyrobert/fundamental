import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("malformed and split-surrogate composition ranges refuse atomically",
          arguments: [NSRange(location: -1, length: 0),
                      NSRange(location: 0, length: -1),
                      NSRange(location: Int.max - 1, length: 8),
                      NSRange(location: 2, length: 0),
                      NSRange(location: 1, length: 1)])
    func invalidRange(_ range: NSRange) throws
    {
        let window = try WritingTestWindow("A👋B")
        defer
        {
            window.close()
        }
        let before = window.storage
        window.mark("X", replacing: range)
        #expect(!window.view.hasMarkedText())
        #expect(window.storage == before)
        try window.expect("A👋B", selection: NSRange(location: 0, length: 0))
    }

    @Test("preedit selection cannot split a surrogate pair")
    func invalidSelection() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        let before = window.storage
        window.mark("👋", selecting: NSRange(location: 1, length: 0))
        #expect(!window.view.hasMarkedText())
        #expect(window.storage == before)
        try window.expect("AB", selection: NSRange(location: 0, length: 0))
    }

    @Test("composition respects raw capacity before native mutation",
          arguments: ["X", "\r\n"])
    func capacity(_ inserted: String) throws
    {
        let spare = inserted.utf16.count - 1
        let text = String(repeating: "A",
            count: WritingSurfacePolicy.maximumUTF16Units - spare)
        let window = try WritingTestWindow(text)
        defer
        {
            window.close()
        }
        let before = window.storage
        window.mark(inserted)
        #expect(!window.view.hasMarkedText())
        #expect(window.storage == before)
        try window.expect(text, selection: NSRange(location: 0, length: 0))
    }
}
