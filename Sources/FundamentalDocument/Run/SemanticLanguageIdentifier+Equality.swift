extension SemanticLanguageIdentifier
{
    package static func == (
        lhs: SemanticLanguageIdentifier, rhs: SemanticLanguageIdentifier
    ) -> Bool
    {
        lhs.value.utf16.elementsEqual(rhs.value.utf16)
    }
}
