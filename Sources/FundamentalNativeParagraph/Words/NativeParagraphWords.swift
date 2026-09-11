import FundamentalParagraph
import Foundation
import NaturalLanguage

package struct NativeParagraphWords: Sendable
{
    package let source: ParagraphWordSource
    package let language: NativeWordLanguage
    package let observations: [NativeWordObservation]
    package let returnedUTF16: [UInt16]

    package init(
        source: ParagraphWordSource, language: NativeWordLanguage
    ) throws
    {
        self.source = source
        self.language = language
        let text = source.source.text
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        tokenizer.setLanguage(NLLanguage(rawValue: language.rawValue))
        var observations: [NativeWordObservation] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex)
        {
            range, flags in
            let native = NSRange(range, in: text)
            let lower = native.location
            let upper = lower + native.length
            observations.append(NativeWordObservation(
                flags: UInt64(flags.rawValue),
                resolution: source.resolve(lower..<upper)
            ))
            return true
        }
        guard let retained = tokenizer.string,
              retained.utf16.elementsEqual(source.source.utf16)
        else
        {
            throw WordScopeFailure.nativeSourceChanged
        }
        self.observations = observations
        returnedUTF16 = Array(retained.utf16)
    }
}
