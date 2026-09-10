import AppKit
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension WritingMixedDocumentFixture
{
    static func accessibleReader(
        _ controller: MacReaderWindowController
    ) throws
    {
        let residents = controller.readerView.model.snapshot
            .presentedDocument.residents.all
        let nodes = try #require(controller.readerView.accessibilityChildren()
            as? [MacAccessibilityElement])
        var nodeIndex = 0
        var lists: Set<UUID> = []
        for resident in residents
        {
            let id = resident.residentID.blockID
            if let item = resident.content.listItem
            {
                if !lists.insert(id).inserted { continue }
                try #require(nodes.indices.contains(nodeIndex))
                let node = nodes[nodeIndex]
                nodeIndex += 1
                #expect(node.accessibilityAttributeValue(.role)
                    as? NSAccessibility.Role == .group)
                let children = try #require(node.accessibilityChildren()
                    as? [MacAccessibilityElement])
                let body = try #require(children.last)
                let text = residents.filter { $0.residentID.blockID == id }
                    .compactMap(\.content.textLine).map(\.text).joined()
                #expect(body.accessibilityAttributeValue(.value)
                    as? String == text)
                #expect(body.accessibilityNumberOfCharacters()
                    == text.utf16.count)
                let markers = children.filter
                {
                    $0.accessibilityAttributeValue(.role)
                        as? NSAccessibility.Role == .listMarkerRole
                }
                if let marker = resident.content.listMarker
                {
                    #expect(markers.count == 1)
                    #expect(markers.first?.accessibilityAttributeValue(.value)
                        as? String == item.label)
                    #expect(marker.source.label == item.label)
                }
                continue
            }
            try #require(nodes.indices.contains(nodeIndex))
            let node = nodes[nodeIndex]
            nodeIndex += 1
            let line = try #require(resident.content.textLine)
            #expect(node.accessibilityAttributeValue(.value)
                as? String == line.text)
            let level: Int?
            switch resident.content
            {
            case .title: level = 1
            case let .section(value, _): level = value.rawValue
            default: level = nil
            }
            #expect(node.accessibilityAttributeValue(.role)
                as? NSAccessibility.Role
                == (level == nil ? .staticText : .headingRole))
            if let level
            {
                #expect((node.accessibilityAttributeValue(
                    .headingLevelAttribute
                ) as? NSNumber)?.intValue == level)
            }
        }
        #expect(nodeIndex == nodes.count)
    }
}
