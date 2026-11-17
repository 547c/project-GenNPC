# Big rulebook review: gemini gemini-3.5-flash-lite, size 47, mode full

Every card that was wrong in at least one of the three scorings (no check, retry, reject on violation); errors count as wrong. The lines of each card show all three.

## Wrong in all three (14)

### A05 (run 1, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 7
- AI reason: VOLLEY deals 1 damage n times with n from 2 to 10, but the damage cannot be 1 per hit (VOLLEY deals 1 damage n times, meaning each hit is 1 damage, which fits VOLLEY 6, but VOLLEY 6 deals 6 hits of 1 damage. The player states each dealing 1 damage, which matches VOLLEY n where n is 6). Wait, VOLLEY deals 1 damage n times, so VOLLEY 6 deals 1 damage 6 times. Let us check if VOLLEY is valid: VOLLEY 6 deals 1 damage 6 times, target enemy, cost 6 + 1 = 7. Let's see if VOLLEY is valid. VOLLEY n: Deal 1 damage n times. Target: one enemy. n: 2-10. Cost: n + 1. The player says 'Fire 6 arrows at the enemy, each dealing 1 damage.' This translates to VOLLEY 6. So it is not rejected.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B14 (run 1, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: There is no keyword that makes an enemy skip its next turn conditionally based on being poisoned; FREEZE makes an enemy skip its next turn but does not have a condition, and FROSTBITE requires Chill.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: [STRIKE 6 enemy NONE; ECHO null none NONE; ECHO null none NONE] cost 18 | AI cost 18
- First answer breaks: ECHO max per card
- AI reason: Valid card using STRIKE and ECHO
- No check: effects wrong
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: A card can have only 1 ECHO.

### C07 (run 1, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 | AI cost 6
- AI reason: Valid card using FROSTBITE.
- No check: effects wrong, cost 6, expected 12
- Retry check: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)
- Reject on violation: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)

### A05 (run 2, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 7
- AI reason: VOLley deals 1 damage n times, but n must be between 2 and 10 and target one enemy. Wait, 6 is in range (2-10). However, VOLLEY description states: Deal 1 damage n times. The player's text says 'Fire 6 arrows at the enemy, each dealing 1 damage', which matches VOLLEY 6. Let me recheck the cost and rules. VOLLEY 6 cost is n + 1 = 7. Is there anything wrong? No, VOLLEY 6 is valid. Let me output the correct card effects.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B14 (run 2, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: There is no keyword to make an enemy skip its next turn based on being poisoned; FREEZE makes an enemy skip its turn but does not require poison, and FROSTBITE requires chilled.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 2, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: [STRIKE 6 enemy NONE; ECHO null none NONE] cost 12 | AI cost 12
- AI reason: Valid card using STRIKE and ECHO
- No check: effects wrong, cost 12, expected 18
- Retry check: [STRIKE 6 enemy NONE; ECHO null none NONE] cost 12 -> effects wrong, cost 12, expected 18 (ok)
- Reject on violation: [STRIKE 6 enemy NONE; ECHO null none NONE] cost 12 -> effects wrong, cost 12, expected 18 (ok)

### C04 (run 2, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 | AI cost 6
- AI reason: Valid card with aftershock effect.
- No check: should be rejected, but it was accepted
- Retry check: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 -> should be rejected, but it was accepted (ok)
- Reject on violation: [STRIKE 1 enemy NONE; AFTERSHOCK 5 enemy NONE] cost 6 -> should be rejected, but it was accepted (ok)

### C07 (run 2, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 | AI cost 6
- AI reason: Valid card using FROSTBITE.
- No check: effects wrong, cost 6, expected 12
- Retry check: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)
- Reject on violation: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)

### A05 (run 3, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 7
- AI reason: VOLLEY deals 1 damage n times, but the damage cannot be 1 per hit; VOLLEY deals 1 damage n times as a volley, but each hit is fixed at 1 damage per hit. Wait, VOLLEY deals 1 damage n times, which matches the player's description. However, VOLley n has n from 2 to 10, costing n + 1. Let's check: VOLLEY 6 would cost 7. Why would this be rejected? The player says 'each dealing 1 damage', which is standard for VOLLEY n. Let us see if VOLLEY works. VOLLEY 6: 1 damage 6 times, target: enemy. Cost: 7. Wait, is VOLLEY allowed? Yes. Let's provide the card effects instead of rejecting, as it is a valid VOLLEY 6 card.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B14 (run 3, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: There is no keyword that makes an enemy skip its next turn based on being poisoned; FREEZE makes an enemy skip its turn but does not have a poison condition or take n.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 3, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: [STRIKE 6 enemy NONE; ECHO null none NONE; ECHO null none NONE] cost 18 | AI cost 18
- First answer breaks: ECHO max per card
- AI reason: Valid card using STRIKE and ECHO
- No check: effects wrong
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: A card can have only 1 ECHO.

### C04 (run 3, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [AFTERSHOCK 5 enemy NONE; STRIKE 5 enemy NONE] cost 10 | AI cost 10
- AI reason: Valid card with aftershock effect
- No check: should be rejected, but it was accepted
- Retry check: [AFTERSHOCK 5 enemy NONE; STRIKE 5 enemy NONE] cost 10 -> should be rejected, but it was accepted (ok)
- Reject on violation: [AFTERSHOCK 5 enemy NONE; STRIKE 5 enemy NONE] cost 10 -> should be rejected, but it was accepted (ok)

### C07 (run 3, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 | AI cost 6
- AI reason: Valid card using FROSTBITE.
- No check: effects wrong, cost 6, expected 12
- Retry check: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)
- Reject on violation: [FROSTBITE 6 enemy IF_ENEMY_CHILLED] cost 6 -> effects wrong, cost 6, expected 12 (ok)

## Wrong in some of the three (26)

### B07 (run 1, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card using FLARE keyword.
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B13 (run 1, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 15 | AI cost 15
- AI reason: Valid card
- No check: cost 15, expected 6
- Retry check: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6 -> correct (ok)
- Reject on violation: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6 -> correct (ok)

### B15 (run 1, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 13 | AI cost 13
- AI reason: Valid card effects generated successfully.
- No check: cost 13, expected 11
- Retry check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)
- Reject on violation: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 1, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid BLAZE effect.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (BLAZE): n must be a whole number from 1 to 3, but it is 4.

### C01 (run 1, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 5 | AI cost 5
- AI reason: Valid card using Strike and Echo.
- No check: cost 5, expected 10
- Retry check: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)
- Reject on violation: [STRIKE 5 enemy NONE; ECHO null none NONE] cost 10 -> correct (ok)

### C04 (run 1, tier 3, combo_illegal)

- Card: "At the start of my next turn, deal 5 damage to the enemy."
- Expected: reject
- First answer: [GUARD 5 self NONE; AFTERSHOCK 5 enemy NONE] cost 10 | AI cost 10
- First answer breaks: AFTERSHOCK needs damage
- AI reason: Valid card with an aftershock effect.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 2 (AFTERSHOCK) needs a damage effect on the same card.

### C10 (run 1, tier 3, condition_illegal)

- Card: "If I'm below half health, trade 6 of my health for shield."
- Expected: reject
- First answer: [SACRIFICE 6 self IF_MY_HP_BELOW_HALF] cost 6 | AI cost 6
- First answer breaks: SACRIFICE forbids condition
- AI reason: Valid SACRIFICE effect with a condition.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (SACRIFICE): this keyword cannot have a condition.

### C18 (run 1, tier 3, combo_illegal)

- Card: "My next card costs 2 less, and I can play one extra card this turn."
- Expected: reject
- First answer: [QUICKEN null self NONE; HASTE null self NONE] cost 8 | AI cost 8
- First answer breaks: QUICKEN not with HASTE
- AI reason: Valid card effects generated successfully.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (QUICKEN) cannot be on the same card as HASTE.

### C22 (run 1, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- First answer: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 5 | AI cost 5
- AI reason: Valid card using SHIELDBASH with condition IF_I_HAVE_SHIELD.
- No check: cost 5, expected 3
- Retry check: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)
- Reject on violation: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)

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
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 17 | AI cost 17
- AI reason: Valid card effects successfully parsed.
- No check: cost 17, expected 11
- Retry check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)
- Reject on violation: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 2, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid BLAZE effect.
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

### C05 (run 2, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Valid DETONATE card.
- No check: cost 6, expected 3
- Retry check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)
- Reject on violation: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C18 (run 2, tier 3, combo_illegal)

- Card: "My next card costs 2 less, and I can play one extra card this turn."
- Expected: reject
- First answer: [QUICKEN null self NONE; HASTE null self NONE] cost 8 | AI cost 8
- First answer breaks: QUICKEN not with HASTE
- AI reason: The card has two valid effects: QUICKEN and HASTE.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (QUICKEN) cannot be on the same card as HASTE.

### C22 (run 2, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- First answer: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 5 | AI cost 5
- AI reason: Valid card based on SHIELDBASH keyword with correct condition.
- No check: cost 5, expected 3
- Retry check: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)
- Reject on violation: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)

### B07 (run 3, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: [FLARE 5 all_enemies NONE] cost 5 | AI cost 5
- AI reason: Valid card effect
- No check: cost 5, expected 10
- Retry check: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)
- Reject on violation: [FLARE 5 all_enemies NONE] cost 10 -> correct (ok)

### B11 (run 3, tier 2, paraphrase)

- Card: "Throw 5 bombs at random enemies, 2 damage each."
- Expected: [BARRAGE 5 all_enemies NONE] cost 20
- First answer: [BARRAGE 5 all_enemies NONE] cost 10 | AI cost 10
- AI reason: Valid card using BARRAGE
- No check: cost 10, expected 20
- Retry check: [BARRAGE 5 all_enemies NONE] cost 20 -> correct (ok)
- Reject on violation: [BARRAGE 5 all_enemies NONE] cost 20 -> correct (ok)

### B13 (run 3, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 15 | AI cost 15
- AI reason: Valid card based on instructions
- No check: cost 15, expected 6
- Retry check: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6 -> correct (ok)
- Reject on violation: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6 -> correct (ok)

### B15 (run 3, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 17 | AI cost 17
- AI reason: Valid card effects successfully parsed.
- No check: cost 17, expected 11
- Retry check: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)
- Reject on violation: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] cost 11 -> correct (ok)

### B16 (run 3, tier 2, illegal)

- Card: "Burn the enemy for 4 turns at 3 damage per turn."
- Expected: reject
- First answer: [BLAZE 4 enemy NONE] cost 12 | AI cost 12
- First answer breaks: BLAZE n range
- AI reason: Valid BLAZE effect.
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

### C05 (run 3, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: [DETONATE null enemy IF_ENEMY_BURNING] cost 6 | AI cost 6
- AI reason: Valid DETONATE card.
- No check: cost 6, expected 3
- Retry check: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)
- Reject on violation: [DETONATE null enemy IF_ENEMY_BURNING] cost 3 -> correct (ok)

### C16 (run 3, tier 3, special_illegal)

- Card: "Draw 3 cards and discard 3 at the end of the turn. Repeat it."
- Expected: reject
- First answer: [GAMBIT 3 self NONE; ECHO null none NONE] cost 3 | AI cost 3
- First answer breaks: GAMBIT must be last
- AI reason: Valid card following all rules.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (GAMBIT) must be the last effect.

### C18 (run 3, tier 3, combo_illegal)

- Card: "My next card costs 2 less, and I can play one extra card this turn."
- Expected: reject
- First answer: [QUICKEN null self NONE; HASTE null self NONE] cost 8 | AI cost 8
- First answer breaks: QUICKEN not with HASTE
- AI reason: Valid card effects
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (QUICKEN) cannot be on the same card as HASTE.

### C22 (run 3, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- First answer: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 5 | AI cost 5
- AI reason: Valid card based on SHIELDBASH keyword rules.
- No check: cost 5, expected 3
- Retry check: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)
- Reject on violation: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3 -> correct (ok)

