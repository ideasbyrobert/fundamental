import AppKit
import FundamentalDocument

extension WritingWindowController
{
    var canResolveLink: Bool
    {
        guard canFormatSelection, bridge.composition == nil,
              !textView.hasMarkedText(), textView.textLayoutManager != nil,
              case let .editable(current) = bridge.session.state
        else
        {
            return false
        }
        return DocumentObservation(snapshot: current.snapshot) ==
            bridge.projection.observation &&
            textView.selectedRange() == bridge.projection.selection &&
            textView.string.utf16.elementsEqual(bridge.projection.text.utf16)
    }

    var linkRequest: WritingLinkRequest?
    {
        canResolveLink ? WritingLinkRequest(in: bridge.projection) : nil
    }

    func validateOpenLink(_ item: NSValidatedUserInterfaceItem) -> Bool
    {
        guard canResolveLink,
              let request = WritingOpenLinkMenu.choice(from: item)?
                  .representedObject as? WritingLinkRequest
        else
        {
            return false
        }
        return request == linkRequest
    }

    @objc func openLink(_ sender: Any?)
    {
        guard let item = WritingOpenLinkMenu.choice(from: sender),
              validateOpenLink(item),
              let request = item.representedObject as? WritingLinkRequest
        else
        {
            return
        }
        followLink(request)
    }

    private func followLink(_ request: WritingLinkRequest)
    {
        guard !openDestination(request.url)
        else
        {
            return
        }
        let alert = NSAlert()
        alert.messageText = "Couldn’t Open Link"
        alert.informativeText = "macOS could not open this link."
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: documentWindow)
    }
}
