import Foundation
import Testing

@testable import FundamentalParagraph

@Suite("Bundled paragraph pattern admission")
struct BundledPatternTests
{
    @Test
    func loadsThePinnedLanguageCatalog() throws
    {
        let catalog = try OwnedPatternCatalog.bundled()
        #expect(catalog.resources.map(\.locale) == ["en_US", "en_GB", "ru_RU"])
        #expect(try catalog.dictionary(.american)
            .hyphenate("extraordinary").boundaries == [2, 5, 7, 9])
        #expect(try catalog.dictionary(.british)
            .hyphenate("extraordinary").boundaries == [2, 10])
        #expect(try catalog.dictionary(.russian)
            .hyphenate("район").boundaries == [3])
    }

    @Test
    func refusesAlteredManifestBeforeAnyResourceLookup() throws
    {
        let root = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(
            at: root, withIntermediateDirectories: false
        )
        defer
        {
            try? FileManager.default.removeItem(at: root)
        }
        let manifest = root.appending(path: "manifest.json")
        for bytes in [Data("[]".utf8), Data([0xFF])]
        {
            try bytes.write(to: manifest, options: .atomic)
            #expect(throws: PatternFailure.checksumMismatch)
            {
                try BundledParagraphPatterns.load(from: root)
            }
        }
    }

    @Test
    func aValidManifestCannotFallBackToUnrequestedResources() throws
    {
        let root = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(
            at: root, withIntermediateDirectories: false
        )
        defer
        {
            try? FileManager.default.removeItem(at: root)
        }
        let original = try BundledParagraphPatterns.directory
            .appending(path: "manifest.json")
        try FileManager.default.copyItem(
            at: original, to: root.appending(path: "manifest.json")
        )
        #expect(throws: CocoaError.self)
        {
            try BundledParagraphPatterns.load(from: root)
        }
    }
}
