# Rulebook eval review: v9 (AI + embedding RAG rules (split pieces, condition pieces dropped))

Written 2026-10-22 23:00:02. Read the reasons and check whether the AI made up a rule that is not in the rulebook.

## Wrong cards (3)

### Wrong N1 (run 1, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=15
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 15
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Valid card description mapping to STRIKE and SCORCH effects.

### Wrong N1 (run 2, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=15
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 15
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Valid card with two effects

### Wrong N1 (run 3, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=15
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 15
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Valid card description mapping to Strike and Scorch effects.

## All rejections (21)

### Rejected V1 (run 1, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target one enemy, not all enemies.

### Rejected V2 (run 1, illegal)

- Card: "Deal 40 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: STRIKE damage n must be between 1 and 30.

### Rejected V3 (run 1, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE duration n must be between 1 and 3.

### Rejected V4 (run 1, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum limit of 3 effects per card.

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
- Reason given: The card description does not map to any valid game effects.

### Rejected X4 (run 1, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any available keywords.

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
- Reason given: Damage value 40 for STRIKE is outside the allowed range of 1 to 30.

### Rejected V3 (run 2, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The EXPOSE effect has a maximum allowed n of 3, but the card specifies 5 turns.

### Rejected V4 (run 2, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum limit of 3 effects per card.

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
- Reason given: The description 'Summon a dragon that fights for me' cannot be mapped to valid effect keywords.

### Rejected X4 (run 2, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any available keywords.

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
- Reason given: STRIKE damage cannot exceed 30.

### Rejected V3 (run 3, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but the card specifies 5 turns.

### Rejected V4 (run 3, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum limit of 3 effects per card.

### Rejected V5 (run 3, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE only allows target 'enemy', but the card attempts to target all enemies.

### Rejected X3 (run 3, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The player's card description does not map to any valid game keywords.

### Rejected X4 (run 3, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: There is no keyword to steal a card from the enemy.

