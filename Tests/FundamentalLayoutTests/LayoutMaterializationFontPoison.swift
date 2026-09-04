@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    func poison(
        _ font: LayoutFontIdentity
    ) -> LayoutFontIdentity
    {
        LayoutFontIdentity(
            postScriptName: font.postScriptName + "-poisoned",
            uniqueName: font.uniqueName,
            versionName: font.versionName,
            pointSize: font.pointSize,
            matrix: font.matrix,
            variations: font.variations,
            metrics: font.metrics
        )
    }
}
