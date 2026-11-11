# Big rulebook review: gemini gemini-3.5-flash-lite, size 66, mode emb9

Every card that was wrong in at least one of the three scorings (no check, retry, reject on violation); errors count as wrong. The lines of each card show all three.

## Wrong in all three (27)

### A11 (run 1, tier 1, multi)

- Card: "Deal 5 damage and gain 5 shield."
- Expected: [STRIKE 5 enemy NONE; GUARD 5 self NONE] OR [GUARD 5 self NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: BLOODPACT, EXECUTE, VOLLEY, SCORCH, BARRAGE (needed: GUARD, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card requests gaining 5 shield, but no valid keyword for gaining a specific shield amount is provided.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A19 (run 1, tier 1, trick)

- Card: "This card costs 1. Deal 15 damage."
- Expected: [STRIKE 15 enemy NONE] cost 15
- Rules given: EXECUTE, SCORCH, CHAIN, STRIKE, FUSE (needed: STRIKE, hit: true)
- First answer: reject | AI cost 0
- AI reason: The cost of STRIKE 15 is 15, but the player stated it costs 1. The cost must strictly follow the game rules.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B03 (run 1, tier 2, paraphrase)

- Card: "For 3 turns, the enemy's hits do a quarter less damage."
- Expected: [WEAKEN 3 enemy NONE] cost 6
- Rules given: RENEW, BERSERK, CURSE, FORTIFY, EXPOSE (needed: WEAKEN, hit: false)
- First answer: reject | AI cost 0
- AI reason: There is no keyword for reducing the enemy's damage output for several turns.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 1, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- Rules given: LEECH, EXECUTE, BARRAGE, BLOODPACT, DETONATE (needed: SCORCH, STRIKE, hit: false)
- First answer: [EXECUTE 8 enemy NONE; EXECUTE 8 enemy IF_ENEMY_BURNING] cost 22 | AI cost 22
- AI reason: Valid card with two effects
- No check: effects wrong, cost 22, expected 12
- Retry check: [EXECUTE 8 enemy NONE; EXECUTE 8 enemy IF_ENEMY_BURNING] cost 24 -> effects wrong, cost 24, expected 12 (ok)
- Reject on violation: [EXECUTE 8 enemy NONE; EXECUTE 8 enemy IF_ENEMY_BURNING] cost 24 -> effects wrong, cost 24, expected 12 (ok)

### B06 (run 1, tier 2, paraphrase)

- Card: "Hit for 6, and if the enemy isn't burning yet, it catches fire for a turn."
- Expected: [EMBER 6 enemy NONE] cost 9
- Rules given: IGNITE, EMBER, INFERNO, DETONATE, BLAZE (needed: EMBER, hit: true)
- First answer: [EMBER 4 enemy NONE] cost 6 | AI cost 6
- AI reason: Valid card description mapping directly to the EMBER effect.
- No check: effects wrong, cost 6, expected 9
- Retry check: [EMBER 4 enemy NONE] cost 6 -> effects wrong, cost 6, expected 9 (ok)
- Reject on violation: [EMBER 4 enemy NONE] cost 6 -> effects wrong, cost 6, expected 9 (ok)

### B13 (run 1, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- Rules given: INFERNO, IGNITE, BLAZE, FLARE, DETONATE (needed: IGNITE, hit: true)
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 8 | AI cost 8
- First answer breaks: INFERNO n range
- AI reason: Valid card description mapping directly to INFERNO with a condition.
- No check: effects wrong, cost 8, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (INFERNO): n must be a whole number from 1 to 2, but it is 3.

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- Rules given: DETONATE, ECHO, BLOODPACT, RENEW, EXECUTE (needed: STRIKE, ECHO, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card requires 3 distinct strike actions with repetition which exceeds the allowed effect count or keyword limitations for stacking without proper repetition mechanics like ECHO.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C03 (run 1, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- Rules given: EXECUTE, HASTE, DETONATE, RENEW, STRIKE (needed: AFTERSHOCK, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: Delayed damage effects like start of next turn are not supported by the available keywords.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 1, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- Rules given: MARK, EXPOSE, CURSE, IGNITE, ANCHOR (needed: GUARD, MARK, hit: false)
- First answer: reject | AI cost 12
- AI reason: MARK cannot be on the same card as any shield effect or other effects, and gain shield uses GUARD/BULWARK/WARD, but MARK cannot be combined with damage or other conflicting keywords. Actually, MARK cannot be on the same card as any damage effect, but shield is not damage. However, MARK has a restriction that it cannot be on the same card as certain things, or the text mixes MARK (a debuff) with shield. Wait, the card has MARK and gain 4 shield. MARK cannot be on the same card as any damage effect (shield is not damage). But gain shield would use WARD or GUARD. Let's check MARK rules: MARK cannot be on the same card as any damage effect. Shield is fine, but wait, does WARD or GUARD cost fit? 4 shield is WARD 4 or GUARD 4. Is there another reason? MARK cost 4 x 2 = 8. GUARD 4 costs 4. Total cost 12. But wait, MARK target is one enemy, WARD target is self. Can they be on the same card? Yes, different targets are allowed. However, the rule says: 'MARK cannot be on the same card as any damage effect.' Shield is not damage. Let's re-read carefully: 'Mark the enemy for 2 turns and gain 4 shield.' Wait, gain 4 shield is WARD 4 or GUARD 4. If it's valid, why reject? Wait, MARK target: enemy, WARD target: self. Wait, does MARK have a special rule? 'MARK cannot be on the same card as any damage effect.' Shield is not damage. But wait, maybe the player's card asks for something invalid? No, MARK 2 and WARD 4. Wait, shield is usually WARD or GUARD. Let's check if MARK can be with WARD. Yes. But maybe I should reject if the prompt implies a rejection due to rule violation? Wait, is there a violation? 'MARK cannot be on the same card as any damage effect.' There is no damage effect here. But wait, let's check if MARK is compatible. Wait, I can just accept it if it's valid: MARK 2 (cost 8) and WARD 4 (cost 4). Total cost 12. Let's output valid effects if possible. Wait, does shield use GUARD or WARD? GUARD n: Gain n Shield. n: 1-15. Cost: n. WARD n: Gain n Shield and draw 1 card. Wait, 'gain 4 shield' is GUARD 4. Let's use GUARD 4. Effects: MARK 2 (enemy, none) and GUARD 4 (self, none). Cost: 8 + 4 = 12.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C17 (run 1, tier 3, position)

- Card: "Gain 5 shield, then draw 3 cards and discard 3 at the end of the turn."
- Expected: [GUARD 5 self NONE; GAMBIT 3 self NONE] cost 8
- Rules given: FORTIFY, DRAW, DISCARD, GUARD, GAMBIT (needed: GAMBIT, GUARD, hit: true)
- First answer: [GUARD 5 self NONE; DRAW 3 self NONE; GAMBIT 3 self NONE] cost 14 | AI cost 14
- AI reason: Valid card effects using GUARD, DRAW, and GAMBIT.
- No check: effects wrong, cost 14, expected 8
- Retry check: [GUARD 5 self NONE; DRAW 3 self NONE; GAMBIT 3 self NONE] cost 14 -> effects wrong, cost 14, expected 8 (ok)
- Reject on violation: [GUARD 5 self NONE; DRAW 3 self NONE; GAMBIT 3 self NONE] cost 14 -> effects wrong, cost 14, expected 8 (ok)

### A11 (run 2, tier 1, multi)

- Card: "Deal 5 damage and gain 5 shield."
- Expected: [STRIKE 5 enemy NONE; GUARD 5 self NONE] OR [GUARD 5 self NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: BLOODPACT, EXECUTE, VOLLEY, SCORCH, BARRAGE (needed: GUARD, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: The player requested to gain 5 shield, but no valid shield-granting keyword was used in the rules or effects for this description.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B03 (run 2, tier 2, paraphrase)

- Card: "For 3 turns, the enemy's hits do a quarter less damage."
- Expected: [WEAKEN 3 enemy NONE] cost 6
- Rules given: RENEW, BERSERK, CURSE, FORTIFY, EXPOSE (needed: WEAKEN, hit: false)
- First answer: reject | AI cost 0
- AI reason: There is no keyword for reducing enemy damage by a fraction.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 2, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- Rules given: LEECH, EXECUTE, BARRAGE, BLOODPACT, DETONATE (needed: SCORCH, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card requires two damage effects, but a card can only have up to 3 effects total and the condition system doesn't support 'deal extra damage if burning' directly without a specific combo effect.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B06 (run 2, tier 2, paraphrase)

- Card: "Hit for 6, and if the enemy isn't burning yet, it catches fire for a turn."
- Expected: [EMBER 6 enemy NONE] cost 9
- Rules given: IGNITE, EMBER, INFERNO, DETONATE, BLAZE (needed: EMBER, hit: true)
- First answer: [EMBER 4 enemy NONE] cost 6 | AI cost 6
- AI reason: Valid card description mapping directly to the EMBER effect.
- No check: effects wrong, cost 6, expected 9
- Retry check: [EMBER 4 enemy NONE] cost 6 -> effects wrong, cost 6, expected 9 (ok)
- Reject on violation: [EMBER 4 enemy NONE] cost 6 -> effects wrong, cost 6, expected 9 (ok)

### B13 (run 2, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- Rules given: INFERNO, IGNITE, BLAZE, FLARE, DETONATE (needed: IGNITE, hit: true)
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 8 | AI cost 8
- First answer breaks: INFERNO n range
- AI reason: Valid card description mapping directly to INFERNO with a condition.
- No check: effects wrong, cost 8, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (INFERNO): n must be a whole number from 1 to 2, but it is 3.

### C02 (run 2, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- Rules given: DETONATE, ECHO, BLOODPACT, RENEW, EXECUTE (needed: STRIKE, ECHO, hit: false)
- First answer: reject | AI cost 0
- AI reason: ECHO cannot be used to repeat an effect twice or repeat a STRIKE effect in this manner.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C03 (run 2, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- Rules given: EXECUTE, HASTE, DETONATE, RENEW, STRIKE (needed: AFTERSHOCK, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card requests a delayed damage effect which is not supported by any available keyword.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 2, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- Rules given: MARK, EXPOSE, CURSE, IGNITE, ANCHOR (needed: GUARD, MARK, hit: false)
- First answer: reject | AI cost 0
- AI reason: MARK cannot be on the same card as any damage effect or shield effect (GUARD/WARD).
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A11 (run 3, tier 1, multi)

- Card: "Deal 5 damage and gain 5 shield."
- Expected: [STRIKE 5 enemy NONE; GUARD 5 self NONE] OR [GUARD 5 self NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: BLOODPACT, EXECUTE, VOLLEY, SCORCH, BARRAGE (needed: GUARD, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card combines damage and shield in a way that requires multiple keywords that do not cleanly match the requested single effects, or the simple combination of STRIKE and GUARD is expected. Wait, 'Deal 5 damage and gain 5 shield' can be made with STRIKE 5 (cost 3) and GUARD 5 (cost 5). Let's review if it's actually valid: STRIKE 5 is cost 3, GUARD 5 is cost 5. Total cost 8. Both are valid keywords. However, the parser can just map it to STRIKE 5 and GUARD 5.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A19 (run 3, tier 1, trick)

- Card: "This card costs 1. Deal 15 damage."
- Expected: [STRIKE 15 enemy NONE] cost 15
- Rules given: EXECUTE, SCORCH, CHAIN, STRIKE, FUSE (needed: STRIKE, hit: true)
- First answer: reject | AI cost 0
- AI reason: The cost of STRIKE 15 is 15, but the player stated it costs 1, and the cost must follow the game rules.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B03 (run 3, tier 2, paraphrase)

- Card: "For 3 turns, the enemy's hits do a quarter less damage."
- Expected: [WEAKEN 3 enemy NONE] cost 6
- Rules given: RENEW, BERSERK, CURSE, FORTIFY, EXPOSE (needed: WEAKEN, hit: false)
- First answer: reject | AI cost 0
- AI reason: There is no keyword for reducing enemy damage dealt.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 3, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- Rules given: LEECH, EXECUTE, BARRAGE, BLOODPACT, DETONATE (needed: SCORCH, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: The card requests conditional double damage which is not supported by a single EXECUTE effect with condition, or requires multiple effects exceeding rules.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B06 (run 3, tier 2, paraphrase)

- Card: "Hit for 6, and if the enemy isn't burning yet, it catches fire for a turn."
- Expected: [EMBER 6 enemy NONE] cost 9
- Rules given: IGNITE, EMBER, INFERNO, DETONATE, BLAZE (needed: EMBER, hit: true)
- First answer: [EMBER 4 enemy NONE] cost 6 | AI cost 6
- AI reason: Valid card description mapping directly to the EMBER effect.
- No check: effects wrong, cost 6, expected 9
- Retry check: [EMBER 4 enemy NONE] cost 6 -> effects wrong, cost 6, expected 9 (ok)
- Reject on violation: [EMBER 4 enemy NONE] cost 6 -> effects wrong, cost 6, expected 9 (ok)

### B13 (run 3, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- Rules given: INFERNO, IGNITE, BLAZE, FLARE, DETONATE (needed: IGNITE, hit: true)
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 8 | AI cost 8
- First answer breaks: INFERNO n range
- AI reason: Valid card description mapping directly to INFERNO effect with a condition.
- No check: effects wrong, cost 8, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (INFERNO): n must be a whole number from 1 to 2, but it is 3.

### C02 (run 3, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- Rules given: DETONATE, ECHO, BLOODPACT, RENEW, EXECUTE (needed: STRIKE, ECHO, hit: false)
- First answer: [STRIKE 6 enemy NONE; ECHO null none NONE; ECHO null none NONE] cost 18 | AI cost 18
- First answer breaks: ECHO max per card
- AI reason: Valid card using STRIKE and ECHO effects.
- No check: effects wrong
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: A card can have only 1 ECHO.

### C03 (run 3, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- Rules given: EXECUTE, HASTE, DETONATE, RENEW, STRIKE (needed: AFTERSHOCK, STRIKE, hit: false)
- First answer: reject | AI cost 0
- AI reason: Delayed damage or effects at the start of the next turn like that are not supported by the available keywords.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 3, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- Rules given: MARK, EXPOSE, CURSE, IGNITE, ANCHOR (needed: GUARD, MARK, hit: false)
- First answer: reject | AI cost 12
- AI reason: MARK cannot be on the same card as any damage effect or shield effect (WAIT, shield is not a damage effect, but MARK cannot be on the same card as any damage effect. Wait, shield is GUARD or WARD, which are not damage effects, but the prompt says MARK cannot be on the same card as any damage effect. However, 'gain 4 shield' translates to GUARD 4. Is there a conflict? Wait, the player text says 'Mark the enemy for 2 turns and gain 4 shield.' GUARD 4 is valid, MARK 2 is valid. But let's check MARK rules: MARK cannot be on the same card as any damage effect. GUARD is not a damage effect. Let's re-read MARK: MARK 2 cost = 8. GUARD 4 cost = 4. Total cost = 12. Wait, why reject? Let's check MARK rules again. Does MARK conflict with shield? No. Is there any other rule broken? 'MARK cannot be on the same card as any damage effect.' GUARD is not damage. Wait, the prompt says MARK cannot be on the same card as any damage effect. Wait, 'gain 4 shield' is not damage. Is there any violation? Let's check if GUARD 4 works. Yes. So reject should be false? Wait, maybe MARK is incompatible with something else or I must reject because MARK cannot be paired with shield? No, shield is not a damage effect. Let's make it not rejected.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

## Wrong in some of the three (17)

### B07 (run 1, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- Rules given: IGNITE, FLARE, DETONATE, INFERNO, SCORCH (needed: FLARE, hit: true)
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card using FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B15 (run 1, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- Rules given: IGNITE, POISON, EXPOSE, INFERNO, VENOM (needed: EXPOSE, IGNITE, POISON, hit: true)
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 13 | AI cost 13
- AI reason: Valid card with ignite, poison, and expose effects.
- No check: cost 13, expected 11
- Retry check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)
- Reject on violation: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 1, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- Rules given: IGNITE, BLAZE, DETONATE, EMBER, INFERNO (needed: BLAZE, IGNITE, hit: true)
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Card successfully parsed into a BLAZE effect.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### C01 (run 1, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: BLOODPACT, ECHO, EXECUTE, RECYCLE, VOLLEY (needed: ECHO, STRIKE, hit: false)
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card using STRIKE and ECHO
- No check: cost 5, expected 10
- Retry check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)
- Reject on violation: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C05 (run 1, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- Rules given: DETONATE, FLARE, BLAZE, FUSE, EMBER (needed: DETONATE, hit: true)
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Valid card using DETONATE.
- No check: cost 6, expected 3
- Retry check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)
- Reject on violation: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C10 (run 1, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- Rules given: SACRIFICE, GUARD, BANDAGE, BULWARK, FORTIFY (needed: SACRIFICE, hit: true)
- First answer: [SACRIFICE 6 self IF_MY_HP_BELOW_HALF] cost 6 | AI cost 6
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid card using SACRIFICE with a condition
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (SACRIFICE): this keyword cannot have a condition.

### A14 (run 2, tier 1, condition)

- Card: "If this is my first card this turn, gain 2 energy right now."
- Expected: [RALLY 2 self IF_FIRST_CARD] cost 3
- Rules given: RALLY, OVERCHARGE, FOCUS, RENEW, HASTE (needed: RALLY, hit: true)
- First answer: [RALLY 2 self IF_FIRST_CARD] cost 2 | AI cost 2
- AI reason: Valid card with one conditional effect.
- No check: cost 2, expected 3
- Retry check: [RALLY 2 self IF_FIRST_CARD] cost 3 -> correct (ok)
- Reject on violation: [RALLY 2 self IF_FIRST_CARD] cost 3 -> correct (ok)

### B07 (run 2, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- Rules given: IGNITE, FLARE, DETONATE, INFERNO, SCORCH (needed: FLARE, hit: true)
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card using FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B16 (run 2, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- Rules given: IGNITE, BLAZE, DETONATE, EMBER, INFERNO (needed: BLAZE, IGNITE, hit: true)
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Card converted successfully.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### C01 (run 2, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: BLOODPACT, ECHO, EXECUTE, RECYCLE, VOLLEY (needed: ECHO, STRIKE, hit: false)
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card description mapping to STRIKE and ECHO
- No check: cost 5, expected 10
- Retry check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)
- Reject on violation: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C22 (run 2, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- Rules given: SHIELDBASH, SHATTER, PIERCE, GUARD, STRIKE (needed: SHIELDBASH, hit: true)
- First answer: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 5 | AI cost 5
- AI reason: Valid card description mapping directly to the SHIELDBASH effect.
- No check: cost 5, expected 3
- Retry check: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)
- Reject on violation: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)

### B07 (run 3, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- Rules given: IGNITE, FLARE, DETONATE, INFERNO, SCORCH (needed: FLARE, hit: true)
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card using FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B15 (run 3, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- Rules given: IGNITE, POISON, EXPOSE, INFERNO, VENOM (needed: EXPOSE, IGNITE, POISON, hit: true)
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 13 | AI cost 13
- AI reason: Valid card description mapping to IGNITE, POISON, and EXPOSE.
- No check: cost 13, expected 11
- Retry check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)
- Reject on violation: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 3, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- Rules given: IGNITE, BLAZE, DETONATE, EMBER, INFERNO (needed: BLAZE, IGNITE, hit: true)
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Successfully matched player card to BLAZE keyword.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### C01 (run 3, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- Rules given: BLOODPACT, ECHO, EXECUTE, RECYCLE, VOLLEY (needed: ECHO, STRIKE, hit: false)
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 6 | AI cost 6
- AI reason: Valid card with strike and echo.
- No check: cost 6, expected 10
- Retry check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)
- Reject on violation: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C05 (run 3, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- Rules given: DETONATE, FLARE, BLAZE, FUSE, EMBER (needed: DETONATE, hit: true)
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Valid DETONATE card targeting burning enemy
- No check: cost 6, expected 3
- Retry check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)
- Reject on violation: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C10 (run 3, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- Rules given: SACRIFICE, GUARD, BANDAGE, BULWARK, FORTIFY (needed: SACRIFICE, hit: true)
- First answer: [SACRIFICE 6 self IF_MY_HP_BELOW_HALF] cost 6 | AI cost 6
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid card using SACRIFICE with a condition
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (SACRIFICE): this keyword cannot have a condition.

