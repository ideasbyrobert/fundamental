package struct SemanticCodeConversion: Equatable, Sendable
{
    enum Target: Equatable, Sendable
    {
        case code(SemanticCodeLanguageIdentifier?)
        case prose(CanonicalBlockStyle)
    }

    let range: DocumentRange
    let target: Target
    let continuationBlockIDs: [FundamentalBlockID]

    package init(
        range: DocumentRange,
        codeLanguage: SemanticCodeLanguageIdentifier? = nil
    )
    {
        self.range = range
        target = .code(codeLanguage)
        continuationBlockIDs = []
    }

    package init?(
        range: DocumentRange, proseStyle: CanonicalBlockStyle,
        continuationBlockIDs: [FundamentalBlockID] = []
    )
    {
        guard proseStyle != .monostyled,
              Set(continuationBlockIDs).count == continuationBlockIDs.count
        else
        {
            return nil
        }
        self.range = range
        target = .prose(proseStyle)
        self.continuationBlockIDs = continuationBlockIDs
    }
}
