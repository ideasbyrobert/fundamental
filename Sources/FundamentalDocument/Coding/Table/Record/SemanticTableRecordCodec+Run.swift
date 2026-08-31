extension SemanticTableRecordCodec
{
    static func decodeRuns(
        _ value: Any,
        path: [String]
    ) throws -> [SemanticRun]
    {
        let values = try array(value, path: path)
        return try values.enumerated().map
        {
            try decodeRun(
                $0.element,
                path: path + [String($0.offset)]
            )
        }
    }

    static func decodeRun(
        _ value: Any,
        path: [String]
    ) throws -> SemanticRun
    {
        let object = try object(value, path: path)
        let hasLink = object.keys.contains("link")
        let hasLanguage = object.keys.contains("language")
        var expected = ["text", "traits"]
        if hasLink
        {
            expected.append("link")
        }
        if hasLanguage
        {
            expected.append("language")
        }
        try requireKeys(object, expected, path: path)

        let text = try string(
            required("text", in: object, path: path),
            path: path + ["text"]
        )
        let traits = try decodeTraits(
            required("traits", in: object, path: path),
            path: path + ["traits"]
        )

        switch (hasLink, hasLanguage)
        {
        case (false, false):
            return .direct(SemanticDirectRun(
                text: text,
                traits: traits
            ))
        case (true, false):
            let link = try decodeLink(object, path: path)
            return .scoped(SemanticScopedRun(
                text: text,
                traits: traits,
                scopes: .link(link)
            ))
        case (false, true):
            let language = try decodeLanguage(object, path: path)
            return .scoped(SemanticScopedRun(
                text: text,
                traits: traits,
                scopes: .language(language)
            ))
        case (true, true):
            let link = try decodeLink(object, path: path)
            let language = try decodeLanguage(object, path: path)
            return .scoped(SemanticScopedRun(
                text: text,
                traits: traits,
                scopes: .linkAndLanguage(
                    link: link,
                    language: language
                )
            ))
        }
    }

    static func decodeTraits(
        _ value: Any,
        path: [String]
    ) throws -> Set<SemanticInlineTrait>
    {
        let values = try array(value, path: path)
        var traits: Set<SemanticInlineTrait> = []
        for (index, value) in values.enumerated()
        {
            let valuePath = path + [String(index)]
            let rawValue = try string(value, path: valuePath)
            guard let trait = SemanticInlineTrait(rawValue: rawValue)
            else
            {
                throw invalid(valuePath, "Unknown inline trait")
            }
            guard traits.insert(trait).inserted
            else
            {
                throw invalid(valuePath, "Duplicate inline trait")
            }
        }
        return traits
    }

    static func decodeLink(
        _ object: [String: Any],
        path: [String]
    ) throws -> SemanticLinkDestination
    {
        let valuePath = path + ["link"]
        let value = try string(
            required("link", in: object, path: path),
            path: valuePath
        )
        guard let link = SemanticLinkDestination(value)
        else
        {
            throw invalid(valuePath, "Link must not be blank")
        }
        return link
    }

    static func decodeLanguage(
        _ object: [String: Any],
        path: [String]
    ) throws -> SemanticLanguageIdentifier
    {
        let valuePath = path + ["language"]
        let value = try string(
            required("language", in: object, path: path),
            path: valuePath
        )
        guard let language = SemanticLanguageIdentifier(value)
        else
        {
            throw invalid(valuePath, "Language must not be blank")
        }
        return language
    }

    static func encodeRuns(
        _ runs: [SemanticRun],
        to container: inout UnkeyedEncodingContainer
    ) throws
    {
        for run in runs
        {
            try encodeRun(run, to: container.superEncoder())
        }
    }

    static func encodeRun(
        _ run: SemanticRun,
        to encoder: Encoder
    ) throws
    {
        var container = encoder.container(
            keyedBy: SemanticTableRecordCodingKey.self
        )
        try container.encode(run.text, forKey: key("text"))
        try container.encode(
            run.traits.sorted
            {
                $0.rawValue < $1.rawValue
            }.map(\.rawValue),
            forKey: key("traits")
        )

        guard case let .scoped(scoped) = run
        else
        {
            return
        }
        switch scoped.scopes
        {
        case let .link(link):
            try container.encode(link.value, forKey: key("link"))
        case let .language(language):
            try container.encode(
                language.value,
                forKey: key("language")
            )
        case let .linkAndLanguage(link, language):
            try container.encode(link.value, forKey: key("link"))
            try container.encode(
                language.value,
                forKey: key("language")
            )
        }
    }
}
