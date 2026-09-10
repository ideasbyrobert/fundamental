extension SemanticLinkDestination
{
    package static func == (
        lhs: SemanticLinkDestination, rhs: SemanticLinkDestination
    ) -> Bool
    {
        lhs.value.utf16.elementsEqual(rhs.value.utf16)
    }
}
