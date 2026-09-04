import AppKit

extension NativeViewportObservationFixture:
    @MainActor NSTextViewportLayoutControllerDelegate
{
    func viewportBounds(
        for controller: NSTextViewportLayoutController
    ) -> CGRect
    {
        bounds
    }

    func textViewportLayoutController(
        _ controller: NSTextViewportLayoutController,
        configureRenderingSurfaceFor fragment: NSTextLayoutFragment
    )
    {
        configured.append(fragment)
    }
}
