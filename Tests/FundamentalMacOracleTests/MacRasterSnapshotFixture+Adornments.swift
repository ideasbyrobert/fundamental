@testable import FundamentalPresentation

extension MacRasterSnapshotFixture
{
    static func mismatchedColor(
        in snapshot: PresentationSnapshot
    ) -> PresentationColor?
    {
        let source = snapshot.presentedDocument.plane.palette.text
        guard let identity = PresentationColorSpaceIdentity(
            name: source.colorSpace.name + " mismatched",
            profile: source.colorSpace.profile,
            componentCount: source.colorSpace.componentCount
        )
        else
        {
            return nil
        }
        return PresentationColor(
            colorSpace: identity,
            components: source.components,
            alpha: source.alpha
        )
    }

    static func replacingCaretColor(
        in snapshot: PresentationSnapshot,
        with color: PresentationColor
    ) -> PresentationSnapshot?
    {
        guard case let .caret(document, source) = snapshot
        else
        {
            return nil
        }
        let caret = PresentationCaretAdornment(
            position: source.position,
            sitePosition: source.sitePosition,
            lineBounds: source.lineBounds,
            logicalBounds: source.logicalBounds,
            color: color
        )
        return .caret(document, caret)
    }

    static func replacingSelectionColor(
        in snapshot: PresentationSnapshot,
        with color: PresentationColor
    ) -> PresentationSnapshot?
    {
        guard case let .selection(document, source) = snapshot
        else
        {
            return nil
        }
        let selection = PresentationSelectionAdornment(
            anchor: source.anchor,
            focus: source.focus,
            color: color,
            text: source.text,
            sourceSlices: source.sourceSlices,
            firstFragment: source.firstFragment,
            remainingFragments: source.remainingFragments
        )
        return .selection(document, selection)
    }
}
