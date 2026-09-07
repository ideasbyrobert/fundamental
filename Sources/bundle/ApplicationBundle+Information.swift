import Foundation

extension ApplicationBundle
{
    var information: [String: Any]
    {
        let type = "com.ideasbyrobert.fundamental-document"
        return [
            "CFBundlePackageType": "APPL",
            "CFBundleExecutable": "Fundamental",
            "CFBundleIdentifier": "com.ideasbyrobert.Fundamental.Development",
            "CFBundleName": "Fundamental",
            "CFBundleDisplayName": "Fundamental",
            "CFBundleShortVersionString": "0.1",
            "CFBundleVersion": version,
            "LSMinimumSystemVersion": "26.0",
            "NSPrincipalClass": "NSApplication",
            "NSHighResolutionCapable": true,
            "UTExportedTypeDeclarations": [[
                "UTTypeIdentifier": type,
                "UTTypeConformsTo": ["public.json"],
                "UTTypeDescription": "Fundamental document",
                "UTTypeTagSpecification": [
                    "public.filename-extension": ["fun", "fundamental"],
                    "public.mime-type": [
                        "application/vnd.fundamental.document+json"
                    ]
                ]
            ]],
            "CFBundleDocumentTypes": [[
                "CFBundleTypeName": "Fundamental document",
                "LSItemContentTypes": [type],
                "CFBundleTypeRole": "Editor",
                "LSHandlerRank": "Alternate"
            ]]
        ]
    }
}
