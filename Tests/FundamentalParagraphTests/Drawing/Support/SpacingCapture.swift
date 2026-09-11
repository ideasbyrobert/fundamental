import Foundation

enum SpacingCapture
{
    static func write(
        _ raster: SpacingRaster, name: String, group: String
    ) throws
    {
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_PARAGRAPH_CAPTURE_DIR"
        ]
        else
        {
            return
        }
        let folder = URL(fileURLWithPath: path).appendingPathComponent(group)
        try FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true
        )
        let output = folder.appendingPathComponent(name + ".png")
        guard !FileManager.default.fileExists(atPath: output.path)
        else
        {
            throw CocoaError(.fileWriteFileExists)
        }
        try raster.write(to: output)
    }
}
