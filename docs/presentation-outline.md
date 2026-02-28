# Automating the Boring Parts of Astrophotography

Presentation outline for astrophotography group.

---

## Slide 1: Title

- **Automating the Boring Parts of Astrophotography**
- Your name / date

*Intent: Set the tone — this is about the tedium between capture and processing, not the fun parts.*

---

## Slide 2: The Problem

- A clear night gives you hundreds of files
- Lights, darks, flats, bias — scattered across directories
- Quality varies frame to frame
- Matching calibration to lights is manual and error-prone
- You want to be processing, not organizing

*Intent: Resonate with the audience. Everyone has felt this pain. Don't belabor it — they know.*

---

## Slide 3: What If It Just... Worked?

- Capture with NINA
- Run a few commands
- Bad frames rejected, calibration matched, files organized
- Ready to process

*Intent: Paint the vision before explaining the how. Quick aspirational slide.*

---

## Slide 4: The Pipeline at a Glance

- Visual: simplified flow diagram
  - Capture → Organize → Cull → Calibrate → Match → Process
- Each step is a standalone tool
- Use one, some, or all

*Intent: Show the full picture before diving in. Emphasize modularity — adopt what you want.*

---

## Slide 5: Directory Structure

- Visual: example directory tree
  ```
  Data/
    Optic+Camera/
      10_Blink/     ← review
      20_Data/      ← calibrated, collecting
      30_Master/    ← integration
      40_Process/   ← PixInsight
      50_Bake/      ← final review
      60_Done/      ← archive
  ```
- Numbered stages = natural progression
- Organized by equipment, target, date, filter

*Intent: Show the organizational philosophy. The numbered stages are immediately intuitive.*

---

## Slide 6: Preserve What NINA Knows

- **ap-preserve-header**
- NINA encodes metadata in file paths (camera, filter, temp...)
- Moving files loses that context
- This tool writes path metadata into FITS headers — before anything moves
- Idempotent, safe to re-run

*Intent: Explain why this step exists. It's the subtle foundational step most people skip and regret.*

---

## Slide 7: Organize the Chaos

- **ap-move-raw-light-to-blink**
- Reads FITS headers → organizes by optic, camera, target, date, filter
- Raw dump → structured workflow directories
- Creates `accept/` folders for manual review

*Intent: The first "satisfying" tool — instant order from chaos.*

---

## Slide 8: Cull the Junk

- **ap-cull-light**
- Reads HFR (focus quality) and RMS (guiding error) from headers
- Rejects frames exceeding thresholds
- Batch processing — auto-accept if rejection % is low
- Bad seeing? Clouds rolled in? Gone.

*Intent: Quality control without opening every frame. Audience will appreciate the time savings.*

---

## Slide 9: Master Calibration Frames

- **ap-create-master**
- Discovers and groups calibration frames automatically
  - Bias: camera, temp, gain, offset
  - Dark: + exposure
  - Flat: + date, filter
- Drives PixInsight for integration
- Calibrates flats with bias/dark masters

*Intent: The heavy-lifting step. Emphasize the automatic grouping — that's the magic.*

---

## Slide 10: The Calibration Library

- **ap-move-master-to-library**
- Masters organized into a reusable library
  ```
  Library/
    MASTER BIAS/Camera/...
    MASTER DARK/Camera/...
    MASTER FLAT/Camera/Optic/Date/...
  ```
- Bias and darks persist across sessions (cooled cameras)
- Flats organized by date — take new ones as needed

*Intent: Introduce the library concept. Darks library is a key workflow for cooled cameras.*

---

## Slide 11: Matching Calibration to Lights

- **ap-copy-master-to-blink**
- Searches library for calibration matching each light's metadata
- Copies darks, flats, bias into the right place
- Matching by camera, temp, gain, offset, filter, exposure...
- No more hunting through folders

*Intent: This is where the automation really pays off. The matching logic is the core value proposition.*

---

## Slide 12: Ready to Process

- **ap-move-light-to-data**
- Only moves lights when ALL calibration is present
- Incomplete targets stay behind — clear signal of what's missing
- Atomic moves — no half-done state

*Intent: The gatekeeper. Nothing moves forward until it's complete. This prevents processing mistakes.*

---

## Slide 13: What It Looks Like in Practice

- Transition to live demo
- Real data, real commands
- Walk through a session end-to-end

*Intent: Bridge slide before the demo. Keep it short — just set expectations.*

---

## Slide 14: Wrap-Up (post-demo)

- Open source — Python, install from GitHub
- Modular — use what you need
- Metadata-driven — it reads your FITS headers, no config files
- Works with NINA + PixInsight

*Intent: Practical takeaway. How do they get it, what do they need.*

---

## Slide 15: Questions

- Link to GitHub repos
- Your contact info

*Intent: Standard close.*

---

## Notes for Presenter

- Demo plan: have a set of raw files ready, run through the pipeline live
- Good demo targets: ap-move-raw-light-to-blink (visual payoff), ap-cull-light (interactive), ap-copy-master-to-blink (matching logic)
- Consider showing a `--dryrun` first, then the real run
- The directory tree before/after is very effective visually
