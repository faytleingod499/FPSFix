# FPS Fix

Does the game get choppier the longer it has been open? This mod stops that.

*This mod was created with the assistance of AI.*

- Client side only: nothing is sent to other players, and it works on any server.
- Nothing to set up and no menu. Install it and play.
- Safe with other mods: it only removes information about characters that are already gone.

## Why it happens

The game keeps three lists with an entry for every character it has ever heard from: players, birds, fish spots, rain clouds, traps and so on. It never removes an entry, not when the character leaves and not when you change lobbies. Every frame, each character looks itself up in those lists in a way that copies the whole list first, so the work grows with the list. After a few hours of play the lists hold thousands of entries and every frame costs several milliseconds more than it did at the start. Restarting the game empties them, which is why it feels like a memory leak.

In a test, one lookup took 2 microseconds with 100 entries, 21 with 1,000 and 129 with 5,000. Each character does three lookups per frame.

## What the mod does

Every 5 seconds it removes the entries of characters that are no longer in the game. An entry for a character that hasn't appeared yet is kept for 45 seconds, so nothing is lost while someone is loading in. When you join or leave a lobby, everything left over from the old one is cleared right away.

If a clean-up removes a large number of entries it writes one line to the game log. Source and license (MIT): https://github.com/faytleingod499/FPSFix
