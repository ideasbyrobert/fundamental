import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers

extension MacRasterOriginFixture
{
    static func capture(_ surface: MacBitmapSurface, name: String) throws
    {
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_RASTER_ORIGIN_CAPTURE_DIR"
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
        let image = try #require(surface.context.makeImage())
        CGImageDestinationAddImage(output, image, nil)
        #expect(CGImageDestinationFinalize(output))
    }
}
