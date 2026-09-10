import AppKit
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderDocumentInputTests
{
    @Test("every admitted role reaches native selection copy and accessibility",
          arguments: [600.0, 820.0], ["light", "dark"])
    func nativeRoles(width: Double, appearance: String) throws
    {
        let source = try MacReaderDocumentFixture.source(
            MacReaderDocumentFixture.admittedBlocks()
        )
        let retained = source
        let controller = try MacReaderDocumentFixture.window(
            source, width: width
        )
        let window = try #require(controller.window)
        defer { window.close() }
        window.appearance = try MacOracleTestSurface.appearance(
            appearance == "light" ? .aqua : .darkAqua
        )
        controller.showWindow(nil)
        controller.synchronize()
        let model = controller.readerView.model
        try MacReaderDocumentFixture.expectSource(source, in: model)
        let blocks = source.document.content.blocks
        let residents = model.snapshot.presentedDocument.residents.all
        #expect(Set(residents.map(\.residentID.blockID))
            == Set(blocks.map(\.blockID.value)))
        let nodes = try #require(controller.readerView
            .accessibilityChildren() as? [MacAccessibilityElement])
        try #require(nodes.count == residents.count)
        for (node, resident) in zip(nodes, residents)
        {
            let line = try #require(MacReaderDocumentFixture.line(
                resident.content
            ))
            #expect(node.accessibilityAttributeValue(.value) as? String
                == line.text)
            let ordinal = resident.residentID.blockOrdinal
            let heading = (1 ... 7).contains(ordinal)
            #expect(node.accessibilityAttributeValue(.role)
                as? NSAccessibility.Role
                == (heading ? .headingRole : .staticText))
            if heading
            {
                let level = max(1, ordinal - 1)
                #expect((node.accessibilityAttributeValue(
                    .headingLevelAttribute
                ) as? NSNumber)?.intValue == level)
            }
        }
        try MacReaderDocumentFixture.capture(
            controller, name: "roles-\(Int(width))-\(appearance)"
        )
        for block in blocks
        {
            let selection = try MacReaderDocumentFixture.copy(
                blockID: block.blockID.value, from: controller
            )
            let text = try MacReaderDocumentFixture.runs(block.block)
                .map(\.text).joined()
            #expect(selection.text.utf16.elementsEqual(text.utf16))
            #expect(selection.sourceSlices.allSatisfy
            {
                $0.source.domain == .block(block.blockID.value)
            })
        }
        #expect(source == retained)
    }
}
