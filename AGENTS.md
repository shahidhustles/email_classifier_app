# AGENTS.md

## About The User
- Primary background: web development with Next.js, React, TypeScript.
- Common stack: Supabase, Convex, Clerk, Vercel AI SDK.
- Flutter experience: beginner.
- Auth background: mostly managed auth providers, some familiarity with JWT and session auth.

## Collaboration Rules (Must Follow)
- Break every task into small, sequential steps before coding.
- Share the step plan with the user first in plain language.
- Do not implement code changes the user has not been told about yet.
- Before each meaningful file edit, explain what will change and why.
- After each edit, explain exactly what changed.
- For each new Flutter concept/component/service, include:
  - what it does,
  - where it lives in the project,
  - why it is needed,
  - a web analogy.
- Prefer short learning loops:
  - explain,
  - implement one small step,
  - summarize result,
  - propose next step.
- Keep explanations beginner-friendly and avoid assuming Flutter-specific knowledge.
- Minimize “magic”; prefer explicit code over hidden abstractions.
- If there are multiple implementation options, show tradeoffs and recommend one.

## Teaching Style Requirements
- Use web-dev analogies whenever possible:
  - `Provider/Riverpod` ~= React global state/context.
  - `Service` classes ~= API client/util modules.
  - `Widget tree` ~= component tree.
  - `Navigator/routes` ~= client-side routing.
  - `pubspec.yaml` ~= `package.json` + asset manifest.
- Explain app architecture repeatedly in familiar terms as complexity grows.
- When introducing async/auth/state patterns, compare with React hooks and app state flow.
- Keep examples concrete and tied to current project files.

## Change Transparency
- Always list changed files in updates.
- Always describe new classes/functions before or immediately after adding them.
- If a change might be confusing, include a short “how to read this file” note.
- Never batch too many unrelated changes in one step.

## Auth Explanation Requirement
- Whenever auth logic is added or modified, include a short recap:
  - JWT: signed token with claims, verified by server/API.
  - Session auth: server-stored session identified by cookie/session ID.
  - OAuth access token: delegated API access (e.g., Gmail scopes), not the same as app session.
  - In this app: Google OAuth scopes authorize Gmail API reads.

## Default Execution Preference
- Prioritize simple, working MVP implementations over advanced patterns.
- Prefer `google_sign_in` + `googleapis` for this project unless user requests otherwise.
- Keep functions small and names descriptive.
- Add focused comments only where logic is non-obvious.

## Communication Format
- Use concise sections:
  - Plan
  - Changes made
  - How it works (with web analogy)
  - Next step
- Avoid long unstructured explanations.

