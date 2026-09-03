import CoreGraphics
import FundamentalPresentation

@testable import FundamentalMacOracle

@MainActor
final class MacBitmapSurface
{
    private let bytesPerPixel = 4
    private let storage: UnsafeMutableRawPointer
    let context: CGContext
    let width: Int
    let height: Int
    let pixelBounds: PresentationPixelBounds
    let backingScale: Double
    let logicalMinimumX: Double
    let logicalMinimumY: Double

    init?(_ snapshot: PresentationSnapshot)
    {
        let plane = snapshot.presentedDocument.plane
        pixelBounds = plane.pixelBounds
        backingScale = plane.backingScale
        logicalMinimumX = plane.logicalBounds.minX
        logicalMinimumY = plane.logicalBounds.minY
        width = pixelBounds.width
        height = pixelBounds.height
        let bytesPerRow = width * bytesPerPixel
        storage = .allocate(
            byteCount: bytesPerRow * height,
            alignment: 16
        )
        storage.initializeMemory(
            as: UInt8.self,
            repeating: 0,
            count: bytesPerRow * height
        )
        guard let context = CGContext(
            data: storage,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        else
        {
            storage.deallocate()
            return nil
        }
        self.context = context
    }

    isolated deinit
    {
        storage.deallocate()
    }

    func draw(
        _ snapshot: PresentationSnapshot
    ) -> Bool
    {
        let logicalHeight = Double(height) / backingScale
        context.saveGState()
        context.scaleBy(x: backingScale, y: backingScale)
        context.translateBy(
            x: -logicalMinimumX,
            y: logicalMinimumY + logicalHeight
        )
        context.scaleBy(x: 1, y: -1)
        let result = MacRasterExecutor().draw(
            snapshot,
            in: context,
            horizontalInset: 0
        )
        context.restoreGState()
        context.flush()
        return result
    }

    func pixel(x: Int, y: Int) -> UInt32
    {
        let offset = ((y * width) + x) * bytesPerPixel
        return storage.load(fromByteOffset: offset, as: UInt32.self)
    }
}
