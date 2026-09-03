package struct LayoutFontIdentity: Equatable, Hashable, Sendable
{
    package let postScriptName: String
    package let uniqueName: String
    package let versionName: String
    package let pointSize: Double
    package let matrix: LayoutAffineTransform
    package let variations: [LayoutFontVariation]
    package let metrics: LayoutFontMetrics
}
