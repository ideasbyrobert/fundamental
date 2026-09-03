import AppKit

@MainActor
package final class MacAccessibilityElement: NSAccessibilityElement
{
    let semantics: MacAccessibilitySemantics
    private let frameValue: NSRect
    nonisolated(unsafe) private unowned let parentValue: AnyObject
    nonisolated(unsafe) private var childValues: [MacAccessibilityElement]
    nonisolated(unsafe) private var titleElementValues:
        [MacAccessibilityElement]

    init(
        semantics: MacAccessibilitySemantics,
        frame: NSRect,
        parent: AnyObject
    )
    {
        self.semantics = semantics
        frameValue = frame
        parentValue = parent
        childValues = []
        titleElementValues = []
        super.init()
    }

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
        return attributes
    }

    package override func accessibilityAttributeValue(
        _ attribute: NSAccessibility.Attribute
    ) -> Any?
    {
        switch attribute
        {
        case .role:
            return semantics.role
        case .value:
            return semantics.value
        case .position:
            return NSValue(point: frameValue.origin)
        case .size:
            return NSValue(size: frameValue.size)
        case .parent:
            return parentValue
        case .children:
            return childValues
        case .headingLevelAttribute:
            switch semantics
            {
            case .title:
                return NSNumber(value: 1)
            case let .section(level, _):
                return NSNumber(value: level)
            default:
                return nil
            }
        case .rowIndexRange:
            guard let geometry = semantics.cellGeometry
            else
            {
                return nil
            }
            return NSValue(range: NSRange(
                location: geometry.rowTrack,
                length: geometry.rowSpan
            ))
        case .columnIndexRange:
            guard let geometry = semantics.cellGeometry
            else
            {
                return nil
            }
            return NSValue(range: NSRange(
                location: geometry.columnTrack,
                length: geometry.columnSpan
            ))
        case .titleUIElement:
            return titleElementValues.first
        default:
            return nil
        }
    }
}
