import AppKit

final class MacUnmatchedAppearance: NSAppearance
{
    override func bestMatch(
        from appearances: [NSAppearance.Name]
    ) -> NSAppearance.Name?
    {
        nil
    }
}
