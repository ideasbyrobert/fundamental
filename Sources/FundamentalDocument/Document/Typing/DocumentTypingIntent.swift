package struct DocumentTypingIntent: Equatable, Sendable
{
    package let attributes: SemanticRunAttributes

    package init(attributes: SemanticRunAttributes)
    {
        self.attributes = attributes
    }

    package static func == (lhs: Self, rhs: Self) -> Bool
    {
        switch (lhs.attributes, rhs.attributes)
        {
        case let (.direct(left), .direct(right)):
            return left == right
        case let (.scoped(left, leftScopes), .scoped(right, rightScopes)):
            return left == right && matches(leftScopes, rightScopes)
        default:
            return false
        }
    }

    private static func matches(
        _ lhs: SemanticRunScopes, _ rhs: SemanticRunScopes
    ) -> Bool
    {
        switch (lhs, rhs)
        {
        case let (.link(left), .link(right)):
            return left.value.utf16.elementsEqual(right.value.utf16)
        case let (.language(left), .language(right)):
            return left.value.utf16.elementsEqual(right.value.utf16)
        case let (.linkAndLanguage(leftLink, leftLanguage),
                  .linkAndLanguage(rightLink, rightLanguage)):
            return leftLink.value.utf16.elementsEqual(rightLink.value.utf16) &&
                leftLanguage.value.utf16.elementsEqual(
                    rightLanguage.value.utf16
                )
        default:
            return false
        }
    }
}
