package struct PresentationFontIdentity: Equatable, Sendable
{
    package let postScriptName: String
    package let uniqueName: String
    package let versionName: String
    package let pointSize: Double
    package let matrix: PresentationAffineTransform
    package let variations: [PresentationFontVariation]
    package let metrics: PresentationFontMetrics
}
