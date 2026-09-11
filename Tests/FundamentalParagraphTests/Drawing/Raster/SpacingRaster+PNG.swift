@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Foundation
import ImageIO
import UniformTypeIdentifiers

extension SpacingRaster
{
    func write(to url: URL) throws
    {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil
        )
        else
        {
            throw SpacingRasterFailure.missingImage
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination)
        else
        {
            throw SpacingRasterFailure.missingImage
        }
    }
}
