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
                  let geometry = selectionGeometry(line)
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
              completeText.contains(where:
              {
                  $0 != "\n" && $0 != "\r"
              }),
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

    static func selectionLines(
        _ selection: PresentationTextSelection,
        document: PresentedDocument
    ) -> [PresentationSelectionLine]?
    {
        let residents = document.residents.all
        let anchorOffset = selection.anchor.sourcePoint.utf16Offset
        let focusOffset = selection.focus.sourcePoint.utf16Offset
        guard anchorOffset != focusOffset
        else
        {
            return nil
        }
        let lowerPosition = anchorOffset < focusOffset
            ? selection.anchor
            : selection.focus
        let upperPosition = anchorOffset < focusOffset
            ? selection.focus
            : selection.anchor
        guard let lowerIndex = residents.firstIndex(where:
        {
            $0.residentID == lowerPosition.residentID
        }),
              let upperIndex = residents.firstIndex(where:
              {
                  $0.residentID == upperPosition.residentID
              }),
              lowerIndex <= upperIndex
        else
        {
            return nil
        }
        var lines: [PresentationSelectionLine] = []
        var precedingUpper: Int?
        var matchedLowerEndpoint = false
        var matchedUpperEndpoint = false
        for index in lowerIndex ... upperIndex
        {
            let resident = residents[index]
            guard let line = residentText(resident.content),
                  line.firstCaretSite.sourcePoint.domain
                    == lowerPosition.sourcePoint.domain,
                  let firstCaret = line.caretSites.first,
                  let lastCaret = line.caretSites.last,
                  firstCaret.sourcePoint.utf16Offset
                    <= lastCaret.sourcePoint.utf16Offset,
                  precedingUpper == nil
                    || precedingUpper
                        == firstCaret.sourcePoint.utf16Offset
            else
            {
                return nil
            }
            let lowerOffset = max(
                lowerPosition.sourcePoint.utf16Offset,
                firstCaret.sourcePoint.utf16Offset
            )
            let upperOffset = min(
                upperPosition.sourcePoint.utf16Offset,
                lastCaret.sourcePoint.utf16Offset
            )
            guard lowerOffset <= upperOffset,
                  let lowerCaret = exactCaret(
                      lowerOffset,
                      line: line
                  ),
                  let upperCaret = exactCaret(
                      upperOffset,
                      line: line
                  )
            else
            {
                return nil
            }
            if index == lowerIndex
            {
                guard lowerCaret.sourcePoint
                        == lowerPosition.sourcePoint
                else
                {
                    return nil
                }
                matchedLowerEndpoint = true
            }
            if index == upperIndex
            {
                guard upperCaret.sourcePoint
                        == upperPosition.sourcePoint
                else
                {
                    return nil
                }
                matchedUpperEndpoint = true
            }
            if lowerOffset == upperOffset
            {
                let beginsAfterLowerEndpoint = index == lowerIndex
                    && lowerCaret == lastCaret
                let endsBeforeUpperEndpoint = index == upperIndex
                    && upperCaret == firstCaret
                guard beginsAfterLowerEndpoint || endsBeforeUpperEndpoint
                else
                {
                    return nil
                }
                precedingUpper = lastCaret.sourcePoint.utf16Offset
                continue
            }
            lines.append(PresentationSelectionLine(
                residentID: resident.residentID,
                line: line,
                lowerCaret: lowerCaret,
                upperCaret: upperCaret
            ))
            precedingUpper = lastCaret.sourcePoint.utf16Offset
        }
        guard matchedLowerEndpoint,
              matchedUpperEndpoint,
              !lines.isEmpty
        else
        {
            return nil
        }
        return lines
    }

    static func exactCaret(
        _ offset: Int,
        line: PresentedTextLine
    ) -> PresentedCaretSite?
    {
        let matches = line.caretSites.filter
        {
            $0.sourcePoint.utf16Offset == offset
        }
        guard matches.count == 1
        else
        {
            return nil
        }
        return matches[0]
    }
}
