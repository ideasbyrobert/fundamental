import AppKit
import FundamentalDocument

extension WritingTextView
{
    override func insertNewline(_ sender: Any?)
    {
        if !removeListRole(requiringEmpty: true)
        {
            super.insertNewline(sender)
        }
    }

    override func deleteBackward(_ sender: Any?)
    {
        if !removeListRole(requiringEmpty: false)
        {
            super.deleteBackward(sender)
        }
    }

    private func removeListRole(requiringEmpty: Bool) -> Bool
    {
        guard let bridge = delegate as? WritingNativeBridge,
              bridge.finishComposition(in: self), selectedRange().length == 0,
              let index = bridge.projection.map.spans.firstIndex(where:
                  { $0.range.location == selectedRange().location }),
              case .listItem = bridge.projection.snapshot.snapshot.document
                  .content.blocks[index].block,
              !requiringEmpty || bridge.projection.map.spans[index].range
                  .length == 0
        else
        {
            return false
        }
        bridge.changeStyle(.body, in: self)
        return true
    }
}
