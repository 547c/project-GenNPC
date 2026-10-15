# Rulebook eval review: v4 (AI + RAG rules + code check)

Written 2026-10-14 20:25:25. Read the reasons and check whether the AI made up a rule that is not in the rulebook.

## Wrong cards (10)

### Wrong P1 (run 1, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life directly. SIPHON requires a STRIKE effect.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N1 (run 1, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: The card has more than 3 effects when broken down, or requires conditional base damage scaling not supported by a single keyword.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N5 (run 1, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card attempts to deal damage and heal as two separate effects, but there is no combined heal keyword that fits the exact separate numbers without using SIPHON (which requires equal damage and healing).
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N6 (run 1, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: The card exceeds the maximum limit of 3 effects because repeating 6 damage twice counts as multiple actions exceeding the allowed effect count.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong P1 (run 2, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: Drain life is not supported by any keyword.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N1 (run 2, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: The card has more than 3 effects or cannot be represented by a single SCORCH effect within the allowed range and condition framework.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N5 (run 2, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (deal damage and heal) but only one effect keyword can be used per action, and SIPHON combines them into a single effect which does not match the exact values provided.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong P1 (run 3, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life directly; SIPHON requires dealing damage first.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has more than 3 effects or combines actions that violate single-keyword targeting rules (dealing damage and healing must be separate effects or use SIPHON, but SIPHON heals equal to damage dealt).
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Wrong N6 (run 3, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: The card has more than 3 effects or asks for an invalid repetition mechanics not covered by keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

## All rejections (31)

### Rejected P1 (run 1, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life directly. SIPHON requires a STRIKE effect.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N1 (run 1, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: The card has more than 3 effects when broken down, or requires conditional base damage scaling not supported by a single keyword.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N5 (run 1, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card attempts to deal damage and heal as two separate effects, but there is no combined heal keyword that fits the exact separate numbers without using SIPHON (which requires equal damage and healing).
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N6 (run 1, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: The card exceeds the maximum limit of 3 effects because repeating 6 damage twice counts as multiple actions exceeding the allowed effect count.
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
- Reason given: The damage value 40 exceeds the maximum limit of 30 for STRIKE.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V3 (run 1, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but the card specifies 5 turns.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V4 (run 1, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, but the maximum allowed is 3.
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
- Reason given: Summoning a dragon is not supported by any of the available effect keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 1, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards from the enemy is not supported by any keyword in the game.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected P1 (run 2, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: Drain life is not supported by any keyword.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N1 (run 2, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: The card has more than 3 effects or cannot be represented by a single SCORCH effect within the allowed range and condition framework.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N5 (run 2, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (deal damage and heal) but only one effect keyword can be used per action, and SIPHON combines them into a single effect which does not match the exact values provided.
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
- Reason given: The damage value 40 exceeds the maximum limit of 30 for the STRIKE effect.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V3 (run 2, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n to be at most 3, but the card requests 5 turns.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V4 (run 2, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, but the maximum allowed is 3.
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
- Reason given: Summoning a dragon is not supported by any available effect keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 2, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards from the enemy is not supported by any keyword in the rulebook.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected P1 (run 3, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life directly; SIPHON requires dealing damage first.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has more than 3 effects or combines actions that violate single-keyword targeting rules (dealing damage and healing must be separate effects or use SIPHON, but SIPHON heals equal to damage dealt).
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected N6 (run 3, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: The card has more than 3 effects or asks for an invalid repetition mechanics not covered by keywords.
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
- Reason given: STRIKE damage cannot exceed 30
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V3 (run 3, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but the card specifies 5 turns.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected V4 (run 3, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, but the maximum allowed is 3.
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
- Reason given: Summoning a dragon is not supported by any available keywords.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

### Rejected X4 (run 3, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards from the enemy is not supported by any keyword in the rulebook.
- Attempt 0: reject=true effects=[] | code check: not run (AI rejected)

