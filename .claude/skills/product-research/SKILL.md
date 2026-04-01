# Product Research Skill

> Load this skill when performing market research, competitive analysis, feature gap identification, ICP analysis, TAM sizing, or any task requiring structured product intelligence.

## Research Frameworks

Use the appropriate framework(s) based on the research question. Multiple frameworks can be combined in a single research session.

---

### Framework 1: ICP (Ideal Customer Profile) Analysis

**When to use**: Understanding who the product is for, refining target segments.

**Data extraction targets**:
| Dimension | What to Find | Where to Look |
|-----------|-------------|---------------|
| Demographic | Role, seniority, team size | Job postings, LinkedIn, case studies |
| Firmographic | Company size, industry, revenue, stage | G2 reviews, Crunchbase, press releases |
| Behavioral | Tools used, workflows, buying triggers | Reddit, reviews, support forums |
| Psychographic | Values, frustrations, aspirations | User interviews, review sentiment |

**Output format**:
```markdown
## ICP: [Segment Name]
- **Role**: [typical title/seniority]
- **Company**: [size, industry, stage]
- **Pain**: [top 3 frustrations — verbatim from sources]
- **Current tools**: [what they use today]
- **Buying trigger**: [what makes them switch]
- **Evidence**: [source URLs]
```

---

### Framework 2: Competitive Landscape

**When to use**: Understanding the competitive field, identifying positioning opportunities.

**Per-competitor data sheet**:
```markdown
## Competitor: [Name]
- **Positioning tagline**: [from their homepage/marketing]
- **Target segment**: [who they sell to]
- **Pricing model**: [free/freemium/paid tiers — with prices if public]
- **Key differentiators**: [what they claim is unique]
- **Known weaknesses**: [from G2/Capterra reviews, Reddit complaints]
- **Recent moves**: [from changelogs, press, blog posts — last 6 months]
- **Employee count trend**: [growing/stable/shrinking — from LinkedIn]
- **Funding**: [stage, amount, investors — from Crunchbase]
- **Tech stack signals**: [from job postings, GitHub, BuiltWith]
```

**Competitive matrix template**:
```markdown
| Capability | Us | Comp A | Comp B | Comp C | Comp D |
|------------|-----|--------|--------|--------|--------|
| [Feature 1] | ✅/❌/🔄 | ... | ... | ... | ... |
| [Feature 2] | ✅/❌/🔄 | ... | ... | ... | ... |
| Pricing | [tier] | [tier] | [tier] | [tier] | [tier] |
| Free tier | Y/N | Y/N | Y/N | Y/N | Y/N |

✅ = Has it  |  ❌ = Missing  |  🔄 = Partial/planned
```

---

### Framework 3: TAM/SAM/SOM Sizing

**When to use**: Estimating market opportunity, validating product-market fit scope.

**Prefer bottom-up** (count addressable units × willingness to pay):
```markdown
## Market Sizing: [Product Category]

### Bottom-Up (preferred)
- Addressable companies: [count] (source: [database/report])
- Average seats per company: [count] (source: [job postings/reviews])
- Willingness to pay: $[amount]/mo (source: [competitor pricing/surveys])
- **TAM**: [companies] × [seats] × [price] = $[amount]
- **SAM**: [TAM] filtered by [geography/segment/stage] = $[amount]
- **SOM**: [SAM] × [realistic capture rate] = $[amount]

### Top-Down (for reference only)
- Analyst estimate: $[amount] ([source], [date])
- ⚠️ Top-down estimates are typically inflated — use bottom-up as primary
```

---

### Framework 4: Jobs-to-be-Done (JTBD) Extraction

**When to use**: Understanding what users are actually trying to accomplish.

**Mining sources**: Reviews, forums, support tickets, Reddit threads, interview transcripts.

**Pattern to extract**:
```markdown
## JTBD: [Product Category]

### Functional Jobs (what they're trying to DO)
- "When I [situation], I want to [motivation], so I can [expected outcome]"
  - Source: [URL] | Confidence: [CONFIRMED/INFERRED]

### Emotional Jobs (how they want to FEEL)
- "I feel [emotion] when [situation]"
  - Source: [URL] | Confidence: [CONFIRMED/INFERRED]

### Social Jobs (how they want to be PERCEIVED)
- "Others see me as [perception] when I [action]"
  - Source: [URL] | Confidence: [CONFIRMED/INFERRED]

### Underserved Jobs (high importance, low satisfaction)
| Job | Importance (1-5) | Current Satisfaction (1-5) | Gap | Evidence |
|-----|-------------------|---------------------------|-----|----------|
| [job] | [n] | [n] | [n] | [source] |
```

---

### Framework 5: Positioning Gap Analysis

**When to use**: Finding whitespace in the competitive landscape.

**Method**: Map competitors on 2 axes most relevant to the product category, then identify empty quadrants.

```markdown
## Positioning Map: [Category]

**Axis X**: [dimension — e.g., "Simple ← → Complex"]
**Axis Y**: [dimension — e.g., "Individual ← → Enterprise"]

| Competitor | X Position | Y Position | Notes |
|------------|-----------|-----------|-------|
| [Name] | [Low/Mid/High] | [Low/Mid/High] | [brief] |

### Whitespace Identified
- **[Quadrant]**: No competitor focuses on [description]. Opportunity because [evidence].
```

---

### Framework 6: Go-to-Market Patterns

**When to use**: Understanding how similar products launched, what pricing/acquisition models work.

```markdown
## GTM Patterns: [Category]

### Pricing Models in Market
| Competitor | Model | Entry Price | Enterprise Price | Free Tier |
|------------|-------|-------------|-----------------|-----------|
| [Name] | [Freemium/Usage/Seat] | $[n]/mo | $[n]/mo | [Y/N] |

### Acquisition Channels
| Channel | Used By | Evidence |
|---------|---------|----------|
| Product-led growth | [competitors] | [source] |
| Sales-led | [competitors] | [source] |
| Community/open-source | [competitors] | [source] |

### Launch Patterns
- [Competitor A]: Launched via [channel], initial audience was [segment]
- [Competitor B]: [pattern]
```

---

## Epistemic Standards (Non-Negotiable)

Every finding MUST carry a confidence label:

| Label | When to Use | Example |
|-------|-------------|---------|
| `[CONFIRMED]` | Multiple independent sources agree, dated, verifiable | "Competitor X raised $50M (TechCrunch, 2025-01-15)" |
| `[INFERRED]` | Logical extrapolation from confirmed data | "Based on 3 job postings for Go engineers, they're likely rebuilding their backend" |
| `[UNVERIFIED]` | Single source, could not corroborate | "One Reddit user claims response time is >5s" |
| `[GAP]` | Looked for evidence, found none | "No public data on their enterprise pricing" |

**Rules**:
- Never present `[INFERRED]` as `[CONFIRMED]`
- Always surface `[GAP]`s — knowing what you DON'T know is as valuable as what you find
- When sources conflict, present both sides with citations — do not resolve the conflict yourself
