# Presentation Diagrams

Drill-down diagrams for presenting the astrophotography pipeline. Each level adds detail, building from the goal to the full automated workflow.

See [legend.md](legend.md) for color standards.

---

## Data Stages

How data progresses through the workflow. Each numbered stage represents a state in the pipeline. Colors flow from warm (early) to cool (late) to green (done).

**Left-Right**

```mermaid
flowchart LR
    RAW[Raw Capture] --> BLINK[10_Blink]
    BLINK --> DATA[20_Data]
    DATA --> MASTER[30_Master]
    MASTER --> PROCESS[40_Process]
    PROCESS --> BAKE[50_Bake]
    BAKE --> DONE[60_Done]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef blinkStyle fill:#ffcc80,stroke:#ff9800,stroke-width:2px,color:#000
    classDef dataStage fill:#fff176,stroke:#f9a825,stroke-width:2px,color:#000
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000
    classDef processStage fill:#90caf9,stroke:#1565c0,stroke-width:2px,color:#000
    classDef bakeStyle fill:#ce93d8,stroke:#ab47bc,stroke-width:2px,color:#000
    classDef doneStyle fill:#a5d6a7,stroke:#4caf50,stroke-width:2px,color:#000

    class RAW rawStyle
    class BLINK blinkStyle
    class DATA dataStage
    class MASTER masterStyle
    class PROCESS processStage
    class BAKE bakeStyle
    class DONE doneStyle
```

**Top-Down**

```mermaid
flowchart TB
    RAW[Raw Capture] --> BLINK[10_Blink]
    BLINK --> DATA[20_Data]
    DATA --> MASTER[30_Master]
    MASTER --> PROCESS[40_Process]
    PROCESS --> BAKE[50_Bake]
    BAKE --> DONE[60_Done]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef blinkStyle fill:#ffcc80,stroke:#ff9800,stroke-width:2px,color:#000
    classDef dataStage fill:#fff176,stroke:#f9a825,stroke-width:2px,color:#000
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000
    classDef processStage fill:#90caf9,stroke:#1565c0,stroke-width:2px,color:#000
    classDef bakeStyle fill:#ce93d8,stroke:#ab47bc,stroke-width:2px,color:#000
    classDef doneStyle fill:#a5d6a7,stroke:#4caf50,stroke-width:2px,color:#000

    class RAW rawStyle
    class BLINK blinkStyle
    class DATA dataStage
    class MASTER masterStyle
    class PROCESS processStage
    class BAKE bakeStyle
    class DONE doneStyle
```

| Stage | State |
|-------|-------|
| Raw Capture | Unprocessed files from camera |
| 10_Blink | Initial review and quality control |
| 20_Data | Calibration matched, collecting data |
| 30_Master | Creating master lights |
| 40_Process | Active processing in PixInsight |
| 50_Bake | Final review before publishing |
| 60_Done | Published, ready for archive |

---

## Level 1: The Goal

What are we trying to achieve?

**Top-Down**

```mermaid
flowchart TB
    RAW[Raw Captured Data] --> READY[Ready to Create Master Lights]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class RAW rawStyle
    class READY masterStyle
```

**Left-Right**

```mermaid
flowchart LR
    RAW[Raw Captured Data] --> READY[Ready to Create Master Lights]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class RAW rawStyle
    class READY masterStyle
```

---

## Level 2: Functional Steps

What needs to happen to get there? Two parallel paths converge.

**Top-Down**

```mermaid
flowchart TB
    subgraph Lights["Light Frames"]
        direction TB
        L_ORG[Organize Lights] --> L_QC[Quality Control]
    end

    subgraph Calibration["Calibration Frames"]
        direction TB
        C_INT[Integrate Calibration] --> C_LIB[Organize Calibration]
    end

    RAW[Raw Captured Data] --> L_ORG
    RAW --> C_INT

    L_QC --> MATCH[Match Calibration to Lights]
    C_LIB --> MATCH
    MATCH --> READY[Ready to Create Master Lights]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef processStyle fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class RAW rawStyle
    class L_ORG,L_QC,C_INT,C_LIB,MATCH processStyle
    class READY masterStyle
```

**Left-Right**

```mermaid
flowchart LR
    subgraph Lights["Light Frames"]
        direction LR
        L_ORG[Organize Lights] --> L_QC[Quality Control]
    end

    subgraph Calibration["Calibration Frames"]
        direction LR
        C_INT[Integrate Calibration] --> C_LIB[Organize Calibration]
    end

    RAW[Raw Captured Data] --> L_ORG
    RAW --> C_INT

    L_QC --> MATCH[Match Calibration to Lights]
    C_LIB --> MATCH
    MATCH --> READY[Ready to Create Master Lights]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef processStyle fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class RAW rawStyle
    class L_ORG,L_QC,C_INT,C_LIB,MATCH processStyle
    class READY masterStyle
```

---

## Level 3: Automation Per Step

For each functional step, the tool that automates it. Manual steps highlighted in orange.

**Top-Down**

```mermaid
flowchart TB
    RAW[Raw Captured Data] --> META["Preserve Metadata<br><i>ap-preserve-header</i>"]

    subgraph Lights["Light Frames"]
        direction TB
        L_ORG["Organize Lights<br><i>ap-move-raw-light-to-blink</i>"]
        L_QC["Quality Control<br><i>ap-cull-light</i>"]
        L_REVIEW["Review Frames<br><i>Manual Blink</i>"]
        L_ORG --> L_QC --> L_REVIEW
    end

    subgraph Calibration["Calibration Frames"]
        direction TB
        C_INT["Integrate Calibration<br><i>ap-create-master</i>"]
        C_LIB["Organize Calibration<br><i>ap-move-master-to-library</i>"]
        C_INT --> C_LIB
    end

    META --> L_ORG
    META --> C_INT

    L_REVIEW --> MATCH["Match Calibration to Lights<br><i>ap-copy-master-to-blink</i>"]
    C_LIB --> MATCH
    MATCH --> MOVE["Move Ready Data<br><i>ap-move-light-to-data</i>"]
    MOVE --> READY[Ready to Create Master Lights]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef processStyle fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
    classDef manualStyle fill:#fff4e6,stroke:#ff9800,stroke-width:2px
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class META,L_ORG,L_QC,C_INT,C_LIB,MATCH,MOVE processStyle
    class RAW,L_REVIEW manualStyle
    class READY masterStyle
```

**Left-Right**

```mermaid
flowchart LR
    RAW[Raw Captured Data] --> META["Preserve Metadata<br><i>ap-preserve-header</i>"]

    subgraph Lights["Light Frames"]
        direction LR
        L_ORG["Organize Lights<br><i>ap-move-raw-light-to-blink</i>"]
        L_QC["Quality Control<br><i>ap-cull-light</i>"]
        L_REVIEW["Review Frames<br><i>Manual Blink</i>"]
        L_ORG --> L_QC --> L_REVIEW
    end

    subgraph Calibration["Calibration Frames"]
        direction LR
        C_INT["Integrate Calibration<br><i>ap-create-master</i>"]
        C_LIB["Organize Calibration<br><i>ap-move-master-to-library</i>"]
        C_INT --> C_LIB
    end

    META --> L_ORG
    META --> C_INT

    L_REVIEW --> MATCH["Match Calibration to Lights<br><i>ap-copy-master-to-blink</i>"]
    C_LIB --> MATCH
    MATCH --> MOVE["Move Ready Data<br><i>ap-move-light-to-data</i>"]
    MOVE --> READY[Ready to Create Master Lights]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef processStyle fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
    classDef manualStyle fill:#fff4e6,stroke:#ff9800,stroke-width:2px
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class META,L_ORG,L_QC,C_INT,C_LIB,MATCH,MOVE processStyle
    class RAW,L_REVIEW manualStyle
    class READY masterStyle
```

---

## Level 4: End-to-End with Manual Steps

Full pipeline. Manual steps are orange, automated steps are blue, data is green.

**Top-Down**

```mermaid
flowchart TB
    CAPTURE[Capture] --> RAW[Raw Captured Data]
    RAW --> PH[ap-preserve-header]

    subgraph Lights["Light Frames"]
        direction TB
        MOVE[ap-move-raw-light-to-blink]
        CULL[ap-cull-light]
        BLINK[Blink Review]
        MOVE --> CULL --> BLINK
    end

    subgraph Calibration["Calibration Frames"]
        direction TB
        CREATE[ap-create-master]
        ORGANIZE[ap-move-master-to-library]
        CREATE --> ORGANIZE
    end

    PH --> MOVE
    PH --> CREATE

    BLINK --> COPY[ap-copy-master-to-blink]
    ORGANIZE --> LIBRARY[Calibration Library]
    LIBRARY --> COPY
    COPY --> MOVE_DATA[ap-move-light-to-data]
    MOVE_DATA --> READY[Ready to Create Master Lights]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef processStyle fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
    classDef manualStyle fill:#fff4e6,stroke:#ff9800,stroke-width:2px
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class PH,MOVE,CULL,CREATE,ORGANIZE,COPY,MOVE_DATA processStyle
    class CAPTURE,BLINK manualStyle
    class RAW,LIBRARY rawStyle
    class READY masterStyle
```

**Left-Right**

```mermaid
flowchart LR
    CAPTURE[Capture] --> RAW[Raw Captured Data]
    RAW --> PH[ap-preserve-header]

    subgraph Lights["Light Frames"]
        direction LR
        MOVE[ap-move-raw-light-to-blink]
        CULL[ap-cull-light]
        BLINK[Blink Review]
        MOVE --> CULL --> BLINK
    end

    subgraph Calibration["Calibration Frames"]
        direction LR
        CREATE[ap-create-master]
        ORGANIZE[ap-move-master-to-library]
        CREATE --> ORGANIZE
    end

    PH --> MOVE
    PH --> CREATE

    BLINK --> COPY[ap-copy-master-to-blink]
    ORGANIZE --> LIBRARY[Calibration Library]
    LIBRARY --> COPY
    COPY --> MOVE_DATA[ap-move-light-to-data]
    MOVE_DATA --> READY[Ready to Create Master Lights]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef processStyle fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
    classDef manualStyle fill:#fff4e6,stroke:#ff9800,stroke-width:2px
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class PH,MOVE,CULL,CREATE,ORGANIZE,COPY,MOVE_DATA processStyle
    class CAPTURE,BLINK manualStyle
    class RAW,LIBRARY rawStyle
    class READY masterStyle
```
