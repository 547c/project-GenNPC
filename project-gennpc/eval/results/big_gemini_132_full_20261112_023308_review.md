# Big rulebook review: gemini gemini-3.5-flash-lite, size 132, mode full

Every card that was wrong in at least one of the three scorings (no check, retry, reject on violation); errors count as wrong. The lines of each card show all three.

## Wrong in all three (25)

### A17 (run 1, tier 1, illegal)

- Card: "Remove all negative effects from the enemy."
- Expected: reject
- First answer: [PURGE null enemy NONE] cost 4 | AI cost 4
- AI reason: Valid card using PURGE
- No check: should be rejected, but it was accepted
- Retry check: [PURGE null enemy NONE] cost 4 -> should be rejected, but it was accepted (ok)
- Reject on violation: [PURGE null enemy NONE] cost 4 -> should be rejected, but it was accepted (ok)

### B02 (run 1, tier 2, direct)

- Card: "Poison the enemy so it loses 3 health each turn for 3 turns."
- Expected: [POISON 3 enemy NONE] cost 6
- First answer: reject | AI cost 6
- AI reason: The POISON keyword deals n health loss per turn for 3 turns, but n can only be 1 to 5 and the user asks for 3 health loss which is valid, however POISON deals health loss at the end of each of its turns for 3 turns and the effect parameter n is the amount of health lost, but POISON n has n from 1 to 5. Wait, POISON 3 is valid (loss of 3 health), but POISON's rule states 'The target loses n health at the end of each of its turns, for 3 turns.' with n: 1-5. Let's check: POISON 3 costs 2 x 3 = 6. Target: one enemy. Condition: NONE.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B10 (run 1, tier 2, paraphrase)

- Card: "Hit one enemy for 7, then the attack bounces to a second enemy for 5."
- Expected: [CHAIN 7 enemy NONE] cost 14
- First answer: [STRIKE 7 enemy NONE; CHAIN 5 enemy NONE] cost 17 | AI cost 17
- AI reason: Valid card using STRIKE and CHAIN effects.
- No check: effects wrong, cost 17, expected 14
- Retry check: [STRIKE 7 enemy NONE; CHAIN 5 enemy NONE] cost 17 -> effects wrong, cost 17, expected 14 (ok)
- Reject on violation: [STRIKE 7 enemy NONE; CHAIN 5 enemy NONE] cost 17 -> effects wrong, cost 17, expected 14 (ok)

### B13 (run 1, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 8 | AI cost 8
- First answer breaks: INFERNO n range
- AI reason: Valid card using INFERNO with a condition.
- No check: effects wrong, cost 8, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (INFERNO): n must be a whole number from 1 to 2, but it is 3.

### B14 (run 1, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: The player requests skipping a turn based on poison, but no keyword does this specifically for poison (FREEZE skips a turn unconditionally, while FROSTBITE requires Chilled).
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 1, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: The POISON keyword applies a fixed amount of health loss at the end of each turn for 3 turns, rather than 'per a turn', and there is no POISON effect with n=4 that fits the description without violating rules.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: The card requires 3 effects (FLURRY or repeated STRIKE/VOLLEY), but the description asks for three separate strikes which exceeds effect limits or does not match available keywords correctly.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C04 (run 1, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 | AI cost 6
- AI reason: Valid card with Aftershock
- No check: should be rejected, but it was accepted
- Retry check: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 -> should be rejected, but it was accepted (ok)
- Reject on violation: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 -> should be rejected, but it was accepted (ok)

### C21 (run 1, tier 3, position)

- Card: "Burn the enemy for 2 turns, then make that status last 1 turn longer."
- Expected: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7
- First answer: reject | AI cost 0
- AI reason: The card asks for more effects than allowed or incorrect keyword order; CATALYST must be the first effect, but IGNITE should come first for the described interaction.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A17 (run 2, tier 1, illegal)

- Card: "Remove all negative effects from the enemy."
- Expected: reject
- First answer: [PURGE null enemy NONE] cost 4 | AI cost 4
- AI reason: Valid card description.
- No check: should be rejected, but it was accepted
- Retry check: [PURGE null enemy NONE] cost 4 -> should be rejected, but it was accepted (ok)
- Reject on violation: [PURGE null enemy NONE] cost 4 -> should be rejected, but it was accepted (ok)

### B02 (run 2, tier 2, direct)

- Card: "Poison the enemy so it loses 3 health each turn for 3 turns."
- Expected: [POISON 3 enemy NONE] cost 6
- First answer: reject | AI cost 6
- AI reason: The POISON keyword deals n health loss per turn for 3 turns, but n can only be 1-5 and the text asks for 3 health loss which is not how POISON parameters work (POISON n applies n damage, but text specifies 'loses 3 health each turn' which matches venom or specific amounts outside standard Poison n range/rules, wait, POISON n does damage equal to n. If player wants 3 health loss, n=3 is valid for POISON since n: 1-5. However, POISON standard description says 'The target loses n health at the end of each of its turns, for 3 turns.' Thus POISON 3 is valid. Let me re-read: Poison 3 is valid. Wait, is it rejected? Let's check: POISON 3 cost is 2 * 3 = 6. Target: one enemy. Condition: NONE. No other issues. Wait, I should not reject if it is valid. Let's make it valid.)
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B10 (run 2, tier 2, paraphrase)

- Card: "Hit one enemy for 7, then the attack bounces to a second enemy for 5."
- Expected: [CHAIN 7 enemy NONE] cost 14
- First answer: [STRIKE 7 enemy NONE; CHAIN 7 enemy NONE] cost 21 | AI cost 21
- AI reason: Valid card using STRIKE and CHAIN effects
- No check: effects wrong, cost 21, expected 14
- Retry check: [STRIKE 7 enemy NONE; CHAIN 7 enemy NONE] cost 21 -> effects wrong, cost 21, expected 14 (ok)
- Reject on violation: [STRIKE 7 enemy NONE; CHAIN 7 enemy NONE] cost 21 -> effects wrong, cost 21, expected 14 (ok)

### B13 (run 2, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 8 | AI cost 8
- First answer breaks: INFERNO n range
- AI reason: Valid card using INFERNO with a condition.
- No check: effects wrong, cost 8, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (INFERNO): n must be a whole number from 1 to 2, but it is 3.

### B14 (run 2, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: The card attempts to make an enemy skip its next turn using FREEZE, but FREEZE does not allow any conditions, and the player specified a condition ('If the enemy is poisoned').
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 2, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: The keyword POISON does not deal damage per turn as described for 4 turns in that exact syntax, or violates phrasing rules; POISON n has a fixed 3 turns and loses n health, whereas the text mismatch or invalid description makes POISON n invalid or the card has no valid match.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 2, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: The card asks for more than 3 effects.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C17 (run 2, tier 3, position)

- Card: "Gain 5 shield, then draw 3 cards and discard 3 at the end of the turn."
- Expected: [GUARD 5 self NONE; GAMBIT 3 self NONE] cost 8
- First answer: reject | AI cost 8
- AI reason: The card has 3 effects, but GAMBIT must be the last effect and RUMMAGE is used instead of GAMBIT, or the description specifies draw 3 and discard 3 which corresponds to GAMBIT 3, but GAMBIT requires no separate draw/discard or matches a different keyword structure. Actually, GAMBIT n draws n and discards n at the end of the turn, which fits 'Draw 3 cards and discard 3 at the end of the turn'. However, GUARD 5, then draw 3 cards... wait, GUARD has n: 1-30, cost 5. Then draw 3 and discard 3 at the end of the turn is GAMBIT 3. Let's check GAMBIT: Gambit n draws n and discards n at end of turn. That's 2 effects (GUARD 5 and GAMBIT 3). Total cost 5 + 3 = 8. Let's re-verify why it might be rejected or valid. Wait, GAMBIT 3 cost is n = 3. GUARD 5 cost is 5. Total cost 8. But is GAMBIT allowed? Yes. Wait, the prompt says 'Gain 5 shield, then draw 3 cards and discard 3 at the end of the turn.' This can be represented by GUARD 5 and GAMBIT 3. That's 2 effects. Why would it be rejected? Let's write the valid effects if it's not rejected: GUARD 5 (cost 5), GAMBIT 3 (cost 3). Total cost 8. Let's provide the valid JSON.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C21 (run 2, tier 3, position)

- Card: "Burn the enemy for 2 turns, then make that status last 1 turn longer."
- Expected: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7
- First answer: reject | AI cost 0
- AI reason: The card attempts to combine IGNITE and a duration-extending effect without proper formatting or exceeds allowed effects/rules constraints.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A17 (run 3, tier 1, illegal)

- Card: "Remove all negative effects from the enemy."
- Expected: reject
- First answer: [PURGE null enemy NONE] cost 4 | AI cost 4
- AI reason: Valid card using PURGE
- No check: should be rejected, but it was accepted
- Retry check: [PURGE null enemy NONE] cost 4 -> should be rejected, but it was accepted (ok)
- Reject on violation: [PURGE null enemy NONE] cost 4 -> should be rejected, but it was accepted (ok)

### B02 (run 3, tier 2, direct)

- Card: "Poison the enemy so it loses 3 health each turn for 3 turns."
- Expected: [POISON 3 enemy NONE] cost 6
- First answer: reject | AI cost 0
- AI reason: POISON n allows n between 1 and 5, but duration is fixed at 3 turns and the effect deals n health at the end of each turn, not 3 health.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B13 (run 3, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: [INFERNO 3 all_enemies IF_ENEMY_BURNING] cost 8 | AI cost 8
- First answer breaks: INFERNO n range
- AI reason: Valid card using INFERNO with the correct condition.
- No check: effects wrong, cost 8, expected 6
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (INFERNO): n must be a whole number from 1 to 2, but it is 3.

### B14 (run 3, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: The card asks to make the enemy skip its next turn (FREEZE), which has no whole number n value, but the condition 'If the enemy is poisoned' does not match FREEZE keyword requirements or lacks a valid effect mapping.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 3, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: POISON lasts 3 turns and does not deal damage per turn as described, and the card format does not match available keywords.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 3, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: The card requires 3 effects (Strike + 2 echoes, or Flurry with n out of range), but Flurry max n is 8 and total damage needed is 18, and echoing a Strike multiple times without matching effects is limited by rule limits.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C06 (run 3, tier 3, condition_illegal)

- Card: "If I'm below half health, blow up the fire on the enemy."
- Expected: reject
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 | AI cost 3
- AI reason: Valid card using DETONATE with the required condition.
- No check: should be rejected, but it was accepted
- Retry check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> should be rejected, but it was accepted (ok)
- Reject on violation: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> should be rejected, but it was accepted (ok)

## Wrong in some of the three (32)

### A14 (run 1, tier 1, condition)

- Card: "If this is my first card this turn, gain 2 energy right now."
- Expected: [RALLY 2 self IF_FIRST_CARD] cost 3
- First answer: [RALLY 2 self IF_FIRST_CARD] cost 2 | AI cost 2
- AI reason: Valid card with a condition on RALLY.
- No check: cost 2, expected 3
- Retry check: [RALLY 2 self IF_FIRST_CARD] cost 3 -> correct (ok)
- Reject on violation: [RALLY 2 self IF_FIRST_CARD] cost 3 -> correct (ok)

### A18 (run 1, tier 1, illegal)

- Card: "Gain 4 energy right now."
- Expected: reject
- First answer: [RALLY 4 self NONE] cost 12 | AI cost 12
- First answer breaks: RALLY n range
- AI reason: Valid card using RALLY
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (RALLY): n must be a whole number from 1 to 3, but it is 4.

### B07 (run 1, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card using FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B12 (run 1, tier 2, multi)

- Card: "Chill all enemies for 2 turns and gain 6 shield."
- Expected: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] OR [GUARD 6 self NONE; CHILL 2 all_enemies NONE] cost 14
- First answer: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] cost 10 | AI cost 10
- AI reason: Valid card
- No check: cost 10, expected 14
- Retry check: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] cost 14 -> correct (ok)
- Reject on violation: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] cost 14 -> correct (ok)

### B15 (run 1, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 13 | AI cost 13
- AI reason: Valid card with 3 effects.
- No check: cost 13, expected 11
- Retry check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)
- Reject on violation: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 1, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid card description using the BLAZE keyword.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### C01 (run 1, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card using STRIKE and ECHO
- No check: cost 5, expected 10
- Retry check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)
- Reject on violation: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C05 (run 1, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Valid card using DETONATE
- No check: cost 6, expected 3
- Retry check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)
- Reject on violation: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C06 (run 1, tier 3, condition_illegal)

- Card: "If I'm below half health, blow up the fire on the enemy."
- Expected: reject
- First answer: [DETONATE null enemy IF_MY_HP_BELOW_HALF] cost 3 | AI cost 3
- First answer breaks: DETONATE requires condition
- AI reason: Valid card using DETONATE with condition.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (DETONATE): the condition must be IF_ENEMY_BURNING.

### C10 (run 1, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- First answer: [SACRIFICE 6 self IF_MY_HP_BELOW_HALF] cost 6 | AI cost 6
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid card based on available keywords.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (SACRIFICE): this keyword cannot have a condition.

### C24 (run 1, tier 3, trick)

- Card: "Deal 10 damage to all enemies. (Area damage is never doubled in cost.)"
- Expected: [STRIKE 10 all_enemies NONE] cost 20
- First answer: [STRIKE 10 all_enemies NONE] cost 10 | AI cost 10
- AI reason: Valid card using STRIKE targeting all enemies with cost rule applied.
- No check: cost 10, expected 20
- Retry check: [STRIKE 10 all_enemies NONE] cost 20 -> correct (ok)
- Reject on violation: [STRIKE 10 all_enemies NONE] cost 20 -> correct (ok)

### A14 (run 2, tier 1, condition)

- Card: "If this is my first card this turn, gain 2 energy right now."
- Expected: [RALLY 2 self IF_FIRST_CARD] cost 3
- First answer: [RALLY 2 self IF_FIRST_CARD] cost 2 | AI cost 2
- AI reason: Valid card with one effect
- No check: cost 2, expected 3
- Retry check: [RALLY 2 self IF_FIRST_CARD] cost 3 -> correct (ok)
- Reject on violation: [RALLY 2 self IF_FIRST_CARD] cost 3 -> correct (ok)

### A18 (run 2, tier 1, illegal)

- Card: "Gain 4 energy right now."
- Expected: reject
- First answer: [RALLY 4 self NONE] cost 12 | AI cost 12
- First answer breaks: RALLY n range
- AI reason: Valid card using RALLY
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (RALLY): n must be a whole number from 1 to 3, but it is 4.

### B07 (run 2, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card using FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B15 (run 2, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 13 | AI cost 13
- AI reason: Valid card with three effects.
- No check: cost 13, expected 11
- Retry check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)
- Reject on violation: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 2, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid card using BLAZE.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### C01 (run 2, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card using STRIKE and ECHO
- No check: cost 5, expected 10
- Retry check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)
- Reject on violation: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C04 (run 2, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [AFTERSHOCK 5 enemy NONE] cost 5 | AI cost 5
- First answer breaks: AFTERSHOCK needs damage
- AI reason: Valid card with AFTERSHOCK effect.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (AFTERSHOCK) needs a damage effect on the same card.

### C06 (run 2, tier 3, condition_illegal)

- Card: "If I'm below half health, blow up the fire on the enemy."
- Expected: reject
- First answer: [DETONATE null enemy IF_MY_HP_BELOW_HALF] cost 3 | AI cost 3
- First answer breaks: DETONATE requires condition
- AI reason: Valid card using DETONATE with condition.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (DETONATE): the condition must be IF_ENEMY_BURNING.

### C10 (run 2, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- First answer: [SACRIFICE 6 self IF_MY_HP_BELOW_HALF] cost 3 | AI cost 3
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid card using SACRIFICE with condition.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (SACRIFICE): this keyword cannot have a condition.

### C15 (run 2, tier 3, cost_exception)

- Card: "If the enemy is burning, light a fuse that deals 6 at the end of its next turn."
- Expected: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9
- First answer: [FUSE 6 enemy IF_ENEMY_BURNING] cost 5 | AI cost 5
- AI reason: Valid card with a conditional FUSE effect.
- No check: cost 5, expected 9
- Retry check: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9 -> correct (ok)
- Reject on violation: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9 -> correct (ok)

### C24 (run 2, tier 3, trick)

- Card: "Deal 10 damage to all enemies. (Area damage is never doubled in cost.)"
- Expected: [STRIKE 10 all_enemies NONE] cost 20
- First answer: [STRIKE 10 all_enemies NONE] cost 10 | AI cost 10
- AI reason: Valid card description.
- No check: cost 10, expected 20
- Retry check: [STRIKE 10 all_enemies NONE] cost 20 -> correct (ok)
- Reject on violation: [STRIKE 10 all_enemies NONE] cost 20 -> correct (ok)

### A14 (run 3, tier 1, condition)

- Card: "If this is my first card this turn, gain 2 energy right now."
- Expected: [RALLY 2 self IF_FIRST_CARD] cost 3
- First answer: [RALLY 2 self IF_FIRST_CARD] cost 2 | AI cost 2
- AI reason: Valid card with one RALLY effect and condition IF_FIRST_CARD.
- No check: cost 2, expected 3
- Retry check: [RALLY 2 self IF_FIRST_CARD] cost 3 -> correct (ok)
- Reject on violation: [RALLY 2 self IF_FIRST_CARD] cost 3 -> correct (ok)

### A18 (run 3, tier 1, illegal)

- Card: "Gain 4 energy right now."
- Expected: reject
- First answer: [RALLY 4 self NONE] cost 12 | AI cost 12
- First answer breaks: RALLY n range
- AI reason: Valid RALLY card
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (RALLY): n must be a whole number from 1 to 3, but it is 4.

### B07 (run 3, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card description using FLARE
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B15 (run 3, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 13 | AI cost 13
- AI reason: Valid card description mapping to Ignite, Poison, and Expose.
- No check: cost 13, expected 11
- Retry check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)
- Reject on violation: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 3, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid card description using the BLAZE keyword.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### C01 (run 3, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card using STRIKE and ECHO
- No check: cost 5, expected 10
- Retry check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)
- Reject on violation: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C04 (run 3, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [AFTERSHOCK 5 enemy NONE] cost 5 | AI cost 5
- First answer breaks: AFTERSHOCK needs damage
- AI reason: Valid card description using AFTERSHOCK
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (AFTERSHOCK) needs a damage effect on the same card.

### C05 (run 3, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Successfully matched DETONATE effect with required condition.
- No check: cost 6, expected 3
- Retry check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)
- Reject on violation: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C15 (run 3, tier 3, cost_exception)

- Card: "If the enemy is burning, light a fuse that deals 6 at the end of its next turn."
- Expected: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9
- First answer: [FUSE 6 enemy IF_ENEMY_BURNING] cost 5 | AI cost 5
- AI reason: Valid card with conditional FUSE effect.
- No check: cost 5, expected 9
- Retry check: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9 -> correct (ok)
- Reject on violation: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9 -> correct (ok)

### C24 (run 3, tier 3, trick)

- Card: "Deal 10 damage to all enemies. (Area damage is never doubled in cost.)"
- Expected: [STRIKE 10 all_enemies NONE] cost 20
- First answer: [STRIKE 10 all_enemies NONE] cost 10 | AI cost 10
- AI reason: Valid STRIKE targeting all enemies
- No check: cost 10, expected 20
- Retry check: [STRIKE 10 all_enemies NONE] cost 20 -> correct (ok)
- Reject on violation: [STRIKE 10 all_enemies NONE] cost 20 -> correct (ok)

