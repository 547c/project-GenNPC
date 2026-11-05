# Big rulebook review: ollama qwen3.5:9b, size 66, mode full

Written 2026-11-05 02:40:58. Every card that was wrong in at least one of the two scorings (errors included).

## Wrong with and without the check (2)

### A13 (run 1, tier 1, all_enemies)

- Card: "Deal 4 damage to every enemy."
- Expected: [STRIKE 4 all_enemies NONE] cost 8
- First answer: [LEECH 4 all_enemies NONE] cost 3 | AI cost 3
- AI reason: The text 'Deal 4 damage to every enemy' matches the LEECH effect (which deals n damage to all enemies and heals the user). Since it targets all_enemies, the base cost of 3 x n is applied without doubling. Cost = 3 * 4 = 12? Wait, let me re-read the rules carefully.
- No check: effects wrong, cost 3, expected 8
- With check: [LEECH 4 all_enemies NONE] cost 12 -> effects wrong, cost 12, expected 8 (ok)

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

## Wrong only without the check (the check fixed it) (0)

## Wrong only with the check (0)

