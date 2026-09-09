import AppKit
import XCTest

@MainActor
struct WritingUIFixture
{
    let app: XCUIApplication
    let directory: URL
    let clipboard: WritingUIPasteboard

    init(test: XCTestCase) throws
    {
        let settings = Bundle(for: WritingUITests.self)
        let path = try XCTUnwrap(settings.object(
            forInfoDictionaryKey: "FundamentalUITestApplication"
        ) as? String)
        let url = URL(fileURLWithPath: path)
        let bundle = try XCTUnwrap(Bundle(url: url))
        let identity = try XCTUnwrap(bundle.bundleIdentifier)
        _ = try XCTUnwrap(identity.hasPrefix(
            "com.ideasbyrobert.Fundamental.UITesting."
        ) ? true : nil, "The application must be an isolated UI fixture")
        _ = try XCTUnwrap(NSRunningApplication.runningApplications(
            withBundleIdentifier: identity
        ).isEmpty ? true : nil, "Refuse an already running application")
        directory = FileManager.default.temporaryDirectory.appending(
            path: "FundamentalUI-" + UUID().uuidString,
            directoryHint: .isDirectory
        )
        try FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
        app = XCUIApplication(url: url)
        clipboard = WritingUIPasteboard()
        let application = app
        let pasteboard = clipboard
        test.addTeardownBlock
        {
            await MainActor.run
            {
                if application.state != .notRunning
                {
                    application.terminate()
                }
                pasteboard.restore()
            }
        }
        let metadata = ["application": url.path, "identifier": identity,
                        "evidence": directory.path]
        let data = try JSONSerialization.data(
            withJSONObject: metadata, options: [.prettyPrinted, .sortedKeys]
        )
        try data.write(to: directory.appending(path: "application.json"))
        let attachment = XCTAttachment(data: data,
                                       uniformTypeIdentifier: "public.json")
        attachment.name = "Owned application and document directory"
        attachment.lifetime = .keepAlways
        test.add(attachment)
        app.launch()
    }
}
