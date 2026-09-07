import Foundation

package struct DocumentFileLocation: Hashable, Sendable
{
    package let url: URL
    let path: String

    package init?(_ url: URL)
    {
        let path = url.path(percentEncoded: false)
        guard url.isFileURL,
              url.host == nil || url.host == "" || url.host == "localhost",
              url.user == nil,
              url.password == nil,
              url.port == nil,
              url.query == nil,
              url.fragment == nil,
              path.hasPrefix("/"),
              path != "/",
              !path.utf8.contains(0)
        else
        {
            return nil
        }
        self.url = url
        self.path = path
    }
}
