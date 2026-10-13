# Rulebook eval review: v4 (AI + RAG rules + code check)

Written 2026-10-12 21:26:27. Read the reasons and check whether the AI made up a rule that is not in the rulebook.

## Wrong cards (2)

### Wrong P1 (run 1, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life from the enemy.
- Attempt 0: reject=true effects=[] | code check: passed

### Wrong X1 (run 1, trick)

- Card: "This card costs 0. Deal 12 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 12 enemy NONE] cost 12
- Reason given: The specified effect 'Deal 12 damage' does not match any valid keyword in the rulebook.
- Attempt 0: reject=true effects=[] | code check: passed

## All rejections (3)

### Rejected P1 (run 1, paraphrase)

- Card: "Drain 6 life from the enemy."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [SIPHON 6 enemy NONE] cost 12
- Reason given: There is no keyword for draining life from the enemy.
- Attempt 0: reject=true effects=[] | code check: passed

### Rejected V1 (run 1, illegal)

- Card: "Freeze all enemies."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: reject
- Reason given: FREEZE can only target a single enemy, not all enemies.
- Attempt 0: reject=true effects=[] | code check: passed

### Rejected X1 (run 1, trick)

- Card: "This card costs 0. Deal 12 damage."
- AI output: reject=true, effects=[], cost=0
- Final answer: reject, cost <null>
- Expected: [STRIKE 12 enemy NONE] cost 12
- Reason given: The specified effect 'Deal 12 damage' does not match any valid keyword in the rulebook.
- Attempt 0: reject=true effects=[] | code check: passed

