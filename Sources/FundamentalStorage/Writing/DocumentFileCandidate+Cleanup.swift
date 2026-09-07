import Foundation

extension DocumentFileCandidate
{
    var recoveryLocations: [URL]
    {
        if let backupURL
        {
            return [directory, backupURL]
        }
        return [directory]
    }

    func discard() -> [URL]
    {
        preserved = true
        var retained: [URL] = []
        for item in recoveryLocations.reversed()
        {
            do
            {
                try FileManager.default.removeItem(at: item)
            }
            catch let failure as CocoaError
                where failure.code == .fileNoSuchFile
            {
                continue
            }
            catch
            {
                retained.append(item)
            }
        }
        return retained
    }
}
