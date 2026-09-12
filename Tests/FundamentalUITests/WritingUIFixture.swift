import AppKit
import XCTest

@MainActor
struct WritingUIFixture
{
    let app: XCUIApplication
    let directory: URL
    let clipboard: WritingUIPasteboard
    let identifier: String
    let applicationURL: URL

    init(
        test: XCTestCase, restoresZoom: Bool = false,
        appearance: XCUIDevice.Appearance? = nil
    ) throws
    {
        let settings = Bundle(for: WritingUITests.self)
        let path = try XCTUnwrap(settings.object(
            forInfoDictionaryKey: "FundamentalUITestApplication"
        ) as? String)
        let url = URL(fileURLWithPath: path)
        let bundle = try XCTUnwrap(Bundle(url: url))
        let identity = try XCTUnwrap(bundle.bundleIdentifier)
        identifier = identity
        applicationURL = url
        _ = try XCTUnwrap(identity.hasPrefix(
            "com.ideasbyrobert.Fundamental.UITesting."
        ) ? true : nil, "The application must be an isolated UI fixture")
        _ = try XCTUnwrap(NSRunningApplication.runningApplications(
            withBundleIdentifier: identity
        ).isEmpty ? true : nil, "Refuse an already running application")
        if let appearance { WritingUIAppearance.use(appearance, test: test) }
        directory = FileManager.default.temporaryDirectory.appending(
            path: "FundamentalUI-" + UUID().uuidString,
            directoryHint: .isDirectory
        )
        try FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
        app = XCUIApplication(url: url)
        if !restoresZoom
        {
            app.launchArguments = ["-FundamentalWritingZoomPercentage", "100"]
        }
        let recovery = directory.appending(path: "Recovery")
        let recoveryKey = "FUNDAMENTAL_UI_RECOVERY_DIRECTORY"
        app.launchEnvironment[recoveryKey] = recovery.path
        clipboard = WritingUIPasteboard()
        let application = app
        let pasteboard = clipboard
        test.addTeardownBlock
        {
            @MainActor in
            if application.state != .notRunning
            {
                application.terminate()
            }
            pasteboard.restore()
        }
        let metadata = ["application": url.path, "identifier": identity,
                        "evidence": directory.path, "recovery": recovery.path]
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
