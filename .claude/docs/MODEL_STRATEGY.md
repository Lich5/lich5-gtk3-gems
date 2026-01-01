# Model Strategy for Claude Code Sessions

**Created:** 2026-01-01
**Status:** Active
**Context:** Review of session framework effectiveness during GTK3 binary gem POC

---

## Purpose

Define when to use which Claude model based on task characteristics, not mode assignment. This document captures lessons learned from extended debugging/architecture sessions and provides guidance for effective model utilization.

---

## Task Taxonomy

### Type 1: Mechanical Execution
Tasks with clear inputs, known patterns, minimal decision-making.

**Characteristics:**
- Spec is complete and unambiguous
- Pattern exists in codebase to follow
- No investigation required
- No architectural decisions
- Predictable outcome

**Examples:**
- Rename variable across files
- Add boilerplate test following existing pattern
- Update version numbers
- Apply known fix to multiple locations
- Mechanical refactoring (extract method, inline variable)

**Appropriate Model:** Haiku (fast, efficient, cost-effective)

---

### Type 2: Guided Implementation
Tasks with clear goals but requiring some judgment.

**Characteristics:**
- Acceptance criteria defined
- Some pattern matching required
- Minor decisions within established boundaries
- May require reading existing code for context

**Examples:**
- Implement feature from work unit spec
- Write tests for existing functionality
- Add documentation following standards
- Create workflow step following established patterns

**Appropriate Model:** Sonnet or Haiku (depending on complexity)

---

### Type 3: Investigation & Debugging
Tasks requiring deep reasoning, hypothesis formation, iterative exploration.

**Characteristics:**
- Root cause unknown
- Requires reading and correlating multiple sources
- Hypothesis → test → refine cycle
- May uncover unexpected dependencies
- Context retention critical across iterations

**Examples:**
- "Why is the linker failing?"
- "What dependencies does this gem actually need?"
- "Why does this work in MSYS2 but not native Windows?"
- Debugging CI failures with incomplete error messages
- Tracing execution paths through unfamiliar code

**Appropriate Model:** Opus (deep reasoning, context retention)

---

### Type 4: Architecture & Design
Tasks requiring system-level thinking, trade-off analysis, long-term implications.

**Characteristics:**
- Multiple valid approaches
- Trade-offs must be weighed
- Decisions have lasting impact
- Requires understanding constraints and goals
- Often produces documentation (ADRs, specs)

**Examples:**
- Design new repository architecture
- Evaluate build strategies
- Create comprehensive technical specifications
- Define migration paths
- Establish patterns for future work

**Appropriate Model:** Opus (nuanced reasoning, comprehensive output)

---

## Model Capabilities Matrix

| Capability | Haiku | Sonnet | Opus |
|------------|-------|--------|------|
| Speed | Fastest | Fast | Moderate |
| Cost | Lowest | Medium | Highest |
| Pattern following | Excellent | Excellent | Excellent |
| Novel problem solving | Limited | Good | Excellent |
| Context retention (long) | Limited | Good | Excellent |
| Nuanced trade-offs | Limited | Good | Excellent |
| Multi-step reasoning | Basic | Good | Excellent |
| Documentation quality | Good | Very Good | Excellent |
| Debugging complex issues | Poor | Moderate | Excellent |

---

## Mode/Model Alignment Review

### Current Framework Design

| Mode | Specified Model | Intended Use |
|------|-----------------|--------------|
| `/arch` | Sonnet | Planning, design |
| `/analyze` | Sonnet | Investigation |
| `/code` | Haiku | Implementation |
| `/test` | (none) | Validation |
| `/review` | (none) | Quality review |

### Observed Issues

1. **`/code` → Haiku assumes implementation is mechanical**
   - Reality: Implementation often uncovers issues requiring investigation
   - Switching modes mid-task breaks flow
   - Haiku struggles with "why isn't this working?"

2. **Model specs in commands are outdated**
   - Reference old model IDs
   - Don't account for Opus availability

3. **Mode boundaries are artificial for exploratory work**
   - Debugging sessions flow: investigate → implement → test → debug → repeat
   - Forcing mode switches adds friction

### Recommended Alignment

| Mode | Recommended Model | Rationale |
|------|-------------------|-----------|
| `/arch` | Opus | Architecture requires deepest reasoning |
| `/analyze` | Opus | Investigation requires hypothesis/iteration |
| `/code` | **Context-dependent** | See decision tree below |
| `/test` | Sonnet or Haiku | Depends on test complexity |
| `/review` | Sonnet | Balance of speed and insight |

---

## Decision Tree for `/code` Model Selection

```
Is the task clearly specified with known patterns?
├── YES: Is it purely mechanical (rename, boilerplate)?
│   ├── YES → Haiku
│   └── NO: Does it require reading unfamiliar code?
│       ├── YES → Sonnet
│       └── NO → Haiku
└── NO: Does it involve debugging or investigation?
    ├── YES → Opus
    └── NO: Are there architectural implications?
        ├── YES → Opus
        └── NO → Sonnet
```

**Simplified heuristic:** When in doubt, use Opus. The cost difference is negligible compared to rework from insufficient reasoning.

---

## Session Evidence

### GTK3 Binary Gem POC (2025-12-28 to 2026-01-01)

**Session characteristics:**
- Extended debugging of CI build failures
- Iterative discovery of dependencies (gobject-introspection, CFLAGS)
- Platform-specific issues (MSYS2 symlinks vs Windows linker)
- Architecture discussion (greenfield repository design)
- ADR creation and documentation

**Model used:** Opus (entire session)

**Task breakdown:**
| Task Type | Percentage | Haiku-Appropriate? |
|-----------|------------|-------------------|
| Debugging CI failures | 40% | No |
| Architecture discussion | 25% | No |
| Documentation/ADRs | 20% | No |
| Mechanical edits | 10% | Yes |
| Code review | 5% | Partially |

**Conclusion:** ~10-15% of this session could have used Haiku effectively. Forcing Haiku for `/code` would have significantly impaired productivity.

---

## Practical Recommendations

### For Framework Updates

1. **Remove hardcoded models from command files**
   - Let user/system select based on task
   - Or default to higher-capability model with override option

2. **Add complexity indicator to work units**
   ```markdown
   ## Work Unit Metadata
   Complexity: mechanical | guided | investigative | architectural
   Suggested Model: haiku | sonnet | opus
   ```

3. **Document "reactive debugging" workflow**
   - Not all sessions follow work unit → implement → done
   - Acknowledge investigate → fix → test → debug cycles

### For Session Management

1. **Start with Opus for new/unfamiliar work**
   - Downgrade to Haiku only for clearly mechanical tasks
   - Cost savings from Haiku don't offset rework from poor reasoning

2. **Use Haiku explicitly for grunt work**
   - Batch mechanical changes
   - "Apply this fix to all 10 gemspecs" → Haiku
   - "Figure out why this gemspec change isn't working" → Opus

3. **Don't switch models mid-investigation**
   - Context loss costs more than model cost difference
   - Complete the investigation, then use appropriate model for fix

---

## Token Visibility Disparity

**Critical Finding:** Token consumption visibility varies by model.

| Model | Token Telemetry | Can Report |
|-------|-----------------|------------|
| Haiku | None | Estimates only |
| Sonnet | **Full visibility** | Actual counts, remaining, %, thresholds |
| Opus | None | Cannot see consumption |

**Sonnet provides (on request or proactively):**
```
TOKEN STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Used:      19,433 / 200,000 tokens
Remaining: 180,567 tokens
Progress:  [████████░░░░░░░░░░] 9.7%
Status:    GREEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Opus provides:**
```
TOKEN STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Used:      ??? / ??? tokens
Remaining: ??? tokens
Progress:  [??????????????????] ??.?%
Status:    UNKNOWN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Implications:**
1. Social Contract Expectation #13 (token monitoring) cannot be fulfilled in Opus sessions
2. Long Opus sessions risk unexpected context exhaustion
3. Sonnet has an operational capability Opus lacks
4. This appears to be an Anthropic platform disparity, not a model limitation

**Recommendation:** Raise with Anthropic engineering. The most capable model should not lack telemetry available to less capable models.

**Workaround for Opus sessions:**
- User must monitor externally if tooling provides visibility
- Proactive checkpointing based on session depth (qualitative), not token count (quantitative)
- Consider Sonnet for sessions where precise token management is critical

---

## Token Monitoring Note

Social Contract Expectation #13 defines token monitoring thresholds (50%, 75%, 85%, 90%, 95%). In practice:

- Precise token visibility is limited
- System warnings appear after tool operations but aren't predictable
- Thresholds are aspirational guidelines, not precise triggers

**Practical approach:** Monitor session depth qualitatively. When work feels "deep" (many files read, complex reasoning chains), proactively suggest checkpointing rather than waiting for system warnings.

---

## References

- `.claude/docs/SOCIAL_CONTRACT.md` - Team expectations
- `.claude/docs/DEVELOPMENT_WORKFLOW.md` - Process definitions
- `.claude/commands/*.md` - Mode definitions
- `docs/adr/0002-greenfield-binary-gems-architecture.md` - Session output example

---

## Revision History

| Date | Change |
|------|--------|
| 2026-01-01 | Initial creation based on GTK3 POC session review |

---

**Document Owner:** Product Owner
**Next Review:** When framework commands are updated
