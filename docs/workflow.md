# groundup Workflow

Full session flow from "I want to build X" to merged PR.

## High-Level Flow

```mermaid
flowchart TD
    A([Engineer: I want to build X]) --> B[session-start hook\nusing-groundup bootstrap loaded]
    B --> C[EXPLORE\nRead codebase before saying anything]
    C --> D[GRILL\nRelentless questions until:\napproach + files + edge cases agreed]
    D --> E[FLOW MAP\nEngineer draws the flow\nClaude interrogates it]
    E --> F{Patterns check\nDoes this flow involve\na known pattern?}
    F -->|Yes| G[Teach the pattern\nEngineer applies it\nto the design]
    F -->|No| H
    G --> H[Agree on diagram\n+ ordered file list]
    H --> I[PER-FILE LOOP]
    I --> Z([Final review + PR])

    style A fill:#f9f9f9
    style Z fill:#f9f9f9
    style I fill:#e8f4e8
```

---

## Per-File Loop

```mermaid
flowchart TD
    A([Start: next file in dependency order]) --> B{Patterns check\nKnown best practice\nfor this function?}
    B -->|Yes| C[Claude names the pattern\nexplains tradeoff\nasked if engineer knows it]
    B -->|No| D
    C --> D[PSEUDOCODE\nClaude writes problem-domain\npseudocode into the file]
    D --> E[IMPLEMENT\nEngineer translates pseudocode to code]
    E --> F{Stuck?}
    F -->|Yes| G[SYSTEMATIC DEBUGGING\nReproduce → Hypothesise\nTest hypothesis → Verify]
    G --> E
    F -->|No| H[TESTS\nEngineer writes tests\nAll Edges: header cases required]
    H --> I[CODE REVIEW\nPer-file review\nGate: tests must exist]
    I --> J{Review passed?}
    J -->|Changes needed| E
    J -->|Passed| K[GROWTH REVIEW\nOne session-specific\nreflection question\nClaude does not give the answer]
    K --> L{More files?}
    L -->|Yes| A
    L -->|No| M([Final review + PR])

    style A fill:#f9f9f9
    style M fill:#f9f9f9
```

---

## Systematic Debugging Flow

```mermaid
flowchart TD
    A([Bug reported or\nspeculative change detected]) --> B[PHASE 1: OBSERVE\nReproduce the bug\nCollect evidence: error, stack trace, logs]
    B --> C{Reproducible?}
    C -->|No| B
    C -->|Yes| D[PHASE 2: HYPOTHESISE\nEngineer states:\nThe bug is caused by X\nbecause Y, evidence Z]
    D --> E[PHASE 3: TEST HYPOTHESIS\nInstrument at boundaries\nConfirm or rule out]
    E --> F{Hypothesis confirmed?}
    F -->|Ruled out| D
    F -->|Confirmed| G[Write targeted fix\nfor the root cause]
    G --> H[PHASE 4: VERIFY\nFix works\nNeighbours still pass]
    H --> I{All passing?}
    I -->|No| D
    I -->|Yes| J[Document root cause\nas comment above fix]
    J --> K([Return to implementation])

    style A fill:#f9f9f9
    style K fill:#f9f9f9
```

---

## Hybrid Trigger Protocol

When a gate is skipped, Claude names it and the risk — it does not hard-block.

```mermaid
flowchart LR
    A[Gate skipped] --> B[Claude names the skip\nand the risk]
    B --> C[Engineer decides\nwhether to proceed]
    C -->|Proceeds| D[Skip is a named\nlearning moment]
    C -->|Invokes skill| E[Process resumes\nfrom correct gate]
```

| Gate skipped | What Claude says |
|---|---|
| Grill | "We haven't grilled this yet. Proceeding, but we're designing without understanding the edge cases — that risk is now yours." |
| Flow map | "No agreed flow yet. Proceeding, but pseudocode without a flow tends to miss transaction boundaries." |
| Pseudocode | "No pseudocode exists for this file. Proceeding, but implementation without pseudocode skips the planning that prevents rewrites." |
| Tests | "Code review won't start until tests exist. Write them first." |

---

## Patterns Teaching — When It Fires

```mermaid
flowchart LR
    A[Flow Map discussion] -->|Before diagram is agreed| B[Patterns check:\ndoes any step map to\na known pattern?]
    C[Before pseudocode\nfor each file] -->|Before writing| D[Patterns check:\ndoes this function have\na known best practice?]
    B --> E[Teach: name it,\nexplain when it applies,\nshow the tradeoff,\nask if engineer knows it]
    D --> E
    E --> F[Engineer applies it\nClaude does not\nrewrite their code]
```

---

## GSD Integration (optional)

If GSD is installed, the final PR step uses `/gsd-ship` for multi-agent code review and PR creation. groundup works without GSD — use your normal PR process if it isn't installed.
