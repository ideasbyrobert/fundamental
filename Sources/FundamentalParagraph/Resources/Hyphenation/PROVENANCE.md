# Language data provenance

These resources adapt the English and Russian pattern files in tex-hyphen at
commit 5684c0f51c0b81133db2efbe60a408b4155a3ff5. All original pattern entries,
exceptions, copyright notices and permission notices are preserved. The only
changes are the resource filenames and the five-line Fundamental notice placed
before the original bytes. No linguistic correction is made in this import.

manifest.json records each original and distributed SHA-256, upstream filename,
locale, selected license and left/right minimum. Tools/PatternResourceImport.swift
and PatternImportDefinition.swift reproduce these files from the hash-checked
originals. Each resource is verified against its distributed digest before use.

## American English

en_US.patterns derives from hyph-en-us.tex, copyright 1990, 2004, 2005 Gerard
D.C. Kuiken. The complete copying/distribution permission and notices remain at
the start of the original file. It includes the original Knuth patterns and
exceptions described there. LicenseRef-Kuiken-notice in the manifest identifies
that retained permission; it does not refer to a new project license.

The file's known democrat issue remains part of the evidence. The imported
data is not represented as linguistically perfect.

## British English

en_GB.patterns derives from hyph-en-gb.tex, copyright 1992, 1996, 2005, 2016
Dominik Wujastyk and Graham Toal. Its full MIT permission and warranty notice
remain in the resource. The original Oxford word list is not included; the
upstream header distinguishes it from these distributable patterns.

## Russian

ru_RU.patterns derives from hyph-ru.tex, copyright 1999-2003 Alexander I.
Lebedev. The original notice permits LPPL 1.2 or later. This identified
adaptation is distributed under LPPL 1.3c; the complete, unmodified license is
included as LPPL-1.3c.txt. Its filename and added notice identify it separately
from the upstream component. This file records the complete change history.

The license is copied byte for byte, including upstream whitespace. The local
.gitattributes preserves imported resource/license bytes across checkouts and
exempts only that unmodified license from Git's whitespace diagnostics.

The upstream authors and maintainers do not provide maintenance or support for
this adaptation. These data-specific terms do not assign a new license to the
unrelated Swift engine or to other files in Fundamental or its Etudes.

## Complete sources

- [Complete tex-hyphen source archive at the pinned revision](https://github.com/hyphenation/tex-hyphen/archive/5684c0f51c0b81133db2efbe60a408b4155a3ff5.tar.gz).
- [Pinned American source](https://github.com/hyphenation/tex-hyphen/blob/5684c0f51c0b81133db2efbe60a408b4155a3ff5/hyph-utf8/tex/generic/hyph-utf8/patterns/tex/hyph-en-us.tex).
- [Pinned British source](https://github.com/hyphenation/tex-hyphen/blob/5684c0f51c0b81133db2efbe60a408b4155a3ff5/hyph-utf8/tex/generic/hyph-utf8/patterns/tex/hyph-en-gb.tex).
- [Pinned Russian source](https://github.com/hyphenation/tex-hyphen/blob/5684c0f51c0b81133db2efbe60a408b4155a3ff5/hyph-utf8/tex/generic/hyph-utf8/patterns/tex/hyph-ru.tex).
- [Complete original ruhyphen package and documentation](https://ctan.org/pkg/ruhyphen?lang=en).
- [Original ruhyphen package archive](https://mirrors.ctan.org/language/hyphenation/ruhyphen.zip).

## Change history

- Import the three pinned resources without changing their pattern/exception
  content. Add the identifying notice, rename resources, and preserve original
  hashes alongside distributed hashes. Select LPPL 1.3c for the Russian
  adaptation and retain the complete license text.
