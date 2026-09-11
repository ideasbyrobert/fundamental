import Foundation
import Network

extension WritingUILinkReceiver
{
    func respond(to connection: NetworkConnection<TCP>) async throws
    {
        try await withThrowingTaskGroup(of: Void.self)
        {
            group in
            group.addTask { try await self.readRequest(from: connection) }
            group.addTask
            {
                try await Task.sleep(for: .seconds(5))
                throw URLError(.timedOut)
            }
            defer { group.cancelAll() }
            try await group.next()
        }
    }

    private func readRequest(from connection: NetworkConnection<TCP>)
        async throws
    {
        var bytes = Data()
        let terminator = Data("\r\n\r\n".utf8)
        while bytes.count < 8192 && bytes.range(of: terminator) == nil
        {
            let message = try await connection.receive(
                atMost: 8192 - bytes.count
            )
            bytes.append(message.content)
            if message.metadata.endOfStream
            {
                return
            }
        }
        let request = String(decoding: bytes, as: UTF8.self)
        let line = request.components(separatedBy: "\r\n").first ?? ""
        let accepted = bytes.range(of: terminator) != nil &&
            (line == "GET \(path) HTTP/1.1" || line == "GET \(path) HTTP/1.0")
        let body = accepted ? """
            <!doctype html><html><head><meta charset="utf-8">
            <title>Fundamental Link Witness</title></head><body>
            <h1>Link handoff confirmed</h1><p>\(path)</p></body></html>
            """ : "Not found"
        let status = accepted ? "200 OK" : "404 Not Found"
        let response = "HTTP/1.1 \(status)\r\n" +
            "Content-Type: text/html; charset=utf-8\r\n" +
            "Content-Length: \(body.utf8.count)\r\n" +
            "Cache-Control: no-store\r\nConnection: close\r\n\r\n" + body
        try await connection.send(Data(response.utf8), endOfStream: true)
        if accepted
        {
            receivedPath = path
        }
    }
}
