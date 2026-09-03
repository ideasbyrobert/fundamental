package struct RasterFontIdentity: Equatable, Sendable
{
    package let postScriptName: String
    package let uniqueName: String
    package let versionName: String
    package let pointSize: Double
    package let matrix: RasterAffineTransform
    package let variations: [RasterFontVariation]
    package let metrics: RasterFontMetrics
}
