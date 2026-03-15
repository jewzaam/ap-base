# Diagram Color Legend

Standard color definitions for mermaid diagrams across all documentation.

## Core Colors

Used across all pipeline diagrams for step types.

| Color | Style Name | Fill | Stroke | Meaning |
|-------|-----------|------|--------|---------|
| Blue | `processStyle` | `#e1f5ff` | `#0066cc` | Automated step |
| Orange | `manualStyle` | `#fff4e6` | `#ff9800` | Manual step |

```
classDef processStyle fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
classDef manualStyle fill:#fff4e6,stroke:#ff9800,stroke-width:2px
```

## Data Stage Colors

Each stage has a consistent color across all diagrams. Colors flow warm to cool.

| Color | Style Name | Fill | Stroke | Stage |
|-------|-----------|------|--------|-------|
| Taupe | `rawStyle` | `#bcaaa4` | `#795548` | Raw Capture |
| Orange | `blinkStyle` | `#ffcc80` | `#ff9800` | 10_Blink |
| Yellow | `dataStage` | `#fff176` | `#f9a825` | 20_Data |
| Cyan | `masterStyle` | `#80deea` | `#00acc1` | 30_Master |
| Blue | `processStage` | `#90caf9` | `#1565c0` | 40_Process |
| Purple | `bakeStyle` | `#ce93d8` | `#ab47bc` | 50_Bake |
| Green | `doneStyle` | `#a5d6a7` | `#4caf50` | 60_Done |

```
classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
classDef blinkStyle fill:#ffcc80,stroke:#ff9800,stroke-width:2px,color:#000
classDef dataStage fill:#fff176,stroke:#f9a825,stroke-width:2px,color:#000
classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000
classDef processStage fill:#90caf9,stroke:#1565c0,stroke-width:2px,color:#000
classDef bakeStyle fill:#ce93d8,stroke:#ab47bc,stroke-width:2px,color:#000
classDef doneStyle fill:#a5d6a7,stroke:#4caf50,stroke-width:2px,color:#000
```

## Usage

```mermaid
flowchart LR
    A[Input Data] --> B[Automated Step] --> C[Manual Step] --> D[Goal]

    classDef rawStyle fill:#bcaaa4,stroke:#795548,stroke-width:2px,color:#000
    classDef processStyle fill:#e1f5ff,stroke:#0066cc,stroke-width:2px
    classDef manualStyle fill:#fff4e6,stroke:#ff9800,stroke-width:2px
    classDef masterStyle fill:#80deea,stroke:#00acc1,stroke-width:2px,color:#000

    class A rawStyle
    class B processStyle
    class C manualStyle
    class D masterStyle
```
