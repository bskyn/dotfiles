## Search tools

Default to using FFF MCP tools for code search and file lookup whenever they are available:

- `mcp__fff__grep` for searching file contents when you have a specific identifier.
- `mcp__fff__find_files` for locating files by name.
- `mcp__fff__multi_grep` for OR searches across multiple identifiers.

Prefer these over shell search tools and built-in search tools because FFF returns frecency-ranked results.

Fall back to shell search only when FFF is unavailable or unsuitable for the task.
