import FundamentalDocument

package struct DocumentFileRead: Sendable
{
    package let location: DocumentFileLocation
    package let document: CanonicalDocument
    package let revision: DocumentFileRevision
}
