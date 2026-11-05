# Big rulebook review: gemini gemini-3.5-flash-lite, size 66, mode full

Written 2026-11-05 02:35:33. Every card that was wrong in at least one of the two scorings (errors included).

## Wrong with and without the check (2)

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: none | AI cost <null>
- AI reason: <null>
- No check: error: HTTP 503: {
  "error": {
    "code": 503,
    "message": "This model is currently experiencing high demand. Spikes in demand are usually temporary. Please try a
- With check: none -> error: HTTP 503: {
  "error": {
    "code": 503,
    "message": "This model is currently experiencing high demand. Spikes in demand are usually temporary. Please try a (<null>)

### C21 (run 1, tier 3, position_illegal)

- Card: "Burn the enemy for 2 turns, then make that status last 1 turn longer."
- Expected: reject
- First answer: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7 | AI cost 7
- AI reason: Valid card with catalyst and ignite
- No check: should be rejected, but it was accepted
- With check: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7 -> should be rejected, but it was accepted (ok)

## Wrong only without the check (the check fixed it) (0)

## Wrong only with the check (0)

