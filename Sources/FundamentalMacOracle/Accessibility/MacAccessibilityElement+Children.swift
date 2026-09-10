extension MacAccessibilityElement
{
    func replaceChildren(
        _ children: [MacAccessibilityElement]
    )
    {
        childValues = children
    }

    func replaceTitleElement(
        _ element: MacAccessibilityElement
    )
    {
        titleElementValues = [element]
    }
}
