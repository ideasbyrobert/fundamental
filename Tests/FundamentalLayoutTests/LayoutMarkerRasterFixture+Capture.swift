import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers

extension LayoutMarkerRasterFixture
{
    static func capture(_ image: CGImage, name: String) throws
    {
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_LAYOUT_MARKER_CAPTURE_DIR"
        ]
        else
        {
            return
        }
        let root = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(
            at: root, withIntermediateDirectories: true
        )
        let url = root.appending(path: name + ".png")
        let output = try #require(CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil
        ))
        CGImageDestinationAddImage(output, image, nil)
        #expect(CGImageDestinationFinalize(output))
    }
}
