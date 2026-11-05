# Big rulebook review: gemini gemini-3.5-flash-lite, size 66, mode full

Written 2026-11-05 04:24:23. Every card that was wrong in at least one of the two scorings (errors included).

## Wrong with and without the check (29)

### A05 (run 1, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 7
- AI reason: VOLley n deals 1 damage n times, but the damage per hit must be 1 and n is between 2 and 10. The player asked for 6 arrows dealing 1 damage, which fits VOLLEY 6. However, VOLLEY 6 has a cost of 6 + 1 = 7. Wait, VOLLEY's n range is 2-10, and it deals 1 damage n times to 'one enemy'. The player text matches VOLLEY 6. Let us re-verify VOLLEY rule: VOLLEY n: Deal 1 damage n times. Target: one enemy. n: 2-10. Cost: n + 1. Since n=6, cost = 7. It is valid. Why would it be rejected? Let me re-read carefully: 'Fire 6 arrows at the enemy, each dealing 1 damage.' This is VOLLEY 6. Let's output it as valid instead.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### A07 (run 1, tier 1, paraphrase)

- Card: "Store up 2 extra energy for my next turn."
- Expected: [FOCUS 2 self NONE] cost 4
- First answer: reject | AI cost 0
- AI reason: There is no keyword to store extra energy for a future turn; FOCUS gives extra energy next turn and RALLY gives energy right now.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 1, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- First answer: [STRIKE 8 enemy NONE; SCORCH 8 enemy IF_ENEMY_BURNING] cost 20 | AI cost 20
- AI reason: Valid card using STRIKE and SCORCH
- No check: effects wrong, cost 20, expected 12
- With check: [STRIKE 8 enemy NONE; SCORCH 8 enemy IF_ENEMY_BURNING] cost 14 -> effects wrong, cost 14, expected 12 (ok)

### B10 (run 1, tier 2, paraphrase)

- Card: "Hit one enemy for 7, then the attack bounces to a second enemy for 5."
- Expected: [CHAIN 7 enemy NONE] cost 14
- First answer: reject | AI cost 0
- AI reason: The card requests Chain with 7 damage and 5 damage, but CHAIN n deals n damage and n minus 2 damage, so n must be 7 which yields 5 damage, but the player specified 7 then 5 which requires n=7 and n=5 simultaneously.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 1, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: The poison keyword deals n health loss at the end of each turn for 3 turns, not 4 a turn, and the requested duration/rate does not match valid POISON or VENOM parameters.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: [STRIKE 6 enemy NONE; ECHO null none NONE; ECHO null none NONE] cost 18 | AI cost 18
- First answer breaks: ECHO max per card
- AI reason: Card is valid with a strike followed by two echoes.
- No check: effects wrong
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> rejected, but the card can be made (ai_reject)

### C04 (run 1, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [GUARD 5 self NONE; AFTERSHOCK 5 enemy NONE] cost 10 | AI cost 10
- First answer breaks: AFTERSHOCK needs damage
- AI reason: Valid card
- No check: should be rejected, but it was accepted
- Retry 1: [STRIKE 5 enemy NONE; AFTERSHOCK 5 enemy NONE] | code check: passed
- With check: [STRIKE 5 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 10 -> should be rejected, but it was accepted (ok)

### C06 (run 1, tier 3, condition_illegal)

- Card: "If I'm below half health, blow up the fire on the enemy."
- Expected: reject
- First answer: [DETONATE null enemy IF_MY_HP_BELOW_HALF] cost 3 | AI cost 3
- First answer breaks: DETONATE requires condition
- AI reason: Valid DETONATE effect with required condition.
- No check: should be rejected, but it was accepted
- Retry 1: [DETONATE null enemy IF_ENEMY_BURNING] | code check: passed
- With check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> should be rejected, but it was accepted (ok)

### C07 (run 1, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: The card attempts to combine FROSTBITE with a condition, but the effect rules are based on its internal condition check, or it conflicts with card design rules. Specifically, FROSTBITE already checks for chilling internally, but if it is interpreted as an effect, FROSTBITE has n: 1-10 and cost 2 x n = 12, but it cannot combine with FREEZE (which this describes). Alternatively, 'loses its next turn' corresponds to FREEZE, but the text combines it into one FROSTBITE effect.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 1, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- First answer: reject | AI cost 12
- AI reason: MARK cannot be on the same card as any damage effect, but wait, guard is not damage. However, MARK cannot be on the same card as any damage effect. Wait, guard is not damage, but MARK cannot be on the same card as any damage effect? Actually, let's check MARK rules: MARK cannot be on the same card as any damage effect. But Guard is a shield effect. Wait, let's look at why it's rejected: MARK description says MARK cannot be on the same card as any damage effect, but the card has MARK and GUARD. Is GUARD damage? No. Wait, let's check if MARK requires something else or if there's another reason. Actually, MARK description says: MARK cannot be on the same card as any damage effect. Guard is not a damage effect. Wait, let's check if the player card has any issue. Mark for 2 turns (MARK 2, cost 4*2=8) and gain 4 shield (GUARD 4, cost 4). Total cost 12. Wait, why would it be rejected? Let's check MARK n: 1-2. Cost 4 x n. Guard n: 1-30. Cost n. Both effects are valid. But wait, is there any rule broken? No. Wait, let's provide the valid JSON if it's not rejected, or set reject to false.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### A05 (run 2, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 7
- AI reason: VOLLEY deals 1 damage n times, where n is 2-10, but the damage dealt per hit is fixed at 1. The player specified 6 arrows dealing 1 damage, which fits VOLLEY 6. However, VOLLEY targets one enemy, and the cost for VOLLEY 6 is 6 + 1 = 7. Let's check the rules again. VOLLEY n: Deal 1 damage n times. Target: one enemy. n: 2-10. Cost: n + 1. The player's text matches VOLLEY 6. Wait, let's verify if VOLLEY is valid. Yes, VOLLEY 6 is valid. Let me re-read the player prompt carefully: 'Fire 6 arrows at the enemy, each dealing 1 damage.' This matches VOLLEY 6. Target: enemy. Cost: 7. Let's generate it instead of rejecting.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### A07 (run 2, tier 1, paraphrase)

- Card: "Store up 2 extra energy for my next turn."
- Expected: [FOCUS 2 self NONE] cost 4
- First answer: reject | AI cost 0
- AI reason: There is no keyword to store extra energy for next turn without taking 3 damage (OVERCHARGE requires taking damage, and FOCUS gives 1 to 3 energy instantly but RALLY gives energy right now, while extra energy for next turn specifically doesn't match available keywords cleanly or exceeds valid amounts).
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### B10 (run 2, tier 2, paraphrase)

- Card: "Hit one enemy for 7, then the attack bounces to a second enemy for 5."
- Expected: [CHAIN 7 enemy NONE] cost 14
- First answer: [STRIKE 7 enemy NONE; CHAIN 7 enemy NONE] cost 21 | AI cost 21
- AI reason: Valid card description mapping to STRIKE and CHAIN.
- No check: effects wrong, cost 21, expected 14
- With check: [STRIKE 7 enemy NONE; CHAIN 7 enemy NONE] cost 21 -> effects wrong, cost 21, expected 14 (ok)

### B13 (run 2, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 15 | AI cost 15
- First answer breaks: INFERNO n range
- AI reason: Valid card
- No check: effects wrong, cost 15, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 2, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: POISON keyword does not take a per-turn amount in that way and the description is malformed
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 2, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: The card asks for more than 3 effects (Strike, Echo, Echo)
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### C04 (run 2, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 | AI cost 6
- AI reason: Valid card with AFTERSHOCK and a damage effect.
- No check: should be rejected, but it was accepted
- With check: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 -> should be rejected, but it was accepted (ok)

### C06 (run 2, tier 3, condition_illegal)

- Card: "If I'm below half health, blow up the fire on the enemy."
- Expected: reject
- First answer: [DETONATE null enemy IF_MY_HP_BELOW_HALF] cost 3 | AI cost 3
- First answer breaks: DETONATE requires condition
- AI reason: Valid card detonate
- No check: should be rejected, but it was accepted
- Retry 1: [DETONATE null enemy IF_ENEMY_BURNING] | code check: passed
- With check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> should be rejected, but it was accepted (ok)

### C07 (run 2, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: [STRIKE 6 enemy NONE; FROSTBITE 0 enemy IF_ENEMY_CHILLED] cost 6 | AI cost 6
- First answer breaks: FROSTBITE n range
- AI reason: Valid card using STRIKE and FROSTBITE.
- No check: effects wrong, cost 6, expected 12
- Retry 1: [STRIKE 6 enemy NONE; FROSTBITE 1 enemy IF_ENEMY_CHILLED] | code check: passed
- With check: [STRIKE 6 enemy NONE; FROSTBITE 1 enemy IF_ENEMY_CHILLED] cost 7 -> effects wrong, cost 7, expected 12 (ok)

### C17 (run 2, tier 3, position)

- Card: "Gain 5 shield, then draw 3 cards and discard 3 at the end of the turn."
- Expected: [GUARD 5 self NONE; GAMBIT 3 self NONE] cost 8
- First answer: [GUARD 5 self NONE; DRAW 3 self NONE; GAMBIT 3 self NONE] cost 14 | AI cost 14
- AI reason: Valid card with guard, draw and gambit effects.
- No check: effects wrong, cost 14, expected 8
- With check: [GUARD 5 self NONE; DRAW 3 self NONE; GAMBIT 3 self NONE] cost 14 -> effects wrong, cost 14, expected 8 (ok)

### A05 (run 3, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 7
- AI reason: VOLLEY damage per hit must be 1, but VOLLEY rule says deal 1 damage n times for n damage total, however VOLLEY n range is 2-10 for n total damage. Wait, the description says 6 arrows each dealing 1 damage, but VOLLEY deals 1 damage n times, meaning total n damage. Here n=6 is valid for VOLLEY (range 2-10), and the cost would be 6 + 1 = 7. Let me re-verify VOLLEY rule: VOLLEY n: Deal 1 damage n times. Target: one enemy. n: 2-10. Cost: n + 1. So 'Fire 6 arrows at the enemy, each dealing 1 damage' is valid for VOLLEY 6.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### A07 (run 3, tier 1, paraphrase)

- Card: "Store up 2 extra energy for my next turn."
- Expected: [FOCUS 2 self NONE] cost 4
- First answer: reject | AI cost 0
- AI reason: There is no keyword to store extra energy for a future turn; FOCUS gives extra energy next turn and RALLY gives energy right now, but there is no store mechanic.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### B13 (run 3, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 15 | AI cost 15
- First answer breaks: INFERNO n range
- AI reason: Valid card
- No check: effects wrong, cost 15, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 3, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: The poison keyword deals n health loss per turn for 3 turns, but the player requested '4 a turn' which is outside the keyword rule.
- No check: rejected, but the card can be made
- With check: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 3, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: [STRIKE 6 enemy NONE; ECHO null none NONE; ECHO null none NONE] cost 18 | AI cost 18
- First answer breaks: ECHO max per card
- AI reason: Valid card using STRIKE and ECHO effects.
- No check: effects wrong
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> rejected, but the card can be made (ai_reject)

### C04 (run 3, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 | AI cost 6
- AI reason: Valid card with AFTERSHOCK and a damage effect.
- No check: should be rejected, but it was accepted
- With check: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 -> should be rejected, but it was accepted (ok)

### C06 (run 3, tier 3, condition_illegal)

- Card: "If I'm below half health, blow up the fire on the enemy."
- Expected: reject
- First answer: [DETONATE null enemy IF_MY_HP_BELOW_HALF] cost 3 | AI cost 3
- First answer breaks: DETONATE requires condition
- AI reason: Valid card with DETONATE effect and condition.
- No check: should be rejected, but it was accepted
- Retry 1: [DETONATE null enemy IF_ENEMY_BURNING] | code check: passed
- With check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> should be rejected, but it was accepted (ok)

### C07 (run 3, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 | AI cost 6
- AI reason: Valid card conversion
- No check: effects wrong, cost 6, expected 12
- With check: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)

### C17 (run 3, tier 3, position)

- Card: "Gain 5 shield, then draw 3 cards and discard 3 at the end of the turn."
- Expected: [GUARD 5 self NONE; GAMBIT 3 self NONE] cost 8
- First answer: [GUARD 5 self NONE; DRAW 3 self NONE; GAMBIT 3 self NONE] cost 14 | AI cost 14
- AI reason: Valid card effects and cost calculation
- No check: effects wrong, cost 14, expected 8
- With check: [GUARD 5 self NONE; DRAW 3 self NONE; GAMBIT 3 self NONE] cost 14 -> effects wrong, cost 14, expected 8 (ok)

## Wrong only without the check (the check fixed it) (18)

### B07 (run 1, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card using FLARE.
- No check: cost 5, expected 10
- With check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### C01 (run 1, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card using STRIKE and ECHO
- No check: cost 5, expected 10
- With check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C05 (run 1, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Valid detonate card
- No check: cost 6, expected 3
- With check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C10 (run 1, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- First answer: [SACRIFICE 6 self IF_MY_HP_BELOW_HALF] cost 6 | AI cost 6
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid card based on SACRIFICE
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> correct (ai_reject)

### C22 (run 1, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- First answer: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 5 | AI cost 5
- AI reason: Valid card using SHIELDBASH with condition
- No check: cost 5, expected 3
- With check: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)

### B07 (run 2, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card
- No check: cost 5, expected 10
- With check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B15 (run 2, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 13 | AI cost 13
- AI reason: Valid card
- No check: cost 13, expected 11
- With check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 2, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Card is valid.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> correct (ai_reject)

### C01 (run 2, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card using STRIKE and ECHO
- No check: cost 5, expected 10
- With check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C05 (run 2, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Valid card using Detonate with condition
- No check: cost 6, expected 3
- With check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C10 (run 2, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- First answer: [SACRIFICE 6 self IF_MY_HP_BELOW_HALF] cost 6 | AI cost 6
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid card
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> correct (ai_reject)

### B07 (run 3, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card with a single flare effect.
- No check: cost 5, expected 10
- With check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B15 (run 3, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 17 | AI cost 17
- AI reason: Valid card effects
- No check: cost 17, expected 11
- With check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### C01 (run 3, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card using STRIKE and ECHO
- No check: cost 5, expected 10
- With check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C05 (run 3, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Valid card
- No check: cost 6, expected 3
- With check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C10 (run 3, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- First answer: [SACRIFICE 6 self IF_MY_HP_BELOW_HALF] cost 6 | AI cost 6
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid card following all rules.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- With check: reject -> correct (ai_reject)

### C22 (run 3, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- First answer: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 5 | AI cost 5
- AI reason: Valid card using SHIELDBASH with condition
- No check: cost 5, expected 3
- With check: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)

### C24 (run 3, tier 3, trick)

- Card: "Deal 10 damage to all enemies. (Area damage is never doubled in cost.)"
- Expected: [STRIKE 10 all_enemies NONE] cost 20
- First answer: [STRIKE 10 all_enemies NONE] cost 10 | AI cost 10
- AI reason: Valid card with a single target all enemies strike effect.
- No check: cost 10, expected 20
- With check: [STRIKE 10 all_enemies NONE] cost 20 -> correct (ok)

## Wrong only with the check (0)

