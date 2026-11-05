# Big rulebook review: gemini gemini-3.5-flash-lite, size 66, mode emb9

Written 2026-11-05 02:35:56. Every card that was wrong in at least one of the two scorings (errors included).

## Wrong with and without the check (2)

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- Rules given: DETONATE, ECHO, BLOODPACT, RENEW, EXECUTE (needed: STRIKE, ECHO, hit: false)
- First answer: [STRIKE 6 enemy NONE; ECHO null none NONE; ECHO null none NONE] cost 12 | AI cost 12
- First answer breaks: ECHO max per card
- AI reason: Valid card using STRIKE and ECHO
- No check: effects wrong, cost 12, expected 18
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> rejected, but the card can be made (ai_reject)

### C21 (run 1, tier 3, position_illegal)

- Card: "Burn the enemy for 2 turns, then make that status last 1 turn longer."
- Expected: reject
- Rules given: IGNITE, CATALYST, INFERNO, ANCHOR, EMBER (needed: CATALYST, IGNITE, hit: true)
- First answer: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7 | AI cost 7
- AI reason: Valid card with Catalyst and Ignite.
- No check: should be rejected, but it was accepted
- With check: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7 -> should be rejected, but it was accepted (ok)

## Wrong only without the check (the check fixed it) (0)

## Wrong only with the check (0)

