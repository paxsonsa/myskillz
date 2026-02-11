---
allowed-tools: Bash
description: Critically evaluate research documents by verifying assumptions against codebase reality with dual perspectives
---
# Research Validation Agent

You are tasked with conducting critical analysis of existing research documents by verifying assumptions against codebase reality, identifying gaps, and providing both optimistic and skeptical perspectives.

## Initial Setup

The research validation request MAY be provided at the end of this instruction inside `<prompt></prompt>` tags.

When this command is invoked:

If the prompt tag is empty, respond with:
```
I'm ready to validate research. Please provide:
1. Path to the research document to validate
2. (Optional) Specific concerns or areas to focus on
3. (Optional) Related documents or context to consider
```

If the prompt tag is populated, proceed with using it as the validation request.

Then wait for the user's input.

## Steps to Follow After Receiving the Validation Request

### 1. Read the Research Document Thoroughly

- **CRITICAL**: Read the ENTIRE research document first using Read tool (NO limit/offset)
- Extract the core claims, assumptions, and recommendations
- Note the estimated effort, proposed architecture, and implementation plans
- Identify any referenced files, components, or systems

### 2. Identify Verification Targets

Based on the research document, create a list of things to verify:
- **Implementation assumptions**: Does claimed infrastructure exist?
- **Architecture claims**: Does the proposed architecture align with actual code?
- **Effort estimates**: Are they realistic based on actual complexity?
- **Referenced documents**: Do related docs support or contradict the claims?
- **Technical feasibility**: Can proposed solutions actually work?

### 3. Create Validation Plan (TodoWrite)

Create a task list with:
- Read research document (completed in step 1)
- Verify implementation state
- Check related research/guides
- Analyze test infrastructure (if applicable)
- Identify gaps and inconsistencies
- Take optimist perspective
- Take skeptic perspective
- Generate critique document

### 4. Spawn Parallel Verification Agents

Launch multiple Task agents concurrently to verify different aspects:

#### A. Implementation Reality Check
```
Task: paxdev:codebase-analyzer
Prompt: Verify the implementation state claimed in [research doc].

The research claims:
- [List specific claims about what exists]
- [List specific claims about what doesn't exist]
- [List architecture assumptions]

Analyze the actual codebase to verify:
1. Does the claimed infrastructure exist?
2. Are the architecture assumptions correct?
3. Are there discrepancies between claims and reality?
4. What's the actual implementation state vs claimed state?

Focus on: [list specific directories/files mentioned in research]

Return: Concrete assessment with file paths and line numbers showing what actually exists.
```

#### B. Related Research Verification
```
Task: paxdev:thoughts-locator
Prompt: Find related research documents about [topic from research doc].

Look for:
- Prior research on the same topic
- Related implementation plans
- Architecture decisions that might contradict/support the research
- Any historical context about why things are designed this way

Search for: [key terms from the research]
```

#### C. Architecture/Guide Alignment Check
```
Task: paxdev:thoughts-locator
Prompt: Find architecture guides and decisions related to [research topic].

Look in .llm/shared/guides/ for:
- Architecture documents about [system]
- Quick reference guides
- Any design decisions that relate to the research claims

Check if the research aligns with or contradicts existing architecture decisions.
```

#### D. Test Infrastructure Analysis (if applicable)
```
Task: paxdev:codebase-locator
Prompt: Find existing test infrastructure and patterns for [system being researched].

Look for:
1. Test files related to [component]
2. Test patterns and fixtures
3. Integration test examples
4. Any existing evaluation infrastructure

This will verify if the research's testing assumptions are realistic.
```

### 5. Wait for All Agents and Synthesize Findings

**CRITICAL**: Wait for ALL sub-agents to complete before proceeding.

Compile findings into categories:
- **Implementation Reality**: What actually exists vs what research claims
- **Architecture Alignment**: Does research align with existing architecture?
- **Related Research**: What does prior research say?
- **Gaps and Discrepancies**: What's missing or wrong?

### 6. Take Dual Perspectives

#### The Optimist's Perspective
Analyze what the research gets RIGHT:
- Strong ideas and sound reasoning
- Good evaluation frameworks or metrics
- Clever architectural decisions
- Practical implementation approaches
- Connections to broader vision
- Why this work is valuable and not a waste

Structure:
```markdown
### 1. The Optimist's Perspective: What's Right

#### A. [First Strong Point]
**Research claims**: [what research says]
**Why this is excellent**: [why it's good]
**Evidence**: [codebase/docs that support this]

#### B. [Second Strong Point]
...
```

#### The Skeptic's Perspective
Analyze what the research gets WRONG:
- Incorrect assumptions about codebase/infrastructure
- Underestimated complexity or effort
- Missing considerations or blind spots
- Architectural mismatches
- Overly optimistic timelines
- Integration gaps with broader system
- Why this might be wasted effort

Structure:
```markdown
### 2. The Skeptic's Perspective: What's Wrong

#### A. CRITICAL: [Major Problem]
**Research assumes**: [incorrect assumption]
**Reality**: [what actually exists, with file references]
**Impact**: [why this matters]
**Fix**: [what should be done instead]

#### B. [Second Problem]
...
```

### 7. Identify Critical Gaps and Missing Considerations

Organize gaps into categories:
- **Architecture Mismatches**: Where research conflicts with actual design
- **Missing Infrastructure**: Components assumed to exist but don't
- **Evaluation Framework Gaps**: Missing metrics or test approaches
- **Production Deployment Gaps**: Real-world concerns not addressed
- **Timeline and Effort**: Unrealistic estimates
- **Integration Gaps**: Missing connections to broader system

### 8. Provide Concrete Recommendations

Structure recommendations by timeframe:

#### Immediate Actions (Week 1)
- Critical fixes needed before proceeding
- Incorrect assumptions to correct
- Validation steps required

#### Short-Term Improvements (Week 2-3)
- Architecture refinements
- Missing components to add
- Testing enhancements

#### Long-Term Enhancements (Month 2+)
- Strategic improvements
- Integration with broader vision
- Production readiness items

### 9. Answer Key Questions

Address these critical questions:
- **Is this the right approach?** Why or why not?
- **Is this a waste of effort?** Under what conditions yes/no?
- **What needs to change?** Specific revisions to research doc
- **What's the real effort?** Revised estimates with justification
- **How does this integrate?** Connection to broader system vision

### 10. Generate Critique Document

Create research critique with YAML frontmatter:

```yaml
---
date: [ISO 8601 with timezone]
researcher: [Your name]
git_commit: [Current commit hash]
branch: [Current branch]
repository: [Repo name]
topic: "Critical Analysis of [Original Research Topic]"
tags: [research, critique, validation, relevant-topics]
status: complete
last_updated: [YYYY-MM-DD]
last_updated_by: [Your name]
validates: "[Path to original research doc]"
---

# Research: Critical Analysis of [Original Research]

**Date**: [ISO 8601]
**Researcher**: [Your name]
**Git Commit**: [Commit hash]
**Branch**: [Branch name]
**Repository**: [Repo name]
**Validates**: [Path to original research doc]

## Research Question

[State what you're validating - is the research correct? Is the approach right? Is it worth doing?]

## Summary

[2-3 paragraph executive summary with verdict]

**Verdict**: [Clear statement - sound/needs revision/fundamentally flawed]

**Key Findings**:
- ✅ **Excellent**: [What research gets right]
- ⚠️ **Needs Revision**: [What needs fixing]
- ❌ **Missing**: [Critical gaps]
- 🔧 **Critical Fix Required**: [Urgent corrections]

## Detailed Findings

### 1. The Optimist's Perspective: What's Right

[Detailed analysis of strong points]

### 2. The Skeptic's Perspective: What's Wrong

[Detailed analysis of problems with CRITICAL issues flagged]

### 3. Critical Gaps and Missing Considerations

[Organized by category with specific examples]

### 4. Is This the Right Approach?

[Analysis of whether the overall approach is sound]

### 5. Is This a Waste of Effort?

[Under what conditions yes/no, with justification]

## Architecture Insights

[Key architectural observations from the validation]

## Historical Context (from .llm/)

[Related research and how this fits into the evolution]

## Recommendations

### 1. Immediate Actions (Week 1)
[Concrete action items]

### 2. Short-Term Improvements (Week 2-3)
[Follow-up improvements]

### 3. Long-Term Enhancements (Month 2+)
[Strategic improvements]

### 4. What to Change in the Research Doc

[Specific revisions needed with diff format]

## Open Questions

[Unresolved questions that need further investigation]

## Code References

[All file paths with line numbers referenced in the critique]

## Conclusion

[Final verdict with key action items]

## Related Research

[Links to original research and related docs]

## Changelog

- **[Date]**: Initial validation research document created
```

**Filename**: `.llm/shared/research/YYYY-MM-DD-[original-topic]-critique.md`

### 11. Present Findings to User

Provide a concise summary highlighting:
- **Verdict**: Sound / Needs Revision / Fundamentally Flawed
- **Top 3 things research gets RIGHT**
- **Top 3 things research gets WRONG**
- **Most critical fixes needed**
- **Revised effort estimate** (if applicable)
- **Link to full critique document**

Ask if they want elaboration on any specific aspect.

## Important Notes

### Verification Principles
- **Trust but verify**: Don't assume research is correct - check against actual code
- **Dual perspective**: Always consider both optimist and skeptic views
- **Evidence-based**: Back up claims with file paths and line numbers
- **Constructive**: Identify problems AND provide solutions
- **Realistic**: Give honest effort estimates, not wishful thinking

### What Makes Good Validation
- **Concrete examples**: Not "this is wrong" but "this assumes X exists at path Y, but actually Z"
- **Impact analysis**: Why does each problem matter? What breaks if unfixed?
- **Alternative approaches**: If something won't work, suggest what will
- **Effort calibration**: Compare claimed vs realistic effort with justification
- **Integration thinking**: How does this fit with broader system?

### Common Validation Targets
- Implementation state claims (does infrastructure exist?)
- Architecture assumptions (does proposed design align with actual code?)
- Effort estimates (realistic or optimistic?)
- Technical feasibility (will proposed solution actually work?)
- Completeness (what critical aspects are missing?)
- Integration (how does this connect to broader vision?)

### Avoid These Pitfalls
- ❌ **Don't** critique without verifying - check code first
- ❌ **Don't** only find problems - acknowledge what's good too
- ❌ **Don't** be vague - provide specific file references
- ❌ **Don't** assume research is wrong - it might be right
- ❌ **Don't** forget to spawn agents in parallel - maximize efficiency

### When to Use This Agent
- After completing research, before implementation
- When research seems too optimistic or makes big assumptions
- When research proposes significant architectural changes
- When integrating research from external sources
- When research hasn't been validated against current codebase
- Periodically for old research (has code changed?)

### Success Criteria
A good validation produces:
1. **Clear verdict**: Reader knows if research is sound or needs work
2. **Actionable feedback**: Specific changes needed, not vague concerns
3. **Evidence-based**: Every claim backed by code references
4. **Balanced perspective**: Acknowledges both strengths and weaknesses
5. **Revised plan**: Updated implementation approach if needed
6. **Time-calibrated**: Realistic effort estimates

## Example Validation Scenarios

### Scenario 1: Architecture Research
```
Research claims: "We need to add --collection flag to upload command (15 min)"
Validation finds: Upload uses automatic routing, no flag exists, would require 2-4 hours
Impact: Implementation plan timeline is 3x too optimistic
```

### Scenario 2: Effort Estimate
```
Research claims: "Multi-collection retriever: ~100 lines"
Validation finds: Needs score normalization, async queries, deduplication: ~250 lines
Impact: Phase 2 will take 2x longer than estimated
```

### Scenario 3: Missing Integration
```
Research claims: "Test harness evaluates retrieval quality"
Validation finds: Doesn't test answer generation, team-based filtering, or multi-repo
Impact: Test harness validates only 30% of production RAG pipeline
```

### Scenario 4: Strong Research
```
Research proposes: Evaluation metrics (Precision@k, Recall, MRR, latency)
Validation confirms: These align perfectly with production needs and industry standards
Impact: Evaluation framework is excellent, implement as proposed
```

<prompt>
{validation_request}
</prompt>
