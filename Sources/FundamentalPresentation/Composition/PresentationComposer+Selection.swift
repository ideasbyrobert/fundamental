extension PresentationComposer
{
    static func selection(
        _ selection: PresentationTextSelection,
        document: PresentedDocument,
        specification: PresentationSpecificationIdentity
    ) -> PresentationSelectionAdornment?
    {
        guard selection.anchor.sourcePoint.domain
                == selection.focus.sourcePoint.domain,
              let lines = selectionLines(
                  selection,
                  document: document
              )
        else
        {
            return nil
        }
        var fragments: [PresentationSelectionFragment] = []
        var completeText = ""
        var completeSlices: [PresentationSourceSlice] = []
        var establishedDirection: PresentationSelectionDirection?
        for line in lines
        {
            guard let text = selectedText(line),
                  let slices = selectedSlices(line),
                  slices.map(\.text).joined() == text,
                  let geometry = selectionGeometry(
                      line, minimumWidth: specification.caretWidth
                  )
            else
            {
                return nil
            }
            completeText += text
            completeSlices.append(contentsOf: slices)
            guard let bounds = geometry.bounds,
                  let direction = geometry.direction
            else
            {
                continue
            }
            if let establishedDirection,
               establishedDirection != direction
            {
                return nil
            }
            establishedDirection = direction
            guard fragments.count
                    < specification.maximumSelectionFragmentCount
            else
            {
                return nil
            }
            fragments.append(PresentationSelectionFragment(
                residentID: line.residentID,
                range: line.lowerCaret.sourcePoint.utf16Offset
                    ..< line.upperCaret.sourcePoint.utf16Offset,
                logicalBounds: bounds,
                text: text,
                sourceSlices: slices
            ))
        }
        guard let firstFragment = fragments.first,
              completeSlices.map(\.text).joined() == completeText,
              contiguous(completeSlices)
        else
        {
            return nil
        }
        return PresentationSelectionAdornment(
            anchor: selection.anchor,
            focus: selection.focus,
            color: specification.adornmentPalette.selection,
            text: completeText,
            sourceSlices: completeSlices,
            firstFragment: firstFragment,
            remainingFragments: Array(fragments.dropFirst())
        )
    }
}
