# ap-base TODO

## Cross-Project Improvements

### Extract Master Frame Matching Logic to ap-common

**Current State:**

Master frame matching logic (finding darks, flats, bias) is currently duplicated across multiple projects:

- `ap-copy-master-to-blink` - matching.py
- `ap-move-master-to-library` - (likely has similar logic)
- `ap-move-light-to-data` - (likely has similar logic)

**Problem:**
The logic to find matching master calibration frames for a given light frame is identical across projects:
- Same matching criteria (camera, gain, offset, settemp, readoutmode, exposure, filter, date)
- Same priority logic for dark matching (exact exposure > shorter exposure + bias)
- Same exact DATE matching for flats
- Only difference is the directory being searched (library vs blink vs other)

**Proposed Solution:**
Extract the matching logic to `ap-common` as reusable functions:

```python
# ap_common/calibration_matching.py

def find_matching_dark(
    search_dir: Path,
    light_metadata: Dict[str, str],
) -> Optional[Dict[str, str]]:
    """
    Find matching dark frame for a light frame.

    Priority:
    1. Exact exposure match
    2. Longest dark exposure < light exposure (requires bias)

    Args:
        search_dir: Directory to search for masters
        light_metadata: Metadata dictionary for light frame

    Returns:
        Metadata dict for matching dark, or None if no match found
    """
    # Implementation from ap-copy-master-to-blink/matching.py
    pass

def find_matching_bias(
    search_dir: Path,
    light_metadata: Dict[str, str],
) -> Optional[Dict[str, str]]:
    """Find matching bias frame for a light frame."""
    # Implementation from ap-copy-master-to-blink/matching.py
    pass

def find_matching_flat(
    search_dir: Path,
    light_metadata: Dict[str, str],
    date_tolerance_days: Optional[int] = None,
) -> Optional[Dict[str, str]]:
    """
    Find matching flat frame for a light frame.

    Args:
        search_dir: Directory to search for masters
        light_metadata: Metadata dictionary for light frame
        date_tolerance_days: If provided, allow flats within ±N days

    Returns:
        Metadata dict for matching flat, or None if no match found
    """
    # Implementation with flexible date matching
    pass

def determine_required_masters(
    search_dir: Path,
    light_metadata: Dict[str, str],
    date_tolerance_days: Optional[int] = None,
) -> Dict[str, Optional[Dict[str, str]]]:
    """
    Determine which master frames are required for a light frame.

    Returns dict with keys:
    - TYPE_MASTER_DARK
    - TYPE_MASTER_BIAS
    - TYPE_MASTER_FLAT
    """
    # Implementation from ap-copy-master-to-blink/matching.py
    pass
```

**Benefits:**
- Single source of truth for matching logic
- Easier to maintain and test
- Consistent behavior across all projects
- Easier to add features like flexible flat date matching

**Implementation Steps:**
1. Move matching.py from ap-copy-master-to-blink to ap-common/calibration_matching.py
2. Update imports in ap-copy-master-to-blink to use ap-common
3. Update ap-move-master-to-library to use ap-common (if applicable)
4. Update ap-move-light-to-data to use ap-common (if applicable)
5. Add comprehensive tests in ap-common
6. Add documentation to ap-common README

---

### Flexible Flat Date Matching

**Current State:**
`ap-copy-master-to-blink` requires exact DATE match for flat frames. If the exact date doesn't exist, no flat is found.

**Problem:**
- Flats from nearby dates may be suitable (especially for narrowband filters)
- User may have flats from a few days before/after the light frames
- Current implementation is too strict and may reject usable flats

**Proposed Solution:**
Add flexible date matching with configurable tolerance:

1. **Exact match first (current behavior):**
   - DATE must match exactly
   - Example: Light from 2024-01-15 requires flat from 2024-01-15

2. **Older flats (within tolerance):**
   - Scan DATE subdirectories < light frame date
   - Pick the most recent flat within tolerance
   - Example: Light from 2024-01-15, tolerance=7 days
     - Try 2024-01-14, 2024-01-13, ..., 2024-01-08
     - Use first match found

3. **Newer flats (within tolerance):**
   - Scan DATE subdirectories > light frame date
   - Pick the oldest flat within tolerance
   - Example: Light from 2024-01-15, tolerance=7 days
     - Try 2024-01-16, 2024-01-17, ..., 2024-01-22
     - Use first match found

4. **Configuration options:**
   - `--flat-date-tolerance <days>` CLI argument
   - Default: 0 (exact match only)
   - Example: `--flat-date-tolerance 7` allows ±7 days

**Implementation Details:**
```python
def find_matching_flat(
    library_dir: Path,
    light_metadata: Dict[str, str],
    date_tolerance_days: Optional[int] = None,
) -> Optional[Dict[str, str]]:
    """
    Find matching flat frame for a light frame.

    Priority:
    1. Exact date match
    2. If tolerance specified:
       a. Older flats within tolerance (most recent first)
       b. Newer flats within tolerance (oldest first)
    """
    light_date = parse_date(light_metadata.get(KEYWORD_DATE))

    # Try exact match first
    exact_match = find_flat_for_date(library_dir, light_metadata, light_date)
    if exact_match:
        return exact_match

    if date_tolerance_days is None or date_tolerance_days == 0:
        return None

    # Try older dates (most recent first)
    for days_back in range(1, date_tolerance_days + 1):
        older_date = light_date - timedelta(days=days_back)
        match = find_flat_for_date(library_dir, light_metadata, older_date)
        if match:
            logger.warning(
                f"Using flat from {older_date} for light from {light_date} "
                f"({days_back} days older)"
            )
            return match

    # Try newer dates (oldest first)
    for days_forward in range(1, date_tolerance_days + 1):
        newer_date = light_date + timedelta(days=days_forward)
        match = find_flat_for_date(library_dir, light_metadata, newer_date)
        if match:
            logger.warning(
                f"Using flat from {newer_date} for light from {light_date} "
                f"({days_forward} days newer)"
            )
            return match

    return None
```

**User Interface:**
- Add `--flat-date-tolerance` argument to CLI
- Log warnings when using non-exact date matches
- Show in summary report which flats were from different dates

**Testing:**
- Test exact match (current behavior)
- Test older flat within tolerance
- Test newer flat within tolerance
- Test tolerance=0 (exact match only)
- Test no match within tolerance

**Documentation:**
- Update README with --flat-date-tolerance option
- Add examples showing when to use tolerance
- Document risks of using flats from different dates
- Add guidance for narrowband vs broadband (narrowband more tolerant)

**Projects to Update:**
- ap-copy-master-to-blink (first)
- ap-move-light-to-data (if applicable)
- Any other projects that match flats

---

## Notes

- Keep TODO items updated as they are implemented
- Mark completed items with strikethrough (~~item~~) and move to bottom
- Add new TODO items as they are identified
- Cross-reference GitHub issues where applicable
