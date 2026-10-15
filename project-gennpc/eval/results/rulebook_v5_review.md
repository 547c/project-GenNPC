# Rulebook eval review: v5 (AI + all rules + code check)

Written 2026-10-14 20:36:18. Read the reasons and check whether the AI made up a rule that is not in the rulebook.

## Wrong cards (3)

### Wrong N1 (run 1, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=14
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 11
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Valid card with two effects
- Attempt 0: reject=false effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING] | code check: passed

### Wrong N1 (run 2, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=15
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 11
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Card is valid and fits the rules.
- Attempt 0: reject=false effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING] | code check: passed

### Wrong N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: Healing requires MEND, SIPHON, or RENEW, but the card asks for separate damage and healing without using SIPHON.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

## All rejections (22)

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
- Reason given: The STRIKE keyword maximum damage is 30, but 40 was requested.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V3 (run 1, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but 5 was requested.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V4 (run 1, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum allowed limit of 3.
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
- Reason given: The card description does not match any available effect keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 1, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: There is no keyword to steal a card.
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
- Reason given: The damage value 40 exceeds the maximum allowed limit of 30 for STRIKE.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V3 (run 2, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but the player requested 5 turns.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V4 (run 2, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, but a card can have at most 3 effects.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V5 (run 2, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target one enemy, not all enemies.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X3 (run 2, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card description does not map to any valid game effects.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 2, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: There is no keyword to steal a card from the enemy.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: Healing requires MEND, SIPHON, or RENEW, but the card asks for separate damage and healing without using SIPHON.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V1 (run 3, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target one enemy, not all enemies.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V2 (run 3, illegal)

- Card: "Deal 40 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The damage value 40 exceeds the maximum allowed limit of 30 for STRIKE.
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
- Reason given: The card has 4 effects, which exceeds the maximum allowed limit of 3 effects per card.
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
- Reason given: Summoning a dragon is not supported by any available effect keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 3, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any keyword.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

