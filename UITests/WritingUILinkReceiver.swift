import Foundation
import Network

actor WritingUILinkReceiver
{
    let listener: NetworkListener<TCP>
    let path = "/fundamental-link-" + UUID().uuidString
    var address: URL?
    var receivedPath: String?
    var failure: String?
    var task: Task<Void, Never>?

    init() throws
    {
        let parameters = NWParametersBuilder({ TCP() })
            .localEndpoint(.hostPort(host: "127.0.0.1", port: .any))
            .localOnly(true)
        listener = try NetworkListener(using: parameters)
            .newConnectionLimit(4)
    }

    func start() async throws -> URL
    {
        listener.onStateUpdate
        {
            [self] listener, state in
            if state == .ready, let port = listener.port
            {
                address = URL(string:
                    "http://127.0.0.1:\(port.rawValue)\(path)")
            }
        }
        task = Task
        {
            do
            {
                try await listener.run { try await self.respond(to: $0) }
            }
            catch
            {
                if !Task.isCancelled
                {
                    failure = String(describing: error)
                }
            }
        }
        let deadline = ContinuousClock.now.advanced(by: .seconds(10))
        while address == nil && failure == nil && ContinuousClock.now < deadline
        {
            try await Task.sleep(for: .milliseconds(20))
        }
        guard let address
        else
        {
            throw URLError(.cannotConnectToHost)
        }
        return address
    }

    func receipt() async throws -> String
    {
        let deadline = ContinuousClock.now.advanced(by: .seconds(10))
        while receivedPath == nil && failure == nil &&
            ContinuousClock.now < deadline
        {
            try await Task.sleep(for: .milliseconds(20))
        }
        guard let receivedPath
        else
        {
            throw URLError(.timedOut)
        }
        return receivedPath
    }

    func stop() async
    {
        task?.cancel()
        await task?.value
        task = nil
        listener.onStateUpdate { _, _ in }
    }
}
