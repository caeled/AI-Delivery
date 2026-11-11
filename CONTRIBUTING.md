# Contributing to AI-Delivery

Pull requests are welcome. This project runs live on a real desk, so contributions are held to the same standard the system holds itself to: **verify, then report, in numbers.**

## Before you start

- Read `README.md` for the architecture and `prompts/README.md` for the rules every model is taught. Most design decisions trace back to those rules.
- Open an issue first for anything bigger than a small fix, so the design gets argued before the code does.

## The house rules (contributions are checked against these)

1. **Copies, never moves.** No tool may delete a user's file, and no copy may silently overwrite a different file. Conflicts are reported, never resolved by force.
2. **Localhost only.** The web router binds 127.0.0.1. Do not widen the bind, add remote access, or add any network call beyond the user's own git staging sync.
3. **No new dependencies.** The router is Python standard library only; the scripts are stock PowerShell. That constraint is a feature: it installs anywhere with zero setup friction.
4. **Paste, never retype.** Addresses and identifiers are read from stored bytes (`repo-url.txt`) at runtime, never hardcoded or retyped into source. Do not commit a real repo address, real base path, or any credential.
5. **Nothing personal in the tree.** No real transfer logs, no real filenames from a working desk, no usernames. Examples use `C:\Users\<you>\AI-Delivery`.

## Testing your change

- **Router (`tools/ai-delivery-router.py`):** build a scratch tree (`Inbox/<A>`, `Outbox/<B>`), drop in a test file, run `python ai-delivery-router.py --base <scratch> --port 8799`, and exercise: a clean copy (hash-identical, logged), a repeat copy (reported identical), a conflicting same-name file (refused, destination untouched), and a same-box attempt (refused). Report the results in your PR.
- **PowerShell tools:** run them against a scratch base folder with `-BasePath` / a test config, never against a live desk for a first run. State the Windows and PowerShell versions you tested on.
- **Setup script:** test on a throwaway user profile or VM if you can; at minimum, walk the prompt flow with a scratch base path and confirm nothing outside it was touched.

## Pull request process

1. Branch from `main`; one concern per PR.
2. Keep commits descriptive: what changed and why, in the subject line.
3. Fill in the PR template: what changed, how you tested it, and which house rules it touches.
4. Expect review against the house rules first and style second. A PR that weakens rule 1 or 2 will be declined no matter how elegant it is.

## Prompts are code too

The files in `prompts/` are operating instructions for live agents. Changes to them get the same review as changes to scripts: say which model's behavior you are changing and how you know the new wording does what you intend.
