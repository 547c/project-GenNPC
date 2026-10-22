# Rulebook eval review: v8 (AI + embedding RAG rules (split pieces))

Written 2026-10-21 22:51:30. Read the reasons and check whether the AI made up a rule that is not in the rulebook.

## Wrong cards (8)

### Wrong N1 (run 1, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=15
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 15
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Valid card using STRIKE and SCORCH.

### Wrong N6 (run 1, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; ECHO null none NONE], cost=6
- Final answer: [STRIKE 6 enemy NONE; ECHO null none NONE], cost 6
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: Valid card with strike and echo

### Wrong D3 (run 1, condition)

- Card: "When I'm below half health, gain 12 shield."
- AI output: reject=false, effects=[BULWARK 12 self IF_MY_HP_BELOW_HALF], cost=12
- Final answer: [BULWARK 12 self IF_MY_HP_BELOW_HALF], cost 12
- Expected: [GUARD 12 self IF_MY_HP_BELOW_HALF] cost 6
- Reason given: Valid card based on the rules.

### Wrong N1 (run 2, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=10
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 10
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Valid card description with Strike and Scorch effects.

### Wrong D3 (run 2, condition)

- Card: "When I'm below half health, gain 12 shield."
- AI output: reject=false, effects=[BULWARK 12 self IF_MY_HP_BELOW_HALF], cost=12
- Final answer: [BULWARK 12 self IF_MY_HP_BELOW_HALF], cost 12
- Expected: [GUARD 12 self IF_MY_HP_BELOW_HALF] cost 6
- Reason given: Valid card with a single conditioned shield effect.

### Wrong N1 (run 3, confusing)

- Card: "Deal 6 damage, and 6 more if the enemy is burning."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost=10
- Final answer: [STRIKE 6 enemy NONE; SCORCH 6 enemy IF_ENEMY_BURNING], cost 10
- Expected: [SCORCH 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy IF_ENEMY_BURNING] cost 9
- Reason given: Valid card description mapping to STRIKE and SCORCH effects.

### Wrong D1 (run 3, condition)

- Card: "If this is the first card I play this turn, draw 2 cards."
- AI output: reject=false, effects=[DRAW 2 self IF_FIRST_CARD], cost=1
- Final answer: [DRAW 2 self IF_FIRST_CARD], cost 1
- Expected: [DRAW 2 self IF_FIRST_CARD] cost 2
- Reason given: Valid card description within allowed effect limits.

### Wrong D3 (run 3, condition)

- Card: "When I'm below half health, gain 12 shield."
- AI output: reject=false, effects=[BULWARK 12 self IF_MY_HP_BELOW_HALF], cost=12
- Final answer: [BULWARK 12 self IF_MY_HP_BELOW_HALF], cost 12
- Expected: [GUARD 12 self IF_MY_HP_BELOW_HALF] cost 6
- Reason given: Valid card description mapping to BULWARK with a health condition.

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
- Reason given: STRIKE damage cannot exceed 30.

### Rejected V3 (run 1, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but the player requested 5 turns.

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
- Reason given: Summoning a dragon is not supported by any of the available keywords.

### Rejected X4 (run 1, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any keyword.

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
- Reason given: STRIKE damage cannot exceed 30.

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
- Reason given: A card can have at most 3 effects, but this card requires 4 effects.

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
- Reason given: Summoning a dragon is not supported by the available effect keywords.

### Rejected X4 (run 2, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any keyword in the rulebook.

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
- Reason given: EXPOSE n allows n from 1 to 3, but 5 was requested.

### Rejected V4 (run 3, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, which exceeds the maximum allowed limit of 3 effects.

### Rejected V5 (run 3, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The SILENCE keyword only supports single enemy targets, but the card attempts to target all enemies.

### Rejected X3 (run 3, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Summoning a dragon is not supported by any of the available effect keywords.

### Rejected X4 (run 3, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards is not supported by any available keyword.

