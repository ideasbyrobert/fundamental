import AppKit

extension WritingApplicationDelegate
{
    func applicationShouldTerminate(
        _ sender: NSApplication
    ) -> NSApplication.TerminateReply
    {
        if terminationPending
        {
            return .terminateLater
        }
        for controller in controllers.reversed()
        {
            if controller.mayClose()
            {
                controller.documentWindow.close()
            }
            else if let pending = controller.closeTask
            {
                terminationPending = true
                finishTermination(after: pending, application: sender)
                return .terminateLater
            }
            else
            {
                return .terminateCancel
            }
        }
        return .terminateNow
    }

    private func finishTermination(
        after pending: Task<Bool, Never>,
        application: NSApplication
    )
    {
        Task
        {
            let closed = await pending.value
            terminationPending = false
            guard closed
            else
            {
                application.reply(toApplicationShouldTerminate: false)
                return
            }
            switch applicationShouldTerminate(application)
            {
            case .terminateNow:
                application.reply(toApplicationShouldTerminate: true)
            case .terminateCancel:
                application.reply(toApplicationShouldTerminate: false)
            case .terminateLater:
                break
            @unknown default:
                application.reply(toApplicationShouldTerminate: false)
            }
        }
    }
}
