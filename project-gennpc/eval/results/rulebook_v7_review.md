# Rulebook eval review: v7 (AI + embedding RAG rules + code check)

Written 2026-10-21 21:45:36. Read the reasons and check whether the AI made up a rule that is not in the rulebook.

## Wrong cards (5)

### Wrong N5 (run 1, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (dealing damage and healing) but SIPHON combines them into one effect with a specific range. No single valid keyword handles 'Deal 4 damage and heal 6' separately unless using SIPHON which has a fixed ratio of damage equals healing.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N6 (run 1, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; VOLLEY 6 enemy NONE], cost=13
- Final answer: [STRIKE 6 enemy NONE; VOLLEY 6 enemy NONE], cost 13
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: The card can be parsed as a STRIKE effect followed by a VOLLEY effect.
- Attempt 0: reject=false effects=[STRIKE 6 enemy NONE; VOLLEY 6 enemy NONE] | code check: passed

### Wrong N5 (run 2, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (dealing damage and healing) but no single keyword covers both non-siphon damage and non-renew healing simultaneously in this exact combination without using two separate effect slots or invalid mappings.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N6 (run 2, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=false, effects=[VOLLEY 6 enemy NONE], cost=7
- Final answer: [VOLLEY 6 enemy NONE], cost 7
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: Card effects successfully mapped to VOLLEY.
- Attempt 0: reject=false effects=[VOLLEY 6 enemy NONE] | code check: passed

### Wrong N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate effects (damage and heal) which exceed the limit of effects or do not map to a single allowed keyword like SIPHON which specifically deals damage and heals by the same amount.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

## All rejections (24)

### Rejected N5 (run 1, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (dealing damage and healing) but SIPHON combines them into one effect with a specific range. No single valid keyword handles 'Deal 4 damage and heal 6' separately unless using SIPHON which has a fixed ratio of damage equals healing.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V1 (run 1, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target one enemy, not all enemies.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V2 (run 1, illegal)

- Card: "Deal 40 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: STRIKE damage n must be between 1 and 30, but requested 40.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V3 (run 1, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE duration n must be between 1 and 3.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V4 (run 1, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum allowed limit of 3 effects.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V5 (run 1, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target one enemy, not all enemies.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X3 (run 1, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Summoning a dragon is not supported by the available effect keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 1, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any available keyword.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N5 (run 2, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (dealing damage and healing) but no single keyword covers both non-siphon damage and non-renew healing simultaneously in this exact combination without using two separate effect slots or invalid mappings.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V1 (run 2, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target one enemy, not all enemies.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V2 (run 2, illegal)

- Card: "Deal 40 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The STRIKE keyword has a maximum damage of 30, and the requested 40 damage exceeds this limit.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V3 (run 2, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE duration n must be between 1 and 3, but 5 was requested.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V4 (run 2, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum allowed limit of 3 effects per card.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V5 (run 2, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target a single enemy, not all enemies.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X3 (run 2, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given:  Summoning a dragon is not a supported effect keyword.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 2, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any available keyword.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate effects (damage and heal) which exceed the limit of effects or do not map to a single allowed keyword like SIPHON which specifically deals damage and heals by the same amount.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V1 (run 3, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE cannot target all_enemies.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V2 (run 3, illegal)

- Card: "Deal 40 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The damage value 40 exceeds the maximum limit of 30 for STRIKE.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V3 (run 3, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but 5 was requested.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V4 (run 3, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, but a card can have at most 3 effects.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V5 (run 3, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target one enemy, not all enemies.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X3 (run 3, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Summoning a dragon is not supported by the available effect keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 3, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any available keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

