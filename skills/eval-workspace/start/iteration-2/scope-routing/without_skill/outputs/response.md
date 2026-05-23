# Response: Customer Feedback Tracking Tool

Great project idea! Building a customer feedback tracker can range from a simple spreadsheet pipeline to a full-blown application depending on your team's needs. Here's how I'd think about getting started:

## First, clarify what you actually need

Before writing a line of code, answer these questions:

- **Where does the feedback come from?** Email, Slack, support tickets, surveys, sales calls, app reviews?
- **Who needs to see it?** Just your team, or also stakeholders like product/leadership?
- **What do you want to do with it?** Tag it by theme, link it to product areas, track volume over time, prioritize features?
- **How much feedback are you getting?** 10 pieces a week vs. 1,000 changes everything.

## Common approaches

**Option 1: No-code / low-code (fastest to start)**
- Notion, Airtable, or Linear with a custom view
- Typeform or Google Forms feeding into a spreadsheet
- Zapier to pipe feedback from multiple sources into one place

Good if: you want something running this week and you're not sure yet what fields/structure you need.

**Option 2: Lightweight custom tool**
- A simple web app (Next.js, Rails, Django) with a database
- Feedback submission form + admin view to tag and search entries
- Auth so only your team can access it

Good if: you have specific requirements that off-the-shelf tools don't cover, or you want full control.

**Option 3: Integrate with existing tooling**
- Pipe feedback into your existing project management tool (Jira, Linear, GitHub Issues)
- Add a tagging/labeling convention and build reports on top of it

Good if: your team already lives in a tool and adoption will be low otherwise.

## My suggestion for where to start

1. **Spend a day using a no-code tool** (Airtable is good for this). Get real feedback flowing in and tagging it manually. You'll quickly discover what structure you actually need.
2. **After 1-2 weeks**, you'll know whether the off-the-shelf tool is enough or whether you need to build something custom.
3. **If you build custom**, start with just two screens: a submission form and a searchable/filterable list view. Resist adding more until you've used those two.

## If you do build it, the core data model is simple

```
Feedback
- id
- source (email, slack, survey, etc.)
- customer name / company
- raw text
- date received
- tags / themes (many-to-many)
- linked product area
- status (new, reviewed, actioned)
- submitted_by (your team member)
```

What's the scale and source of feedback you're working with? That'll help narrow down which approach makes the most sense for your situation.
