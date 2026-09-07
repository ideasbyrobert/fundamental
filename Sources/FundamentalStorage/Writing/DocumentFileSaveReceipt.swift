import Foundation

package struct DocumentFileSaveReceipt: Sendable
{
    package let file: DocumentFileRead
    package let retainedItems: [URL]
}
