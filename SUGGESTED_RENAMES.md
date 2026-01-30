# Suggested Project Renames

## Overview

This document analyzes naming conventions for the astrophotography pipeline tools and proposes renames that better reflect data flow using consistent noun/verb patterns.

## Naming Philosophy

### Current Pattern
The current naming uses generic verbs like "move" without clearly indicating the source/destination:
- `ap-move-lights` - Move lights... where?
- `ap-move-calibration` - Move calibration... from/to what?

### Proposed Pattern
Use the pattern: `ap-{qualifier}-{noun}-to-{destination}` or `ap-{verb}-{noun}`

Key terms:
- **raw** - Unprocessed frames from capture
- **master** - Integrated/stacked calibration frames
- **library** - Organized calibration frame storage
- **blink** - The 10_Blink QC stage where lights are reviewed

## Data Flow Diagram

```
                                    ┌─────────────────────────────────────────┐
                                    │           CALIBRATION PATH              │
                                    │                                         │
    ┌──────────────┐                │    ┌──────────────┐    ┌────────────┐  │
    │  Raw Bias/   │────────────────┼───►│ ap-master-   │───►│  Masters   │  │
    │  Dark/Flat   │                │    │ calibration  │    │  (output)  │  │
    └──────────────┘                │    └──────────────┘    └─────┬──────┘  │
                                    │                              │         │
                                    │                              ▼         │
                                    │                     ┌────────────────┐ │
                                    │                     │ ap-master-to-  │ │
                                    │                     │ library        │ │
                                    │                     └───────┬────────┘ │
                                    │                             │          │
                                    │                             ▼          │
                                    │                     ┌────────────────┐ │
                                    │                     │  Calibration   │ │
                                    │                     │    Library     │ │
                                    │                     └───────┬────────┘ │
                                    │                             │          │
                                    └─────────────────────────────┼──────────┘
                                                                  │
    ┌─────────────────────────────────────────────────────────────┼──────────┐
    │                         LIGHT PATH                          │          │
    │                                                             │          │
    │   ┌──────────────┐    ┌─────────────────┐    ┌─────────────▼────────┐ │
    │   │  Raw Lights  │───►│ ap-raw-lights-  │───►│      10_Blink        │ │
    │   │  (capture)   │    │ to-blink        │    │                      │ │
    │   └──────────────┘    └─────────────────┘    │  ┌────────────────┐  │ │
    │                                              │  │ ap-master-to-  │  │ │
    │   ┌──────────────┐    ┌─────────────────┐   │  │ blink          │◄─┼─┘
    │   │   Reject     │◄───│  ap-cull-lights │◄──┤  └────────────────┘  │
    │   │  Directory   │    └─────────────────┘   │                      │
    │   └──────────────┘                          │  ap-fits-headers     │
    │                                              │  (metadata)         │
    │                                              └──────────┬──────────┘
    │                                                         │
    │                                                         ▼
    │                                              ┌──────────────────────┐
    │                                              │  20_Data → 60_Done   │
    │                                              │  (manual workflow)   │
    │                                              └──────────────────────┘
    └─────────────────────────────────────────────────────────────────────────┘
```

## Proposed Renames

### Definite Renames

| Current Name | Proposed Name | Rationale |
|--------------|---------------|-----------|
| `ap-move-lights` | `ap-raw-lights-to-blink` | Clearly states: raw light frames → blink stage |
| `ap-move-calibration` | `ap-master-to-library` | Clearly states: master frames → calibration library |

### New Projects Needed

| Project Name | Purpose |
|--------------|---------|
| `ap-master-to-blink` | Copy matching calibration masters from library into blink directory for a target |
| `ap-library-to-blink` | Alternative name - "library" emphasizes the source is the organized library |

### Projects to Keep As-Is

| Current Name | Rationale |
|--------------|-----------|
| `ap-common` | Generic utility library, not tied to data flow |
| `ap-cull-lights` | "Cull" is a clear, specific verb describing the action |
| `ap-fits-headers` | Describes what it operates on (FITS headers) |
| `ap-master-calibration` | Describes what it creates (master calibration frames) |

### Alternative Considerations

#### ap-cull-lights
Could become `ap-lights-to-reject` to follow the "to" pattern, but:
- "cull" is a well-understood term in photography/astrophotography
- The action is more about evaluating/filtering than moving
- **Recommendation**: Keep as `ap-cull-lights`

#### ap-fits-headers
Could become `ap-path-to-headers` to describe the action, but:
- Current name describes what it modifies
- The "path to headers" action is implicit
- **Recommendation**: Keep as `ap-fits-headers`

#### ap-master-calibration
Could become:
- `ap-raw-calibration-to-master` - follows pattern but very long
- `ap-integrate-calibration` - describes the PixInsight action
- `ap-create-masters` - simple and clear
- **Recommendation**: Keep as `ap-master-calibration` (creates master calibration frames)

## Complete Naming Scheme

### Final Recommendations

```
CURRENT                    →    PROPOSED
─────────────────────────────────────────────────
ap-common                       ap-common (no change)
ap-move-lights             →    ap-raw-lights-to-blink
ap-cull-lights                  ap-cull-lights (no change)
ap-fits-headers                 ap-fits-headers (no change)
ap-master-calibration           ap-master-calibration (no change)
ap-move-calibration        →    ap-master-to-library
(new)                      →    ap-master-to-blink
(future?)                  →    ap-library-match (find matching masters)
```

## Workflow with New Names

```bash
#!/bin/bash
# Complete workflow with proposed naming

# Stage 1: Organize raw lights into blink directory
python -m ap_raw_lights_to_blink /capture/tonight /data

# Stage 2: Cull poor quality frames
python -m ap_cull_lights /data/*/10_Blink /reject --max-hfr 2.5 --max-rms 2.0

# Stage 3: Preserve path metadata in headers
python -m ap_fits_headers /data --include CAMERA OPTIC FILTER

# Stage 4: Create master calibration frames
python -m ap_master_calibration /calibration/raw /calibration/output \
    --pixinsight-binary "/path/to/PixInsight"

# Stage 5: Organize masters into library
python -m ap_master_to_library /calibration/output/master /calibration/library

# Stage 6: Copy matching masters into blink directory for calibration
python -m ap_master_to_blink /calibration/library /data/*/10_Blink/M42
```

## Migration Impact

### Repository Renames Required
1. `jewzaam/ap-move-lights` → `jewzaam/ap-raw-lights-to-blink`
2. `jewzaam/ap-move-calibration` → `jewzaam/ap-master-to-library`

### Package/Module Renames
- `ap_move_lights` → `ap_raw_lights_to_blink`
- `ap_move_calibration` → `ap_master_to_library`

### Documentation Updates
- All workflow docs reference old names
- README badges and links
- Installation instructions

### Git Submodule Updates (ap-base)
- Update `.gitmodules` with new repository names
- Update `patches/` directory names
- Update `Makefile` targets

## Implementation Order

1. **Create** `ap-master-to-blink` (new functionality)
2. **Rename** `ap-move-calibration` → `ap-master-to-library`
3. **Rename** `ap-move-lights` → `ap-raw-lights-to-blink`
4. **Update** ap-base submodules and documentation

## Open Questions

1. Should `ap-master-to-blink` copy just the masters, or also set up a PixInsight project?
2. Is "blink" specific enough, or should we use a more generic term like "workspace"?
3. Should there be an `ap-lights-to-data` tool to automate moving accepted frames from 10_Blink → 20_Data?
