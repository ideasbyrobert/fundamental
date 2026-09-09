import FundamentalDocument

struct WritingCodeLanguageRequest: Equatable, Sendable
{
    let observation: DocumentObservation
    let range: DocumentRange
    private let language: SemanticCodeLanguageIdentifier?

    var value: String { language?.value ?? "" }

    init?(in projection: WritingProjection, range: DocumentRange? = nil)
    {
        let range = range ?? projection.snapshot.selection.range
        guard let selection = SemanticBlockSelection(
            range: range, in: projection.snapshot.snapshot.document
        ), selection.blocks.count == 1,
              case let .code(code) = selection.blocks[0].block
        else
        {
            return nil
        }
        switch code
        {
        case .plain:
            language = nil
        case let .languageTagged(code):
            language = code.language
        }
        observation = projection.observation
        self.range = range
    }

    func command(setting text: String) -> DocumentSessionCommand?
    {
        let language = SemanticCodeLanguageIdentifier(text)
        guard text.isEmpty || language != nil
        else
        {
            return nil
        }
        return .convertCode(observation,
            SemanticCodeConversion(range: range, codeLanguage: language)
        )
    }
}
