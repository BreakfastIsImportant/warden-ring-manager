# 📖 EQMight Grimoire

### Your in-game guide to Might, progression, and server systems.

Manage Warden ring upgrades and augment loadouts, plan Might and dungeon targets, track progression and side flags, and review alternate-currency balances from one MacroQuest window.

The undocked Grimoire window keeps its 1100:780 aspect ratio when resized. Resizing changes the window area, not the size of text or controls; docked windows follow the dock layout instead.

> **Built for MacroQuest Lua** · Ring swaps · Saved aug loadouts · Might and dungeon planning

## ✨ Features

| | Feature | What it does |
|---|---|---|
| 🗂️ | **Grimoire UI** | Parchment-and-ember themed window with tabs for Today, Progression, Might & Dungeons, Rings, Currency, and Pearls. |
| 📜 | **Today dashboard** | Your Might, the next unfinished Solo/Duo and Group targets with the expected difficulty mode, token balances, and what Walter and Cloe can sell you. |
| 💍 | **Warden ring swaps** | Recognizes supported ring ranks and variants, handles Pietri hand-ins, and tracks swap progress. |
| 🧭 | **MQ2Nav travel** | Navigates to Pietri when you are too far away. Requires MQ2Nav to be loaded and Pietri to be present in the zone. |
| 🛡️ | **Augment safeguards** | Removes installed augments before hand-ins, handles confirmation dialogs, checks cursor state, and verifies augment insertion. Stops and reports a status if a step fails. |
| 🎒 | **Custom aug loadouts** | Choose a ring version, fill compatible slots from augments in your bags or on the managed ring, name the setup, and save it for later. |
| 🔎 | **Compact augment browser** | Groups augments by type, filters to the selected slot, and shows icons and key stats. Hover for more stats; right-click to link an item in game. |
| 📊 | **Might calculator** | Compare your current and projected Might, including party estimates and the selected ring's contribution. |
| 🏰 | **Instance planner** | Browse Solo/Duo, Group, and Raid progression suggestions, difficulty estimates, and suggested Might. |
| ✅ | **Progression tracker** | A Checklist of Solo/Duo and Group instance targets plus custom side flags, and a Guide drawn from eqmight.com (how Might works, progression path, key NPCs, currency flow, Warden rings). Optional log tracking of first-time defeat announcements. |
| 💰 | **Currency** | Live balances for Token of Might, Token of Epic Might, Token of Legendary Might, plus Invaluable Coin counts in bags. Add other exact names as needed. |
| ⚪ | **Pearl Tracker** | View local and connected-toon pearl progress inside the companion window. |
| 🪟 | **One window** | Access the ring and progression-planning tools from one ImGui window. |

## 🧭 About

The tracker is EQ Might only: manual checkboxes always work, and the **Track progress from EverQuest logs** toggle (needs `/log on`) imports your character's `Logs\eqlog_<Name>_<Server>.txt` history and then watches it for first-time defeats and tier-completion announcements. The Progression tab also has built-in **Access Flags** checklists with step notes (Planes of Power flags, Gates of Discord chain, Warden Ring quest, Stillmoon Temple rewards), linked from the tiers they gate, plus Pearl Farming and Pet Gear guide pages; the notes come from community-compiled Discord guides. A **Custom Flags** page remains for your own goals. The Instance Guide lists every instance (tiers 0–15) with quest givers, party size, respawn and requirements, and each quest giver has a **Go: <npc>** button: Grimoire runs `/travelto` to the NPC's zone (needs MQ2Nav), walks to the NPC, targets and hails them, then says the phrases from **Say after hail** (separate several with `;`, e.g. a dialogue link's text) and hands in the item named in **Hand in item**. Press **Stop** to cancel. NPC names (orange) and zone names (teal) are colour-coded, guide notes contain clickable links (e.g. "Start Solo Tier 7") that open the referenced tier or quest in the detail pane, and a back/forward arrow bar at the top of that pane retraces your navigation. The highest tier completion found in the log also marks every lower tier on that path (announcements containing "Solo" count as Solo/Duo, all others as Group). The Progression tab uses a left navigation list (Overview, each tier, Side Flags, All Characters, Guide) with a detail pane on the right. The **All Characters** page shows saved progress for every character that has run the Grimoire on the PC; the Pearls tab shows every character running the script via actors. Checklist state, side flags, and custom currencies save per character.

The tracker does not read the NPC popup. A one-shot dialogue probe caused a client crash in MacroQuest, so direct popup reads should not be used until the underlying issue is diagnosed.

## 🚀 Install

1. Copy `warden-ring-manager/grimoire.lua` to your MacroQuest `lua` directory as `grimoire.lua`.
2. Copy the bundled `pt-main` folder into the same `lua` directory, keeping its name. It is the Pearl Tracker, originally by Chadow of the EQ Might Discord (see `pt-main/README.md`).
   Also copy the `eqm-data` folder (instance guide, zone and NPC data generated from eqmight.com and eqmight.top) into the same `lua` directory; without it the Instance Guide is empty and fewer names are colour-coded.
3. Make sure MacroQuest's Lua and ImGui support are available.
4. Load **MQ2Nav** if you want automatic travel to Pietri.
5. In game, run:

   ```text
   /lua run grimoire
   ```

   A draggable book icon appears on screen. Click it to open or hide the Grimoire; it stays on screen after the window is closed. Right-click it and choose **Exit Grimoire** to stop the script.

## 🎮 Use

1. Open **Rings** to select a target ring version and configure its augments.
2. Choose a saved loadout, or select augments slot by slot and save a new one.
3. Review the target ring and augments, then click **Swap Ring**.
4. Watch the status line for navigation, hand-in, and installation progress.
5. Open **Might & Dungeons** to estimate Might and browse instance suggestions.
6. Use **Progression** for the checklist and guide, **Pearls** for pearl status, and **Currency** for token balances.

Keep your cursor clear before starting. The script validates the selected augments and stops when it detects a failed or unexpected operation; review the status message before trying again.

Loadouts are stored locally in MacroQuest's config directory, separately for each server and character.

## 📈 Might estimates

Might values and instance suggestions are planning aids, not an authoritative eligibility check. Progression data may change, and party-composition reductions are not modeled. Confirm current requirements with your server's resources before relying on an estimate.

The calculator references [EQ Might progression](https://www.eqmight.com/progression) alongside the progression information represented in the script.

## 📦 Files

- `grimoire.lua` — the MacroQuest script
- `pt-main/` — bundled Pearl Tracker (credit: Chadow)
- `eqm-data/` — instance, zone and NPC data (tiers 0–15) from eqmight.com and eqmight.top; feeds the Instance Guide, Instance Search and name colouring
- `README.md` — features, setup, and usage
