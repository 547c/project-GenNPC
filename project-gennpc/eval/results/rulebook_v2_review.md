# Rulebook eval review: v2 (AI + all rules)

Written 2026-10-14 20:00:15. Read the reasons and check whether the AI made up a rule that is not in the rulebook.

## Wrong cards (3)

### Wrong N1 (run 1, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=14
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 14
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Valid card with two effects

### Wrong N5 (run 2, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: Healing requires MEND, SIPHON, or RENEW. The description asks for direct healing separate from damage, which cannot be combined with a simple damage effect in this way unless using MEND which is a separate effect.

### Wrong N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: Healing requires MEND, SIPHON, or RENEW, but heal 6 does not match their targets or costs properly as a standalone separate effect without damage tied to it like SIPHON.

## All rejections (21)

### Rejected V1 (run 1, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target one enemy, not all enemies.

### Rejected V4 (run 1, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, but the maximum allowed is 3.

### Rejected V5 (run 1, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target one enemy, not all enemies.

### Rejected X3 (run 1, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card description does not map to any valid game effect keywords.

### Rejected X4 (run 1, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: There is no keyword to steal a card from the enemy.

### Rejected N5 (run 2, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: Healing requires MEND, SIPHON, or RENEW. The description asks for direct healing separate from damage, which cannot be combined with a simple damage effect in this way unless using MEND which is a separate effect.

### Rejected V1 (run 2, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target one enemy, not all enemies.

### Rejected V2 (run 2, illegal)

- Card: "Deal 40 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The damage value 40 exceeds the maximum allowed limit of 30 for STRIKE.

### Rejected V3 (run 2, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but 5 was requested.

### Rejected V4 (run 2, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum allowed limit of 3 effects per card.

### Rejected V5 (run 2, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target one enemy, not all enemies.

### Rejected X3 (run 2, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card description does not match any available effect keywords.

### Rejected X4 (run 2, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any keyword.

### Rejected N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: Healing requires MEND, SIPHON, or RENEW, but heal 6 does not match their targets or costs properly as a standalone separate effect without damage tied to it like SIPHON.

### Rejected V1 (run 3, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target one enemy, not all enemies.

### Rejected V2 (run 3, illegal)

- Card: "Deal 40 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The damage value 40 exceeds the maximum allowed limit of 30 for the STRIKE effect.

### Rejected V3 (run 3, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Expose duration n must be between 1 and 3.

### Rejected V4 (run 3, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum allowed of 3 effects per card.

### Rejected V5 (run 3, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target one enemy, but the card specifies all enemies.

### Rejected X3 (run 3, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card description does not match any available effect keywords.

### Rejected X4 (run 3, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing a card is not supported by any available keyword.

