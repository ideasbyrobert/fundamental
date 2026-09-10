import AppKit

extension MacAccessibilityElement
{
    package override func accessibilityAttributeNames()
        -> [NSAccessibility.Attribute]
    {
        var attributes: [NSAccessibility.Attribute] = [
            .role,
            .position,
            .size,
            .parent,
            .children
        ]
        if semantics.exposesValue
        {
            attributes.append(.value)
        }
        switch semantics
        {
        case .title,
             .section:
            attributes.append(.headingLevelAttribute)
        default:
            break
        }
        if semantics.cellGeometry != nil
        {
            attributes.append(.rowIndexRange)
            attributes.append(.columnIndexRange)
        }
        if !titleElementValues.isEmpty
        {
            attributes.append(.titleUIElement)
        }
        if semantics.listItem != nil
        {
            attributes.append(.index)
        }
        if case .listText = semantics
        {
            attributes.append(.numberOfCharacters)
        }
        return attributes
    }
}
