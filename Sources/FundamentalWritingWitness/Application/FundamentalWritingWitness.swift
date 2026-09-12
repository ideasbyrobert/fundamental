import AppKit
import FundamentalDocument

@main
enum FundamentalWritingWitness
{
    @MainActor
    static func main()
    {
        let application = NSApplication.shared
        guard let seed = WritingDocumentSeed(),
              let controller = WritingWindowController(
                  session: DocumentSession(state: seed.state)
              )
        else
        {
            print("Fundamental could not create its writing witness.")
            return
        }
        let store = WritingRecoveryStore(
            directory: WritingRecoveryLocation.directory()
        )
        let delegate = WritingApplicationDelegate(controller: controller,
                                                    recoveryStore: store)
        WritingApplicationMenu.install(in: application)
        application.setActivationPolicy(.regular)
        application.delegate = delegate
        withExtendedLifetime(delegate)
        {
            application.run()
        }
    }
}
