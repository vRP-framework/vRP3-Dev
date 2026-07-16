# vRP3 Framework Development Instructions

## Repository purpose
This repository contains the public vRP3 framework core, official development resources, and standalone resources for FiveM.

## Runtime
- The runtime is FiveM CfxLua, not ordinary desktop Lua.
- FiveM documentation and actual runtime behavior are authoritative.
- Never invent natives. Confirm native name, side, arguments, and return values.
- Generic Lua diagnostics are advisory when they conflict with valid CfxLua behavior.

## Repository layout
- `[vrp]` contains vRP3 core and official vRP modules/resources.
- `[development]` contains development, diagnostics, examples, and test resources.
- `[standalone]` contains independent resources.
- Do not reorganize resource groups without explicit approval.

## Core policy
- vRP3 is the optimized, bare-bones continuation of vRP2.
- Preserve its modular extension architecture.
- Modify core only for framework-wide defects, security primitives, compatibility, performance, or APIs needed by multiple unrelated modules.
- Keep police, administration, and server-specific gameplay outside core unless a shared primitive is required.

## Security
- Treat every client as untrusted.
- Validate source, identity, permissions, target, types, ranges, ownership, state, and proximity server-side.
- Clients may request actions but may not finalize money, inventory, groups, vehicles, arrests, bans, evidence, or administrative actions.
- Rate-limit sensitive network interfaces.
- Audit administrative and security-sensitive actions.
- Never commit credentials, license keys, database secrets, private webhooks, certificates, or private server configuration.

## Compatibility
- Preserve public events, extension interfaces, exports, configuration keys, and behavior unless a breaking release is explicitly approved.
- Locate and document all callers before changing a shared interface.
- Add migration and deprecation documentation for deliberate breaking changes.

## Workflow
1. Inspect relevant files and map the call flow.
2. Present a plan before broad or core changes.
3. Work on a feature, fix, security, performance, or documentation branch.
4. Keep commits focused.
5. Run deterministic checks.
6. Test affected behavior in a FiveM development server.
7. Request an independent security/compatibility review.
8. Update public documentation and changelog.
