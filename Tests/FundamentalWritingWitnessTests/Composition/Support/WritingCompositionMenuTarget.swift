import AppKit

@MainActor
final class WritingCompositionMenuTarget: NSObject
{
    let action: @MainActor () -> Void

    init(action: @escaping @MainActor () -> Void)
    {
        self.action = action
    }

    @objc func invoke(_ sender: Any?)
    {
        action()
    }
}
