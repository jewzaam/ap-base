# ap-* Naming Conventions

Naming patterns specific to the astrophotography pipeline (`ap-*`) projects.

For general repo/package/module/variable naming rules, see [Naming](https://github.com/jewzaam/standards/blob/main/common/naming.md) in the upstream standards.

## Naming Pattern

All tools follow the pattern:

```
ap-{verb}-{qualifier?}-{noun}-to-{destination?}
```

| Component | Required | Description |
|-----------|----------|-------------|
| `verb` | Yes | Action the tool performs |
| `qualifier` | No | Modifier for the noun (e.g., `raw`) |
| `noun` | Yes | What the tool operates on (always singular) |
| `destination` | No | Where data moves to |

## Taxonomy

### Verbs

| Verb | Action |
|------|--------|
| `copy` | Duplicate to a destination (source retained) |
| `create` | Generate (masters from raw frames) |
| `cull` | Filter/reject based on quality metrics |
| `preserve` | Save metadata (e.g., path → header) |
| `move` | Transfer from one location to another |
| `delete` | Remove files/frames |
| `discover` | Infer missing metadata and record it (e.g., target name from RA/DEC) |
| `empty` | Clean up (e.g., remove empty directories) |

### Nouns

| Noun | Definition |
|------|------------|
| `light` | A light frame (science image of a target) |
| `master` | An integrated calibration frame (bias, dark, or flat) |
| `header` | Metadata stored in the file |
| `targetname` | Target name metadata (matches `NORMALIZED_HEADER_TARGETNAME`) |
| `directory` | A filesystem directory |

### Qualifiers

| Qualifier | Meaning |
|-----------|---------|
| `raw` | Unprocessed, directly from capture |

### Destinations

| Destination | Directory | Purpose |
|-------------|-----------|---------|
| `blink` | `10_Blink/` | Initial QC stage, visual review |
| `data` | `20_Data/` | Accepted frames, collecting more |
| `library` | `Calibration/Library/` | Organized master frame storage |

## Project Names

| Project | Pattern | Purpose |
|---------|---------|---------|
| `ap-move-raw-light-to-blink` | verb-qualifier-noun-to-dest | Move raw lights from capture → blink |
| `ap-cull-light` | verb-noun | Cull (reject) poor quality lights |
| `ap-preserve-header` | verb-noun | Preserve path metadata into header |
| `ap-create-master` | verb-noun | Create masters from raw calibration |
| `ap-move-master-to-library` | verb-noun-to-dest | Move masters → library |
| `ap-copy-master-to-blink` | verb-noun-to-dest | Copy matching masters from library → blink |
| `ap-move-light-to-data` | verb-noun-to-dest | Move accepted lights from blink → data |
| `ap-discover-targetname` | verb-noun | Assign target name to lights by RA/DEC |
| `ap-empty-directory` | verb-noun | Delete directory contents and prune empty subdirectories |
| `ap-common` | — | Shared utilities (exception to pattern) |

## Guidelines

1. **Start with a verb** - Every tool name begins with an action
2. **Use singular nouns** - `light` not `lights`, `header` not `headers`
3. **Include destination when moving** - Use `-to-{dest}` suffix for tools that relocate data
4. **Use qualifiers sparingly** - Only when distinguishing between variants (e.g., `raw` vs calibrated)
