import AppKit

@MainActor
package final class MacCopyDestination: NSObject
{
    package let pasteboard: NSPasteboard

    package init(pasteboard: NSPasteboard)
    {
        self.pasteboard = pasteboard
    }
}
