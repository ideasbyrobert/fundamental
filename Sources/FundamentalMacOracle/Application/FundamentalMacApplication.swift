import AppKit

@MainActor
package final class FundamentalMacApplication
{
    private let application: NSApplication
    private let delegate: MacApplicationDelegate

    package init()
    {
        application = NSApplication.shared
        delegate = MacApplicationDelegate()
    }

    package func run()
    {
        MacApplicationMenu.install(in: application)
        application.setActivationPolicy(.regular)
        application.delegate = delegate
        application.run()
    }
}
