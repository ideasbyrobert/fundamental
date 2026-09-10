import AppKit

extension MacAccessibilityElement
{
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
        case .index:
            return semantics.listItem.map
            {
                NSNumber(value: $0.position.index)
            }
        case .numberOfCharacters:
            guard case let .listText(_, source) = semantics
            else
            {
                return nil
            }
            return NSNumber(value: source.utf16.count)
        case .titleUIElement:
            return titleElementValues.first
        default:
            return nil
        }
    }
}
