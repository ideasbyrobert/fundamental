import Foundation

package struct OwnedPatternCatalog: Sendable
{
    package let resources: [PatternResource]
    private let dictionaries: [PatternLanguage: PatternDictionary]

    package init(directory: URL) throws
    {
        let path = directory.appendingPathComponent("manifest.json")
        let resources = try JSONDecoder().decode(
            [PatternResource].self, from: Data(contentsOf: path)
        )
        try self.init(resources: resources, directory: directory)
    }

    package init(resources: [PatternResource], directory: URL) throws
    {
        let expected = PatternLanguage.allCases.map(\.rawValue).sorted()
        guard resources.map(\.locale).sorted() == expected
        else
        {
            throw OwnedCandidateFailure.invalidCatalog
        }
        var dictionaries: [PatternLanguage: PatternDictionary] = [:]
        for resource in resources
        {
            guard let language = PatternLanguage(rawValue: resource.locale)
            else
            {
                throw OwnedCandidateFailure.invalidCatalog
            }
            dictionaries[language] = try resource.dictionary(from: directory)
        }
        self.resources = resources
        self.dictionaries = dictionaries
    }

    package func dictionary(_ language: PatternLanguage) throws
        -> PatternDictionary
    {
        guard let dictionary = dictionaries[language]
        else
        {
            throw OwnedCandidateFailure.invalidCatalog
        }
        return dictionary
    }
}
