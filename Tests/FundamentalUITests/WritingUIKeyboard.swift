import Carbon
import XCTest

@MainActor
struct WritingUIKeyboard
{
    static func requireUS(in test: XCTestCase) throws
    {
        let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        let pointer = try XCTUnwrap(TISGetInputSourceProperty(
            source, kTISPropertyInputSourceID
        ))
        let identity = Unmanaged<CFString>.fromOpaque(pointer)
            .takeUnretainedValue() as String
        let attachment = XCTAttachment(string: identity)
        attachment.name = "Active keyboard input source"
        attachment.lifetime = .keepAlways
        test.add(attachment)
        XCTAssertEqual(identity, "com.apple.keylayout.US",
                       "This dead-key journey requires the U.S. input source")
    }
}
