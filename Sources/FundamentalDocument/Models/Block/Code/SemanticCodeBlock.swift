enum SemanticCodeBlock: Equatable, Sendable
{
    case plain(PlainSemanticCodeBlock)
    case languageTagged(LanguageTaggedSemanticCodeBlock)

    var runs: [SemanticRun]
    {
        switch self
        {
        case let .plain(block):
            block.runs
        case let .languageTagged(block):
            block.runs
        }
    }
}
