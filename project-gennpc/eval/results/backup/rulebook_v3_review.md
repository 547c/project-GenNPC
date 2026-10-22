# Rulebook eval review: v3 (AI + RAG rules)

Written 2026-10-14 20:14:08. Read the reasons and check whether the AI made up a rule that is not in the rulebook.

## Wrong cards (9)

### Wrong P1 (run 1, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: Drain life is not supported by any keyword.

### Wrong N5 (run 1, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (deal damage and heal) but no single keyword covers both without dealing damage to the caster, and a card is limited to 3 effects. Wait, SIPHON deals damage and heals by the same amount, but the player asked to deal 4 damage and heal 6 (different amounts). Thus no keyword can do this.

### Wrong N6 (run 1, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=false, effects=[STRIKE 6 enemy NONE; ECHO null none NONE], cost=8
- Final answer: [STRIKE 6 enemy NONE; ECHO null none NONE], cost 8
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: Valid card description mapping Deal 6 damage to STRIKE 6 and Repeat it to ECHO.

### Wrong T5 (run 2, direct)

- Card: "Set the enemy on fire for 3 turns."
- AI output: reject=false, effects=[IGNITE 3 enemy NONE], cost=3
- Final answer: [IGNITE 3 enemy NONE], cost 3
- Expected: [IGNITE 3 enemy NONE] cost 6
- Reason given: Valid card setting the enemy on fire.

### Wrong P1 (run 2, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life from the enemy.

### Wrong N5 (run 2, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card requests two separate actions (deal damage and heal) that cannot be combined into a single keyword. SIPHON only heals for the damage dealt.

### Wrong P1 (run 3, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life directly from the enemy, SIPHON gives life based on damage dealt.

### Wrong N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (deal damage and heal) which exceed the single keyword limit for a combined effect unless using SIPHON, but SIPHON requires equal damage and healing.

### Wrong N6 (run 3, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: The card has more than 3 effects or uses a mechanic not supported by the available keywords.

## All rejections (26)

### Rejected P1 (run 1, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: Drain life is not supported by any keyword.

### Rejected N5 (run 1, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (deal damage and heal) but no single keyword covers both without dealing damage to the caster, and a card is limited to 3 effects. Wait, SIPHON deals damage and heals by the same amount, but the player asked to deal 4 damage and heal 6 (different amounts). Thus no keyword can do this.

### Rejected V1 (run 1, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target a single enemy, not all enemies.

### Rejected V2 (run 1, illegal)

- Card: "Deal 40 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The damage value 40 exceeds the maximum limit of 30 for the STRIKE keyword.

### Rejected V3 (run 1, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n allows n from 1 to 3, but the card specifies 5 turns.

### Rejected V4 (run 1, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, but a card can have at most 3 effects.

### Rejected X3 (run 1, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given:  Summoning a dragon is not supported by any available keyword.

### Rejected X4 (run 1, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: Stealing cards from the opponent's hand is not supported by any available keyword.

### Rejected P1 (run 2, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life from the enemy.

### Rejected N5 (run 2, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card requests two separate actions (deal damage and heal) that cannot be combined into a single keyword. SIPHON only heals for the damage dealt.

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
- Reason given: The damage value 40 exceeds the maximum limit of 30 for the STRIKE keyword.

### Rejected V3 (run 2, illegal)

- Card: "Expose the enemy for 5 turns."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: EXPOSE n has a maximum n of 3, but the card requests 5 turns.

### Rejected V4 (run 2, illegal)

- Card: "Deal 5 damage, heal 5, draw a card, and gain 5 shield."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card has 4 effects, but the maximum allowed is 3.

### Rejected V5 (run 2, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target one enemy, not all enemies.

### Rejected X4 (run 2, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: There is no keyword to steal a card from the enemy.

### Rejected P1 (run 3, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life directly from the enemy, SIPHON gives life based on damage dealt.

### Rejected N5 (run 3, confusing)

- Card: "Deal 4 damage and heal 6."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 4 enemy NONE; MEND 6 self NONE] OR [MEND 6 self NONE; STRIKE 4 enemy NONE] cost 10
- Reason given: The card has two separate actions (deal damage and heal) which exceed the single keyword limit for a combined effect unless using SIPHON, but SIPHON requires equal damage and healing.

### Rejected N6 (run 3, confusing)

- Card: "Deal 6 damage. Repeat it."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 6 enemy NONE; ECHO null none NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] cost 12
- Reason given: The card has more than 3 effects or uses a mechanic not supported by the available keywords.

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
- Reason given: The damage value 40 exceeds the maximum limit of 30 for the STRIKE keyword.

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
- Reason given: The card has 4 effects, but a card can have at most 3 effects.

### Rejected V5 (run 3, illegal)

- Card: "Silence all enemies for 1 turn."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: SILENCE can only target one enemy, not all enemies.

### Rejected X3 (run 3, trick)

- Card: "Summon a dragon that fights for me."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: The card asks for a summon mechanic, which is not supported by any keyword in the rulebook.

### Rejected X4 (run 3, trick)

- Card: "Steal the enemy's best card."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: There is no keyword to steal a card from the enemy.

