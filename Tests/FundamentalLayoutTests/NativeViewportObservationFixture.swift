import AppKit

@MainActor
final class NativeViewportObservationFixture: NSObject
{
    let storage: NSTextContentStorage
    let manager: NSTextLayoutManager
    let controller: NSTextViewportLayoutController
    let source: NSString
    var bounds: CGRect
    var configured: [NSTextLayoutFragment] = []

    init(
        text: String,
        width: Double,
        height: Double
    )
    {
        let storage = NSTextContentStorage()
        let manager = NSTextLayoutManager()
        let container = NSTextContainer(size: CGSize(
            width: width,
            height: CGFloat.greatestFiniteMagnitude
        ))
        container.lineFragmentPadding = 0
        storage.addTextLayoutManager(manager)
        manager.textContainer = container
        storage.attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.systemFont(ofSize: 17)
            ]
        )
        self.storage = storage
        self.manager = manager
        controller = manager.textViewportLayoutController
        source = text as NSString
        bounds = CGRect(x: 0, y: 0, width: width, height: height)
        super.init()
        controller.delegate = self
    }

    var sourceLength: Int
    {
        source.length
    }

    func layout() -> [NSTextLayoutFragment]
    {
        configured.removeAll(keepingCapacity: true)
        controller.layoutViewport()
        return configured
    }

    func relocate(toUTF16Offset offset: Int) -> [NSTextLayoutFragment]?
    {
        guard let location = storage.location(
            storage.documentRange.location,
            offsetBy: offset
        )
        else
        {
            return nil
        }
        configured.removeAll(keepingCapacity: true)
        let anchor = controller.relocateViewport(to: location)
        bounds.origin.y = anchor
        controller.layoutViewport()
        return configured
    }

}
