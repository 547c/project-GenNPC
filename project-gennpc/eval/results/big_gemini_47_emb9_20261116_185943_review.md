# Big rulebook review: gemini gemini-3.5-flash-lite, size 47, mode emb9

Every card that was wrong in at least one of the three scorings (no check, retry, reject on violation); errors count as wrong. The lines of each card show all three.

## Wrong in all three (26)

### B05 (run 1, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- Rules given: LEECH, BARRAGE, DETONATE, SCORCH, STRIKE (needed: SCORCH, STRIKE, hit: true)
- First answer: reject | AI cost 0
- AI reason: The card attempts to combine multiple effects in a way that is not supported by a single SCORCH keyword or valid combination within effect limits.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B12 (run 1, tier 2, multi)

- Card: "Chill all enemies for 2 turns and gain 6 shield."
- Expected: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] OR [GUARD 6 self NONE; CHILL 2 all_enemies NONE] cost 14
- Rules given: CHILL, FROSTBITE, FREEZE, WEAKEN, CURSE (needed: CHILL, GUARD, hit: false)
- First answer: [CHILL 2 all_enemies NONE; BULWARK 6 self NONE] cost 14 | AI cost 14
- AI reason: Valid card effects based on the player's description.
- No check: effects wrong
- Retry check: [CHILL 2 all_enemies NONE; BULWARK 6 self NONE] cost 20 -> effects wrong, cost 20, expected 14 (ok)
- Reject on violation: [CHILL 2 all_enemies NONE; BULWARK 6 self NONE] cost 20 -> effects wrong, cost 20, expected 14 (ok)

### B13 (run 1, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- Rules given: INFERNO, IGNITE, BLAZE, FLARE, DETONATE (needed: IGNITE, hit: true)
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 8 | AI cost 8
- First answer breaks: INFERNO n range
- AI reason: Valid card description converting to INFERNO with a condition.
- No check: effects wrong, cost 8, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (INFERNO): n must be a whole number from 1 to 2, but it is 3.

### B14 (run 1, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- Rules given: FREEZE, HASTE, CURSE, FROSTBITE, WEAKEN (needed: FREEZE, hit: true)
- First answer: reject | AI cost 0
- AI reason: There is no keyword that makes an enemy skip its turn conditionally like FREEZE without FREEZE itself, and FREEZE cannot have conditions applied in this manner or use the poison check.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C01 (run 1, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: VOLLEY, ECHO, SCORCH, HASTE, BARRAGE (needed: ECHO, STRIKE, hit: false)
- First answer: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 | AI cost 16
- AI reason: The card deals damage using SCORCH and repeats it using ECHO.
- No check: effects wrong, cost 16, expected 10
- Retry check: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 -> effects wrong, cost 16, expected 10 (ok)
- Reject on violation: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 -> effects wrong, cost 16, expected 10 (ok)

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- Rules given: DETONATE, ECHO, SCORCH, HASTE, LEECH (needed: STRIKE, ECHO, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card exceeds the maximum of 3 effects since repeating twice means 3 separate damage effects.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C03 (run 1, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- Rules given: DETONATE, HASTE, STRIKE, FOCUS, LEECH (needed: AFTERSHOCK, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card requests a delayed damage effect at the start of the next turn, which is not supported by any keyword.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 1, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- Rules given: MARK, EXPOSE, CURSE, IGNITE, ANCHOR (needed: GUARD, MARK, hit: false)
- First answer: reject | AI cost 0
- AI reason: MARK cannot be on the same card as any damage effect or non-compatible effects, but the card also attempts to gain shield which is WARD/GUARD. However, the primary rejection is that MARK cannot be on the same card as shield-gain effects or the text is improperly combined.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C20 (run 1, tier 3, position)

- Card: "Make the next status last longer, then poison the enemy for 3 a turn."
- Expected: [CATALYST null none NONE; POISON 3 enemy NONE] cost 9
- Rules given: CATALYST, POISON, QUICKEN, CURSE, HASTE (needed: CATALYST, POISON, hit: true)
- First answer: reject | AI cost 0
- AI reason: POISON uses n for total damage or per-turn damage inconsistently, and the card lacks a valid status effect alongside CATALYST if POISON is not recognized as one for it, or cost calculation boundaries are violated.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 2, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- Rules given: LEECH, BARRAGE, DETONATE, SCORCH, STRIKE (needed: SCORCH, STRIKE, hit: true)
- First answer: reject | AI cost 0
- AI reason: The card requests two effects, but can be represented by a single SCORCH effect. However, SCORCH n=8 costs 12, whereas the player asks for a specific combination of base and conditional damage that does not cleanly map to a single valid effect without violating mechanics.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B13 (run 2, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- Rules given: INFERNO, IGNITE, BLAZE, FLARE, DETONATE (needed: IGNITE, hit: true)
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 8 | AI cost 8
- First answer breaks: INFERNO n range
- AI reason: Valid card based on available keywords.
- No check: effects wrong, cost 8, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (INFERNO): n must be a whole number from 1 to 2, but it is 3.

### B14 (run 2, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- Rules given: FREEZE, HASTE, CURSE, FROSTBITE, WEAKEN (needed: FREEZE, hit: true)
- First answer: reject | AI cost 0
- AI reason: There is no keyword that makes the enemy skip its turn conditionally like that without freezing.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C01 (run 2, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: VOLLEY, ECHO, SCORCH, HASTE, BARRAGE (needed: ECHO, STRIKE, hit: false)
- First answer: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 | AI cost 16
- AI reason: Valid card description that can be built using SCORCH and ECHO.
- No check: effects wrong, cost 16, expected 10
- Retry check: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 -> effects wrong, cost 16, expected 10 (ok)
- Reject on violation: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 -> effects wrong, cost 16, expected 10 (ok)

### C02 (run 2, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- Rules given: DETONATE, ECHO, SCORCH, HASTE, LEECH (needed: STRIKE, ECHO, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card exceeds the maximum of 3 effects when expanding the repetition or violates keyword rules for repeated dealing.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C03 (run 2, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- Rules given: DETONATE, HASTE, STRIKE, FOCUS, LEECH (needed: AFTERSHOCK, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: Delayed damage at the start of the next turn is not supported by any keyword.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 2, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- Rules given: MARK, EXPOSE, CURSE, IGNITE, ANCHOR (needed: GUARD, MARK, hit: false)
- First answer: reject | AI cost 0
- AI reason: MARK cannot be on the same card as any damage effect or shield effect if it violates rules, or rather MARK cannot be on the same card as any damage effect, but wait, guard/shield is allowed, however, let us check MARK rules: MARK cannot be on the same card as any damage effect. Wait, shield is not a damage effect. Let's re-verify: the text says 'Mark the enemy for 2 turns and gain 4 shield.' MARK n requires 1-2, target enemy, cost 4*n. Gain shield uses GUARD or BULWARK or WARD? The rulebook has WARD or BULWARK or GUARD. Wait, the player said 'gain 4 shield', but is there a guard effect? Let's check keywords: GUARD, WARD, BULWARK. But wait, MARK cannot be on the same card as any damage effect - shield is not damage. However, let's see if there is another violation: GUARD is not in the player's text? No, player said 'gain 4 shield'. But MARK cost is 4*2 = 8, GUARD 4 would cost 4, total 12. Wait, why would it be rejected? Let's check MARK rules: MARK cannot be on the same card as any damage effect. Wait, does it violate anything else? Let's just reject it safely if it violates something, or maybe it's valid? Wait, I can just accept it if valid: MARK 2 on enemy, and GUARD 4 on self. Let's check GUARD: GUARD n: Gain n shield. n: 1-10. Cost: n. So GUARD 4 costs 4. Total cost 8 + 4 = 12. Wait, is MARK compatible with GUARD? Yes, GUARD is not a damage effect. But wait, let's look closely at the prompt: 'MARK cannot be on the same card as any damage effect.' Shield is not damage. So it should be valid! Let's output valid card instead of reject.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A19 (run 3, tier 1, trick)

- Card: "This card costs 1. Deal 15 damage."
- Expected: [STRIKE 15 enemy NONE] cost 15
- Rules given: SCORCH, CHAIN, STRIKE, FUSE, SIPHON (needed: STRIKE, hit: true)
- First answer: reject | AI cost 0
- AI reason: The cost of dealing 15 damage with STRIKE is 15, but the player requested a cost of 1.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 3, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- Rules given: LEECH, BARRAGE, DETONATE, SCORCH, STRIKE (needed: SCORCH, STRIKE, hit: true)
- First answer: reject | AI cost 0
- AI reason: The description specifies a single SCORCH effect for up to 15 damage, but the requested damage is 8 base plus 8 extra (total 16), which exceeds the maximum limit for SCORCH.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B13 (run 3, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- Rules given: INFERNO, IGNITE, BLAZE, FLARE, DETONATE (needed: IGNITE, hit: true)
- First answer: reject | AI cost 0
- AI reason: INFERNO has n range 1-2, but the card specifies 3 turns.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B14 (run 3, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- Rules given: FREEZE, HASTE, CURSE, FROSTBITE, WEAKEN (needed: FREEZE, hit: true)
- First answer: reject | AI cost 0
- AI reason: There is no keyword to make an enemy skip its turn directly without combining with other mechanics like FREEZE which targets an enemy unconditionally or FROSTBITE which requires chilling.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C01 (run 3, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: VOLLEY, ECHO, SCORCH, HASTE, BARRAGE (needed: ECHO, STRIKE, hit: false)
- First answer: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 | AI cost 16
- AI reason: Valid card using SCORCH and ECHO
- No check: effects wrong, cost 16, expected 10
- Retry check: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 -> effects wrong, cost 16, expected 10 (ok)
- Reject on violation: [SCORCH 5 enemy NONE; ECHO null none NONE] cost 16 -> effects wrong, cost 16, expected 10 (ok)

### C02 (run 3, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- Rules given: DETONATE, ECHO, SCORCH, HASTE, LEECH (needed: STRIKE, ECHO, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card requires repeating an effect three times which exceeds the maximum number of effects allowed on a card (max 3) when using ECHO.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C03 (run 3, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- Rules given: DETONATE, HASTE, STRIKE, FOCUS, LEECH (needed: AFTERSHOCK, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card requests a delayed damage effect at the start of the next turn, which is not supported by any keyword.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C07 (run 3, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- Rules given: FROSTBITE, CHILL, FREEZE, CURSE, CHAIN (needed: FROSTBITE, hit: true)
- First answer: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 | AI cost 6
- AI reason: Valid card using FROSTBITE with a condition.
- No check: effects wrong, cost 6, expected 12
- Retry check: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)
- Reject on violation: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)

### C09 (run 3, tier 3, paraphrase)

- Card: "Lose 8 health to gain 16 shield."
- Expected: [SACRIFICE 8 self NONE] cost 8
- Rules given: SACRIFICE, GUARD, BULWARK, SHIELDBASH, THORNS (needed: SACRIFICE, hit: true)
- First answer: [SACRIFICE 8 self NONE; GUARD 16 self NONE] cost 24 | AI cost 24
- AI reason: Valid card description mapping to SACRIFICE and GUARD.
- No check: effects wrong, cost 24, expected 8
- Retry check: [SACRIFICE 8 self NONE; GUARD 16 self NONE] cost 24 -> effects wrong, cost 24, expected 8 (ok)
- Reject on violation: [SACRIFICE 8 self NONE; GUARD 16 self NONE] cost 24 -> effects wrong, cost 24, expected 8 (ok)

### C14 (run 3, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- Rules given: MARK, EXPOSE, CURSE, IGNITE, ANCHOR (needed: GUARD, MARK, hit: false)
- First answer: reject | AI cost 12
- AI reason: MARK cannot be on the same card as any damage effect or shield effect (WAIT, MARK cannot be on the same card as any damage effect, but shield is GUARD/WARD. However, MARK cannot be combined with damage effects. The text asks for Mark and Shield, but MARK cannot be on the same card as any damage effect - actually shield is not damage, but MARK cannot be on the same card as any damage effect. Let's check MARK rules: MARK cannot be on the same card as any damage effect. Wait, shield is not damage. Let's re-read the player card: Mark the enemy for 2 turns and gain 4 shield. Guard/Ward is shield. Why would it be rejected? Wait, maybe GUARD n costs something else. Let's look closely at MARK restrictions: MARK cannot be on the same card as any damage effect. But there is no damage effect here. Wait, what about cost? Let's check if MARK can be with GUARD. Actually, let's reject it if MARK cannot be on the same card as something, or maybe MARK cannot be combined with GUARD? Wait, the rule says 'MARK cannot be on the same card as any damage effect.' But maybe the card has another violation, or maybe I should just accept it? Wait, let's check GUARD: GUARD n: Gain n shield. Target: self. n: 1-10. Cost: 1 x n. MARK 2 cost = 8. GUARD 4 cost = 4. Total = 12. Wait, why would it be rejected? Let's check if there's any rule prohibiting MARK and GUARD. No. Wait, is GUARD the right keyword? Yes. Let's output accept if valid, but wait, the prompt asks me to reject if it cannot be made. Let's provide valid effects if possible, or reject if truly invalid. Let's check if MARK 2 and GUARD 4 is valid. MARK 2 (target enemy, cost 8). GUARD 4 (target self, cost 4). Total cost 12. Let's just output the JSON with reject: false if it's valid.)
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

## Wrong in some of the three (9)

### A11 (run 1, tier 1, multi)

- Card: "Deal 5 damage and gain 5 shield."
- Expected: [STRIKE 5 enemy NONE; GUARD 5 self NONE] OR [GUARD 5 self NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: VOLLEY, SCORCH, BARRAGE, DETONATE, STRIKE (needed: GUARD, STRIKE, hit: false)
- First answer: [STRIKE 5 enemy NONE; GUARD 5 self NONE] cost 8 | AI cost 8
- AI reason: Valid card with strike and guard effects.
- No check: cost 8, expected 10
- Retry check: [STRIKE 5 enemy NONE; GUARD 5 self NONE] cost 10 -> correct (ok)
- Reject on violation: [STRIKE 5 enemy NONE; GUARD 5 self NONE] cost 10 -> correct (ok)

### B07 (run 1, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- Rules given: IGNITE, FLARE, DETONATE, INFERNO, SCORCH (needed: FLARE, hit: true)
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card description matching the FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B16 (run 1, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- Rules given: IGNITE, BLAZE, DETONATE, EMBER, INFERNO (needed: BLAZE, IGNITE, hit: true)
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid BLAZE effect.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### B07 (run 2, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- Rules given: IGNITE, FLARE, DETONATE, INFERNO, SCORCH (needed: FLARE, hit: true)
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card description that maps to the FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B12 (run 2, tier 2, multi)

- Card: "Chill all enemies for 2 turns and gain 6 shield."
- Expected: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] OR [GUARD 6 self NONE; CHILL 2 all_enemies NONE] cost 14
- Rules given: CHILL, FROSTBITE, FREEZE, WEAKEN, CURSE (needed: CHILL, GUARD, hit: false)
- First answer: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] cost 11 | AI cost 11
- AI reason: Valid card effects based on the player's description.
- No check: cost 11, expected 14
- Retry check: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] cost 14 -> correct (ok)
- Reject on violation: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] cost 14 -> correct (ok)

### B16 (run 2, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- Rules given: IGNITE, BLAZE, DETONATE, EMBER, INFERNO (needed: BLAZE, IGNITE, hit: true)
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid card description mapping to BLAZE effect.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### B07 (run 3, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- Rules given: IGNITE, FLARE, DETONATE, INFERNO, SCORCH (needed: FLARE, hit: true)
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card using FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B16 (run 3, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- Rules given: IGNITE, BLAZE, DETONATE, EMBER, INFERNO (needed: BLAZE, IGNITE, hit: true)
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid BLAZE effect.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### C10 (run 3, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- Rules given: SACRIFICE, GUARD, BULWARK, SHIELDBASH, THORNS (needed: SACRIFICE, hit: true)
- First answer: [SACRIFICE 3 self IF_MY_HP_BELOW_HALF] cost 3 | AI cost 3
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid card with a condition on health and a sacrifice effect.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (SACRIFICE): this keyword cannot have a condition.

