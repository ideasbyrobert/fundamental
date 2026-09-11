import CryptoKit
import Foundation

extension SpacingEvidence
{
    static func describe(_ raster: SpacingRaster) -> [String: Any]
    {
        [
            "width": raster.width, "height": raster.height,
            "scale": raster.scale, "coveredPixels": raster.coveredPixels,
            "pixelBounds": rectangle(raster.pixelBounds),
            "sha256": SHA256.hash(data: raster.bytes).map
            {
                String(format: "%02x", $0)
            }.joined()
        ]
    }
}
