extension SemanticCodeLanguageIdentifier
{
    package static func == (
        lhs: SemanticCodeLanguageIdentifier,
        rhs: SemanticCodeLanguageIdentifier
    ) -> Bool
    {
        lhs.value.utf16.elementsEqual(rhs.value.utf16)
    }
}
