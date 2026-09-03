import AppKit
import FundamentalPresentation

@MainActor
package final class MacReaderView: NSView
{
    package let model: MacReaderModel
    private let executor: MacRasterExecutor
    private var pointerState: MacPointerSelectionState
    private var accessibilityNodes: [MacAccessibilityElement]
    private var isSynchronizingPublication: Bool

    package init(
        frame: NSRect,
        model: MacReaderModel
    )
    {
        self.model = model
        executor = MacRasterExecutor()
        pointerState = .resting
        accessibilityNodes = []
        isSynchronizingPublication = false
        super.init(frame: frame)
        setAccessibilityElement(false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder)
    {
        fatalError()
    }

    package override var isFlipped: Bool
    {
        true
    }

    package override var acceptsFirstResponder: Bool
    {
        true
    }

    package var horizontalInset: Double
    {
        max(0, (bounds.width - model.readableMeasure) / 2)
    }

    package override func draw(_ dirtyRect: NSRect)
    {
        guard let context = NSGraphicsContext.current?.cgContext
        else
        {
            return
        }
        _ = executor.draw(
            model.snapshot,
            in: context,
            horizontalInset: horizontalInset
        )
    }

    package override func viewDidMoveToWindow()
    {
        super.viewDidMoveToWindow()
        if window == nil
        {
            removeAccessibility()
        }
        else
        {
            _ = synchronizeFromScrollView()
        }
    }

    package override func viewDidChangeEffectiveAppearance()
    {
        super.viewDidChangeEffectiveAppearance()
        synchronizeFromScrollView()
    }

    package override func mouseDown(with event: NSEvent)
    {
        window?.makeFirstResponder(self)
        guard let position = position(for: event)
        else
        {
            return
        }
        pointerState = .anchored(position)
        if model.showCaret(at: position)
        {
            refresh()
        }
    }

    package override func mouseDragged(with event: NSEvent)
    {
        guard case let .anchored(anchor) = pointerState,
              let focus = position(for: event),
              model.showSelection(anchor: anchor, focus: focus)
        else
        {
            return
        }
        refresh()
    }

    @objc
    package func copy(_ sender: Any?)
    {
        let pasteboard = (sender as? MacCopyDestination)?.pasteboard
            ?? .general
        _ = copySelection(to: pasteboard)
    }

    @discardableResult
    package func copySelection(
        to pasteboard: NSPasteboard
    ) -> Bool
    {
        guard case let .selection(_, selection) = model.snapshot
        else
        {
            return false
        }
        pasteboard.clearContents()
        return pasteboard.setString(
            selection.text,
            forType: .string
        )
    }

    @discardableResult
    package func synchronizeFromScrollView() -> Bool
    {
        guard !isSynchronizingPublication,
              let scrollView = enclosingScrollView,
              let clip = enclosingScrollView?.contentView,
              let screen = window?.screen,
              clip.bounds.width > 64,
              clip.bounds.height > 0
        else
        {
            return false
        }
        isSynchronizingPublication = true
        defer
        {
            isSynchronizingPublication = false
        }
        let requestedOriginY = clip.bounds.minY
        guard model.update(
            viewportWidth: clip.bounds.width,
            viewportHeight: clip.bounds.height,
            visibleOriginY: requestedOriginY,
            screen: screen,
            appearance: effectiveAppearance,
            increasedContrast: NSWorkspace.shared
                .accessibilityDisplayShouldIncreaseContrast
        )
        else
        {
            return false
        }
        setFrameSize(NSSize(
            width: clip.bounds.width,
            height: max(clip.bounds.height, model.documentHeight)
        ))
        var requestedBounds = clip.bounds
        requestedBounds.origin = NSPoint(x: 0, y: requestedOriginY)
        let admittedBounds = clip.constrainBoundsRect(requestedBounds)
        clip.scroll(to: admittedBounds.origin)
        scrollView.reflectScrolledClipView(clip)
        let settledOriginY = clip.bounds.minY
        if requestedOriginY != settledOriginY
            || model.visibleOriginY != settledOriginY
        {
            guard model.update(
                viewportWidth: clip.bounds.width,
                viewportHeight: clip.bounds.height,
                visibleOriginY: settledOriginY,
                screen: screen,
                appearance: effectiveAppearance,
                increasedContrast: NSWorkspace.shared
                    .accessibilityDisplayShouldIncreaseContrast
            )
            else
            {
                removeAccessibility()
                return false
            }
        }
        guard model.visibleOriginY == settledOriginY
        else
        {
            removeAccessibility()
            return false
        }
        needsDisplay = true
        refreshAccessibility()
        return true
    }

    package func refreshAccessibilityGeometry()
    {
        refreshAccessibility()
    }

    package override func accessibilityChildren() -> [Any]?
    {
        accessibilityNodes
    }

    private func position(
        for event: NSEvent
    ) -> PresentationTextPosition?
    {
        let local = convert(event.locationInWindow, from: nil)
        guard let point = PresentationPoint(
            x: local.x - horizontalInset,
            y: local.y
        )
        else
        {
            return nil
        }
        return model.nearestPosition(to: point)
    }

    private func refresh()
    {
        needsDisplay = true
        refreshAccessibility()
    }

    private func refreshAccessibility()
    {
        guard window != nil
        else
        {
            removeAccessibility()
            return
        }
        accessibilityNodes = MacAccessibilityTree.elements(
            document: model.snapshot.presentedDocument,
            view: self,
            horizontalInset: horizontalInset
        )
        setAccessibilityChildren(accessibilityNodes)
    }

    private func removeAccessibility()
    {
        accessibilityNodes = []
        setAccessibilityChildren(accessibilityNodes)
    }
}
