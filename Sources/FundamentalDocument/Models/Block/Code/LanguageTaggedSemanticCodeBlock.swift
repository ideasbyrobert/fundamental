struct LanguageTaggedSemanticCodeBlock: Equatable, Sendable
{
    let runs: [SemanticRun]
    let language: SemanticCodeLanguageIdentifier
}
