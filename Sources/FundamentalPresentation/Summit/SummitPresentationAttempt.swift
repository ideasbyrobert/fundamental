import FundamentalRaster

package struct SummitPresentationAttempt: Sendable
{
    package let snapshot: PresentationSnapshot
    package let lease: PresentationAttemptLease
    let raster: RasterSnapshot
    package let surface: SummitPresentationSurface
}
