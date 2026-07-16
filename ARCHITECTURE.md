# vRP3 Architecture

## Resource groups
- `[vrp]`: vRP3 core and official framework modules.
- `[development]`: debug, test, examples, prototypes, and development-only resources.
- `[standalone]`: independent resources not coupled to the vRP3 core.

## Core boundary
Core contains framework-wide lifecycle, extension loading, shared security primitives, compatibility handling, common validation, and APIs required by multiple unrelated modules.

Gameplay-specific systems remain modular.

## Trust boundary
The FiveM client is untrusted. The server is authoritative for identity, permissions, money, inventory, ownership, sanctions, police state, evidence, and administration.
