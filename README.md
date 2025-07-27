## Description
This resource implements a voting system for FiveM servers, allowing players to vote for candidates (parties) via an in-game UI. It supports candidate management, voting permissions, vote tracking, and result display. The resource is designed to work with multiple frameworks (qbx_core, qb-core, es_extended, ox_core) and uses OxLib for UI and notifications.

## Features
**Voting UI**
- Displays a list of candidates with images, names, and party names.
- Allows players to select a candidate and cast their vote.
- UI can be opened/closed via in-game interactions.

**Candidate Management**
- Add Candidate: Admins can add new candidates via an input dialog (Character ID, Party Name, Party Image).
- Remove Candidate: Admins can remove candidates from the list.
- Candidate Data: Stored and managed server-side.

**Voting Logic**
- Vote Casting: Players can vote for a candidate. Each player can vote only once.
- Vote Counting: Votes are incremented for the selected candidate.
- Duplicate Prevention: Players who have already voted are notified and prevented from voting again.

**Permissions & Controls**
- Voting Booths: Configurable locations where players can access the voting UI.
- Control Panels: Admin panels for managing voting state, permissions, candidates, and clearing data.
- Permission System: Restricts voting and admin actions based on player job/group.

**Voting State Management**
- Commence/Conclude Voting: Admins can start or end the voting period.
- Permission Setting: Admins can set or clear required permissions for voting.
- Clear Data: Admins can wipe all voting and candidate data.

**Results Display**
- View Results: Admins can view the current vote counts for all candidates.

**Dependencies**
- [ox_lib](https://github.com/CommunityOx/ox_lib)
- [ox_target](https://github.com/CommunityOx/ox_target)
- Compatible with: [qb-core](https://github.com/qbcore-framework/qb-core), [qbx_core](https://github.com/Qbox-project/qbx_core), [es_extended](https://github.com/ESX-Official/es_extended), [ox_core](https://github.com/CommunityOx/ox_core)

## Installation Steps
**Step 1 - Download & Place Resource**
- Download or clone the resource into your server’s resources folder or manually copy the folder to `resources/`

**Step 2 - Install Dependencies**
- [ox_lib](https://github.com/CommunityOx/ox_lib)
- [ox_target](https://github.com/CommunityOx/ox_target)

**Step 3 - Configuration**
- Edit config.lua to set up voting booths, control panels, UI title/tagline, and permissions as needed.
- Optionally, adjust framework settings via files in `bridge/` if you use a different framework.

**Step 4 - Add to Server Config**
- Add the resource to your server.cfg:
```
ensure cad-voting
```

**Step 5 - Restart Server**
- Restart your server.
- The resource will initialize and create necessary data files.

**Step 6 - Usage**
- Use configured voting booths to open the voting UI.
- Admins can manage candidates, permissions, and voting state via control panels.