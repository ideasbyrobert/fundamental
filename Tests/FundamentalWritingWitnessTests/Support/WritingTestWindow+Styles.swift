import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingTestWindow
{
    init(styles: [CanonicalBlockStyle], texts: [String]) throws
    {
        try #require(styles.count == texts.count)
        let blocks = zip(styles, texts).map
        {
            $0.semanticBlock(runs: $1.isEmpty ? [] : [SemanticRun(text: $1)])
        }
        try self.init(session: DocumentSession(
            state: WritingTestDocument(blocks: blocks).state,
            initiallySaved: true
        ))
    }

    var styles: [CanonicalBlockStyle?]
    {
        session.document.content.blocks.map { CanonicalBlockStyle($0.block) }
    }

    func selectBlock(_ index: Int)
    {
        let range = controller.bridge.projection.map.spans[index].range
        select(range.location, range.length)
    }

    func choose(_ style: CanonicalBlockStyle) throws
    {
        let popup = controller.formatting.block
        let item = try #require(popup.itemArray.first
        {
            $0.representedObject as? String == style.rawValue
        })
        popup.select(item)
        #expect(popup.sendAction(popup.action, to: popup.target))
    }

    func markerLabels() throws -> [String]
    {
        _ = try WritingWindowCapture.capture(self)
        return view.listMarkers(in: view.visibleRect).map(\.label)
    }
}
