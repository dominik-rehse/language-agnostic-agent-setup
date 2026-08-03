# Documentation rules

These cover technical documentation. Marketing copy, blog posts, and release announcements are a different genre — these rules don't apply there.

- Put all docs in `docs/`.
- Make the docs DRY: refer instead of repeating — within a document as much as between documents (e.g. no summary section recapping the document).
- Don't use promotional language.
- No redundant content such as `README.md` or `getting-started.md`.
- Avoid excessive bold; prefer italics for emphasis.
- In headlines or terminology, capitalize only the first letter.
- Don't write Markdown tables whose cells are paragraphs. Pipe-table rows must live on one physical line, so prose-heavy cells produce unreadable source. Prefer a definition list, a bulleted sublist with a bold term, or short cells with the prose moved into paragraphs below the table.
