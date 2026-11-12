# Big rulebook review: ollama qwen3.5:9b, size 264, mode full

Every card that was wrong in at least one of the three scorings (no check, retry, reject on violation); errors count as wrong. The lines of each card show all three.

## Wrong in all three (123)

### A01 (run 1, tier 1, direct)

- Card: "Deal 9 damage."
- Expected: [STRIKE 9 enemy NONE] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A02 (run 1, tier 1, direct)

- Card: "Gain 12 shield."
- Expected: [GUARD 12 self NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A04 (run 1, tier 1, paraphrase)

- Card: "Drain 5 life from the enemy."
- Expected: [SIPHON 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A05 (run 1, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A06 (run 1, tier 1, paraphrase)

- Card: "Build a wall of 8 that stays until it breaks."
- Expected: [BULWARK 8 self NONE] cost 16
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A07 (run 1, tier 1, paraphrase)

- Card: "Store up 2 extra energy for my next turn."
- Expected: [FOCUS 2 self NONE] cost 4
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A08 (run 1, tier 1, paraphrase)

- Card: "Strip away all of the enemy's shield."
- Expected: [SHATTER null enemy NONE] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A09 (run 1, tier 1, paraphrase)

- Card: "Hit one enemy for 6, and the swing also catches the others for half."
- Expected: [CLEAVE 6 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A10 (run 1, tier 1, paraphrase)

- Card: "Look at the top 3 cards of my deck and put them back in the order I like."
- Expected: [SCRY 3 self NONE] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A11 (run 1, tier 1, multi)

- Card: "Deal 5 damage and gain 5 shield."
- Expected: [STRIKE 5 enemy NONE; GUARD 5 self NONE] OR [GUARD 5 self NONE; STRIKE 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A13 (run 1, tier 1, all_enemies)

- Card: "Deal 4 damage to every enemy."
- Expected: [STRIKE 4 all_enemies NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A14 (run 1, tier 1, condition)

- Card: "If this is my first card this turn, gain 2 energy right now."
- Expected: [RALLY 2 self IF_FIRST_CARD] cost 3
- First answer: reject | AI cost 0
- AI reason: The card text describes a single effect ('gain 2 energy right now' if played first). However, the keyword that matches this description is RALLY (which gains n energy), and its cost formula is '3 x n'. The player's text implies a specific outcome without specifying the cost calculation or the value of 'n' explicitly in a way that fits the standard 'RALLY' definition directly without assuming values. More critically, looking at the available keywords, there is no keyword that simply says 'Gain 2 energy right now' with a condition 'IF_FIRST_CARD'. The closest is RALLY (gain n energy) or SURGE (gain n energy now). If we assume the player meant to use RALLY with n=2, the cost would be 6. However, the prompt asks to turn the text into effects. The text says 'If this is my first card...'. No keyword has a condition 'IF_FIRST_CARD' except BACKSTAB (which deals damage) and LONE variants which have conditions like 'It only works if you played another card before it' or similar, but none match 'gain energy on first play'. Wait, let's re-read the rules. Conditions allowed: IF_ENEMY_BURNING, IF_ENEMY_CHILLED, IF_ENEMY_POISONED, IF_ENEMY_EXPOSED, IF_MY_HP_BELOW_HALF, IF_ENEMY_HP_BELOW_HALF, IF_FIRST_CARD, IF_I_HAVE_SHIELD. 'IF_FIRST_CARD' is a valid condition! But which keyword uses it? Looking at the list... BACKSTAB has 'If this is the first card you play this turn'. LONE variants have conditions like 'It only works if you played another card before it'. No standard keyword or LONE keyword uses 'IF_FIRST_CARD' for gaining energy. The only effect that triggers on 'first card' is BACKSTAB (damage). There is no keyword for 'Gain energy on first card'. Therefore, the requested effect cannot be made with existing keywords.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A15 (run 1, tier 1, condition)

- Card: "When I'm below half health, heal 14."
- Expected: [MEND 14 self IF_MY_HP_BELOW_HALF] cost 7
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A19 (run 1, tier 1, trick)

- Card: "This card costs 1. Deal 15 damage."
- Expected: [STRIKE 15 enemy NONE] cost 15
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B03 (run 1, tier 2, paraphrase)

- Card: "For 3 turns, the enemy's hits do a quarter less damage."
- Expected: [WEAKEN 3 enemy NONE] cost 6
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B04 (run 1, tier 2, paraphrase)

- Card: "Stop the enemy from healing for 2 turns."
- Expected: [CURSE 2 enemy NONE] cost 4
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 1, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B07 (run 1, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B08 (run 1, tier 2, paraphrase)

- Card: "Grow spikes: for 2 turns, anyone who hits me takes 4 damage."
- Expected: [THORNS 4 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B09 (run 1, tier 2, paraphrase)

- Card: "Block the next 2 bad effects someone puts on me."
- Expected: [WARD 2 self NONE] cost 6
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B10 (run 1, tier 2, paraphrase)

- Card: "Hit one enemy for 7, then the attack bounces to a second enemy for 5."
- Expected: [CHAIN 7 enemy NONE] cost 14
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B11 (run 1, tier 2, paraphrase)

- Card: "Throw 5 bombs at random enemies, 2 damage each."
- Expected: [BARRAGE 5 all_enemies NONE] cost 20
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B12 (run 1, tier 2, multi)

- Card: "Chill all enemies for 2 turns and gain 6 shield."
- Expected: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] OR [GUARD 6 self NONE; CHILL 2 all_enemies NONE] cost 14
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B13 (run 1, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B14 (run 1, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B15 (run 1, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 1, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C01 (run 1, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 1, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C03 (run 1, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: The card text describes two separate damage events (now and next turn) but does not specify a target. The available keywords for 'now' damage (STRIKE, PIERCE, etc.) require a target ('self' or 'enemy'). There is no keyword that deals damage to 'none'. Additionally, the 'AFTERSHOCK' keyword handles future damage but requires an immediate damage effect on the same card and a specific target. Since no valid combination of effects can fulfill the 'no target' requirement for damage, the card cannot be made.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C05 (run 1, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C07 (run 1, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C09 (run 1, tier 3, paraphrase)

- Card: "Lose 8 health to gain 16 shield."
- Expected: [SACRIFICE 8 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C11 (run 1, tier 3, cost_exception)

- Card: "Deal 6 damage to every enemy and heal myself by the total."
- Expected: [LEECH 6 all_enemies NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C12 (run 1, tier 3, cost_exception)

- Card: "Every enemy burns for 2 turns at 3 damage a turn."
- Expected: [INFERNO 2 all_enemies NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 1, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C15 (run 1, tier 3, cost_exception)

- Card: "If the enemy is burning, light a fuse that deals 6 at the end of its next turn."
- Expected: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C17 (run 1, tier 3, position)

- Card: "Gain 5 shield, then draw 3 cards and discard 3 at the end of the turn."
- Expected: [GUARD 5 self NONE; GAMBIT 3 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C19 (run 1, tier 3, paraphrase)

- Card: "Deal 3 damage for each different bad status on the enemy."
- Expected: [RESONATE 3 enemy NONE] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C20 (run 1, tier 3, position)

- Card: "Make the next status last longer, then poison the enemy for 3 a turn."
- Expected: [CATALYST null none NONE; POISON 3 enemy NONE] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C21 (run 1, tier 3, position)

- Card: "Burn the enemy for 2 turns, then make that status last 1 turn longer."
- Expected: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7
- First answer: reject | AI cost 0
- AI reason: The card text describes a sequence of events (apply Burning, then extend duration) but does not map to any single valid effect keyword or combination of keywords within the rules. Specifically, there is no keyword that applies 'Burning' and then automatically extends its duration as a secondary effect on the same card without an explicit condition or separate status effect slot. The closest mechanics are IGNITE/BLAZE (apply Burning) and CATALYST (extend next status), but they cannot be combined to achieve exactly this specific phrasing ('Burn... then make that status last longer') as a single coherent effect definition under the provided ruleset, nor can 'Burning' be extended by a separate effect on the same card in the way described without violating the 'must have at least one status effect' rule if using CATALYST incorrectly or simply not matching any keyword definition.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C22 (run 1, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C24 (run 1, tier 3, trick)

- Card: "Deal 10 damage to all enemies. (Area damage is never doubled in cost.)"
- Expected: [STRIKE 10 all_enemies NONE] cost 20
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A02 (run 2, tier 1, direct)

- Card: "Gain 12 shield."
- Expected: [GUARD 12 self NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A04 (run 2, tier 1, paraphrase)

- Card: "Drain 5 life from the enemy."
- Expected: [SIPHON 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A05 (run 2, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A06 (run 2, tier 1, paraphrase)

- Card: "Build a wall of 8 that stays until it breaks."
- Expected: [BULWARK 8 self NONE] cost 16
- First answer: reject | AI cost 0
- AI reason: The card text 'Build a wall of 8 that stays until it breaks' describes a shield effect with n=8. However, the provided keyword list does not contain a generic 'WALL' keyword. The closest keywords are BARRIER (gain n shield for every enemy), BULWARK (gain n shield that doesn't disappear until used up), GUARD (gain n shield that disappears next turn), ICEWALL (gain n shield with specific removal rules), or AEGIS (gain n shield while negative effects can't be put on you). None of these match the description 'stays until it breaks' exactly, and there is no keyword simply called 'WALL'. Additionally, if the user intended to use a specific existing keyword like BULWARK or ICEWALL, the text would need to specify which one. Since no valid keyword matches the description provided in the text, the card cannot be made.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A07 (run 2, tier 1, paraphrase)

- Card: "Store up 2 extra energy for my next turn."
- Expected: [FOCUS 2 self NONE] cost 4
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A08 (run 2, tier 1, paraphrase)

- Card: "Strip away all of the enemy's shield."
- Expected: [SHATTER null enemy NONE] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A09 (run 2, tier 1, paraphrase)

- Card: "Hit one enemy for 6, and the swing also catches the others for half."
- Expected: [CLEAVE 6 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A10 (run 2, tier 1, paraphrase)

- Card: "Look at the top 3 cards of my deck and put them back in the order I like."
- Expected: [SCRY 3 self NONE] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A11 (run 2, tier 1, multi)

- Card: "Deal 5 damage and gain 5 shield."
- Expected: [STRIKE 5 enemy NONE; GUARD 5 self NONE] OR [GUARD 5 self NONE; STRIKE 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A13 (run 2, tier 1, all_enemies)

- Card: "Deal 4 damage to every enemy."
- Expected: [STRIKE 4 all_enemies NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A14 (run 2, tier 1, condition)

- Card: "If this is my first card this turn, gain 2 energy right now."
- Expected: [RALLY 2 self IF_FIRST_CARD] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A15 (run 2, tier 1, condition)

- Card: "When I'm below half health, heal 14."
- Expected: [MEND 14 self IF_MY_HP_BELOW_HALF] cost 7
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A19 (run 2, tier 1, trick)

- Card: "This card costs 1. Deal 15 damage."
- Expected: [STRIKE 15 enemy NONE] cost 15
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B03 (run 2, tier 2, paraphrase)

- Card: "For 3 turns, the enemy's hits do a quarter less damage."
- Expected: [WEAKEN 3 enemy NONE] cost 6
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 2, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B07 (run 2, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B08 (run 2, tier 2, paraphrase)

- Card: "Grow spikes: for 2 turns, anyone who hits me takes 4 damage."
- Expected: [THORNS 4 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B09 (run 2, tier 2, paraphrase)

- Card: "Block the next 2 bad effects someone puts on me."
- Expected: [WARD 2 self NONE] cost 6
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B10 (run 2, tier 2, paraphrase)

- Card: "Hit one enemy for 7, then the attack bounces to a second enemy for 5."
- Expected: [CHAIN 7 enemy NONE] cost 14
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B11 (run 2, tier 2, paraphrase)

- Card: "Throw 5 bombs at random enemies, 2 damage each."
- Expected: [BARRAGE 5 all_enemies NONE] cost 20
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B12 (run 2, tier 2, multi)

- Card: "Chill all enemies for 2 turns and gain 6 shield."
- Expected: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] OR [GUARD 6 self NONE; CHILL 2 all_enemies NONE] cost 14
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B13 (run 2, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B14 (run 2, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B15 (run 2, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 2, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C01 (run 2, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 2, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C03 (run 2, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C05 (run 2, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C07 (run 2, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C09 (run 2, tier 3, paraphrase)

- Card: "Lose 8 health to gain 16 shield."
- Expected: [SACRIFICE 8 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C11 (run 2, tier 3, cost_exception)

- Card: "Deal 6 damage to every enemy and heal myself by the total."
- Expected: [LEECH 6 all_enemies NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 2, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C15 (run 2, tier 3, cost_exception)

- Card: "If the enemy is burning, light a fuse that deals 6 at the end of its next turn."
- Expected: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C17 (run 2, tier 3, position)

- Card: "Gain 5 shield, then draw 3 cards and discard 3 at the end of the turn."
- Expected: [GUARD 5 self NONE; GAMBIT 3 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C19 (run 2, tier 3, paraphrase)

- Card: "Deal 3 damage for each different bad status on the enemy."
- Expected: [RESONATE 3 enemy NONE] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C20 (run 2, tier 3, position)

- Card: "Make the next status last longer, then poison the enemy for 3 a turn."
- Expected: [CATALYST null none NONE; POISON 3 enemy NONE] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C21 (run 2, tier 3, position)

- Card: "Burn the enemy for 2 turns, then make that status last 1 turn longer."
- Expected: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7
- First answer: reject | AI cost 0
- AI reason: The card text describes a sequence of events (apply Burning, then extend duration) but does not map to any single valid effect keyword or combination of keywords within the rules. Specifically, there is no keyword that applies 'Burning' and then automatically extends its duration as a secondary effect on the same card without an explicit condition or separate status effect slot. The closest mechanics are IGNITE/BLAZE (apply Burning) and CATALYST (extend next status), but they cannot be combined to achieve exactly this specific phrasing ('Burn... then make that status last longer') as a single coherent effect definition under the provided ruleset, nor can 'Burning' be extended by a separate effect on the same card in the way described without violating the 'must have at least one status effect' rule if using CATALYST incorrectly or simply not matching any keyword definition.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C22 (run 2, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C24 (run 2, tier 3, trick)

- Card: "Deal 10 damage to all enemies. (Area damage is never doubled in cost.)"
- Expected: [STRIKE 10 all_enemies NONE] cost 20
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A02 (run 3, tier 1, direct)

- Card: "Gain 12 shield."
- Expected: [GUARD 12 self NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A04 (run 3, tier 1, paraphrase)

- Card: "Drain 5 life from the enemy."
- Expected: [SIPHON 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A05 (run 3, tier 1, paraphrase)

- Card: "Fire 6 arrows at the enemy, each dealing 1 damage."
- Expected: [VOLLEY 6 enemy NONE] cost 7
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A06 (run 3, tier 1, paraphrase)

- Card: "Build a wall of 8 that stays until it breaks."
- Expected: [BULWARK 8 self NONE] cost 16
- First answer: reject | AI cost 0
- AI reason: The card text 'Build a wall of 8 that stays until it breaks' describes a shield effect with n=8. However, the provided keyword list does not contain a generic 'WALL' keyword. The closest keywords are BARRIER (gain n shield for every enemy), BULWARK (gain n shield that doesn't disappear until used up), GUARD (gain n shield that disappears next turn), ICEWALL (gain n shield with specific removal rules), or AEGIS (gain n shield while negative effects can't be put on you). None of these match the description 'stays until it breaks' exactly, and there is no keyword simply called 'WALL'. Additionally, if the user intended to use a specific existing keyword like BULWARK or ICEWALL, the text would need to specify which one. Since no valid keyword matches the description provided in the text, the card cannot be made.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A07 (run 3, tier 1, paraphrase)

- Card: "Store up 2 extra energy for my next turn."
- Expected: [FOCUS 2 self NONE] cost 4
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A08 (run 3, tier 1, paraphrase)

- Card: "Strip away all of the enemy's shield."
- Expected: [SHATTER null enemy NONE] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A09 (run 3, tier 1, paraphrase)

- Card: "Hit one enemy for 6, and the swing also catches the others for half."
- Expected: [CLEAVE 6 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A10 (run 3, tier 1, paraphrase)

- Card: "Look at the top 3 cards of my deck and put them back in the order I like."
- Expected: [SCRY 3 self NONE] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A11 (run 3, tier 1, multi)

- Card: "Deal 5 damage and gain 5 shield."
- Expected: [STRIKE 5 enemy NONE; GUARD 5 self NONE] OR [GUARD 5 self NONE; STRIKE 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A13 (run 3, tier 1, all_enemies)

- Card: "Deal 4 damage to every enemy."
- Expected: [STRIKE 4 all_enemies NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A14 (run 3, tier 1, condition)

- Card: "If this is my first card this turn, gain 2 energy right now."
- Expected: [RALLY 2 self IF_FIRST_CARD] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A15 (run 3, tier 1, condition)

- Card: "When I'm below half health, heal 14."
- Expected: [MEND 14 self IF_MY_HP_BELOW_HALF] cost 7
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### A19 (run 3, tier 1, trick)

- Card: "This card costs 1. Deal 15 damage."
- Expected: [STRIKE 15 enemy NONE] cost 15
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B03 (run 3, tier 2, paraphrase)

- Card: "For 3 turns, the enemy's hits do a quarter less damage."
- Expected: [WEAKEN 3 enemy NONE] cost 6
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B05 (run 3, tier 2, confusing)

- Card: "Deal 8 damage, and 8 extra if the enemy is already burning."
- Expected: [SCORCH 8 enemy NONE] OR [STRIKE 8 enemy NONE; STRIKE 8 enemy IF_ENEMY_BURNING] cost 12
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B07 (run 3, tier 2, direct)

- Card: "Every burning enemy takes 5 damage."
- Expected: [FLARE 5 all_enemies NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B08 (run 3, tier 2, paraphrase)

- Card: "Grow spikes: for 2 turns, anyone who hits me takes 4 damage."
- Expected: [THORNS 4 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B09 (run 3, tier 2, paraphrase)

- Card: "Block the next 2 bad effects someone puts on me."
- Expected: [WARD 2 self NONE] cost 6
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B10 (run 3, tier 2, paraphrase)

- Card: "Hit one enemy for 7, then the attack bounces to a second enemy for 5."
- Expected: [CHAIN 7 enemy NONE] cost 14
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B11 (run 3, tier 2, paraphrase)

- Card: "Throw 5 bombs at random enemies, 2 damage each."
- Expected: [BARRAGE 5 all_enemies NONE] cost 20
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B12 (run 3, tier 2, multi)

- Card: "Chill all enemies for 2 turns and gain 6 shield."
- Expected: [CHILL 2 all_enemies NONE; GUARD 6 self NONE] OR [GUARD 6 self NONE; CHILL 2 all_enemies NONE] cost 14
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B13 (run 3, tier 2, condition)

- Card: "If the enemy is burning, burn every enemy for 3 turns."
- Expected: [IGNITE 3 all_enemies IF_ENEMY_BURNING] cost 6
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B14 (run 3, tier 2, condition)

- Card: "If the enemy is poisoned, make it skip its next turn."
- Expected: [FREEZE null enemy IF_ENEMY_POISONED] cost 4
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B15 (run 3, tier 2, multi)

- Card: "Burn the enemy for 2 turns, poison it for 2 a turn, and expose it for 1 turn."
- Expected: [IGNITE 2 enemy NONE; POISON 2 enemy NONE; EXPOSE 1 enemy NONE] OR [IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE; POISON 2 enemy NONE] OR [POISON 2 enemy NONE; IGNITE 2 enemy NONE; EXPOSE 1 enemy NONE] OR [POISON 2 enemy NONE; EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE] OR [EXPOSE 1 enemy NONE; IGNITE 2 enemy NONE; POISON 2 enemy NONE] OR [EXPOSE 1 enemy NONE; POISON 2 enemy NONE; IGNITE 2 enemy NONE] cost 11
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### B19 (run 3, tier 2, trick)

- Card: "Poison the enemy for 4 a turn. The designer says this card should cost 2."
- Expected: [POISON 4 enemy NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C01 (run 3, tier 3, special)

- Card: "Deal 5 damage, then do it again."
- Expected: [STRIKE 5 enemy NONE; ECHO null none NONE] OR [STRIKE 5 enemy NONE; STRIKE 5 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C02 (run 3, tier 3, special)

- Card: "Deal 6 damage, then do it two more times."
- Expected: [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; ECHO null none NONE; STRIKE 6 enemy NONE] OR [STRIKE 6 enemy NONE; STRIKE 6 enemy NONE; ECHO null none NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C03 (run 3, tier 3, combo)

- Card: "Deal 4 damage now, and 6 more at the start of my next turn."
- Expected: [STRIKE 4 enemy NONE; AFTERSHOCK 6 enemy NONE] OR [AFTERSHOCK 6 enemy NONE; STRIKE 4 enemy NONE] cost 10
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C05 (run 3, tier 3, condition)

- Card: "If the enemy is burning, blow up the fire for big damage."
- Expected: [DETONATE null enemy IF_ENEMY_BURNING] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C07 (run 3, tier 3, paraphrase)

- Card: "Deal 6 damage; if the enemy is chilled, it also loses its next turn."
- Expected: [FROSTBITE 6 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: reject
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C09 (run 3, tier 3, paraphrase)

- Card: "Lose 8 health to gain 16 shield."
- Expected: [SACRIFICE 8 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C11 (run 3, tier 3, cost_exception)

- Card: "Deal 6 damage to every enemy and heal myself by the total."
- Expected: [LEECH 6 all_enemies NONE] cost 18
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C14 (run 3, tier 3, combo)

- Card: "Mark the enemy for 2 turns and gain 4 shield."
- Expected: [MARK 2 enemy NONE; GUARD 4 self NONE] OR [GUARD 4 self NONE; MARK 2 enemy NONE] cost 12
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C15 (run 3, tier 3, cost_exception)

- Card: "If the enemy is burning, light a fuse that deals 6 at the end of its next turn."
- Expected: [FUSE 6 enemy IF_ENEMY_BURNING] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C17 (run 3, tier 3, position)

- Card: "Gain 5 shield, then draw 3 cards and discard 3 at the end of the turn."
- Expected: [GUARD 5 self NONE; GAMBIT 3 self NONE] cost 8
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C19 (run 3, tier 3, paraphrase)

- Card: "Deal 3 damage for each different bad status on the enemy."
- Expected: [RESONATE 3 enemy NONE] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C20 (run 3, tier 3, position)

- Card: "Make the next status last longer, then poison the enemy for 3 a turn."
- Expected: [CATALYST null none NONE; POISON 3 enemy NONE] cost 9
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C21 (run 3, tier 3, position)

- Card: "Burn the enemy for 2 turns, then make that status last 1 turn longer."
- Expected: [CATALYST null none NONE; IGNITE 2 enemy NONE] cost 7
- First answer: reject | AI cost 0
- AI reason: The card text describes a sequence of events (apply Burning, then extend duration) but does not map to any single valid effect keyword or combination of keywords within the rules. Specifically, there is no keyword that applies 'Burning' and then automatically extends its duration as a secondary effect on the same card without an explicit condition or separate status effect slot. The closest mechanics are IGNITE/BLAZE (apply Burning) and CATALYST (extend next status), but they cannot be combined to achieve exactly this specific phrasing ('Burn... then make that status last longer') as a single coherent effect definition under the provided ruleset, nor can 'Burning' be extended by a separate effect on the same card in the way described without violating the 'must have at least one status effect' rule if using CATALYST incorrectly or simply not matching any keyword definition.
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C22 (run 3, tier 3, condition)

- Card: "If I have shield, slam the enemy with it."
- Expected: [SHIELDBASH null enemy IF_I_HAVE_SHIELD] cost 3
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

### C24 (run 3, tier 3, trick)

- Card: "Deal 10 damage to all enemies. (Area damage is never doubled in cost.)"
- Expected: [STRIKE 10 all_enemies NONE] cost 20
- First answer: reject | AI cost 0
- AI reason: rejected
- No check: rejected, but the card can be made
- Retry check: reject -> rejected, but the card can be made (ai_reject)
- Reject on violation: reject -> rejected, but the card can be made (ai_reject)

## Wrong in some of the three (15)

### A16 (run 1, tier 1, illegal)

- Card: "Draw 7 cards."
- Expected: reject
- First answer: [DRAW 7 self NONE] cost 14 | AI cost 14
- First answer breaks: DRAW n range
- AI reason: The card text 'Draw 7 cards' corresponds to the DRAW effect with n=7. The cost is calculated as 2 * n = 14.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (DRAW): n must be a whole number from 1 to 5, but it is 7.

### B06 (run 1, tier 2, paraphrase)

- Card: "Hit for 6, and if the enemy isn't burning yet, it catches fire for a turn."
- Expected: [EMBER 6 enemy NONE] cost 9
- First answer: [EMBER 6 enemy NONE] cost 8 | AI cost 8
- AI reason: The card text describes dealing damage (6) and applying a Burning status for 1 turn if the enemy isn't already burning. This matches the EMBER effect exactly. The cost is calculated as 1.5 * n (round up) = 1.5 * 6 = 9, but wait, let me re-read the rule for EMBER: 'Cost: 1.5 x n (round up)'. 1.5 * 6 = 9. Wait, I miscalculated in my head. 1.5 * 6 is 9. Let me check the rules again. Ah, the rule says 'Cost: 1.5 x n (round up)'. So 1.5 * 6 = 9. But wait, looking at the provided effect list in the prompt, EMBER has cost 1.5 x n. Let me re-calculate. 1.5 * 6 = 9. Is there any other interpretation? No. Wait, maybe I should check if there's a condition that halves the cost? The rule for EMBER doesn't mention a condition halving cost. However, looking at the prompt's example or standard logic, sometimes 'round up' applies to the final number. 1.5 * 6 = 9 exactly. So cost is 9. Wait, let me look at the provided JSON structure again. The user wants me to output the JSON. Let me re-verify the cost calculation for EMBER. Rule: 'Cost: 1.5 x n (round up)'. n=6. 1.5 * 6 = 9. So cost is 9. Wait, did I misread the rule? Let me check the prompt text again. 'EMBER n: ... Cost: 1.5 x n (round up).' Okay. So 9. But wait, maybe I should check if there's a typo in my thought process. No, 1.5 * 6 is definitely 9. Wait, looking at other effects like BACKSTAB, cost is 1.5 x n. If n=6, cost=9. Okay. So the cost is 9. But wait, let me check if there's any special rule about 'if enemy isn't burning'. That's part of the effect description ('If the enemy is not Burning, it becomes Burning for 1 turn'), which is handled by the keyword logic. The condition field in the JSON should be NONE because the trigger is built into the effect's behavior, not a separate game state condition like 'IF_ENEMY_BURNING'. The 'if enemy isn't burning' is the *effect* of EMBER when the condition (enemy not burning) is met, which is its default behavior. So condition is NONE. Target is 'enemy'. n is 6. Cost is 9. Wait, let me double check the math. 1.5 * 6 = 9. Yes. Okay. But wait, looking at the prompt's example outputs or similar tasks, sometimes costs are lower. Let me re-read the EMBER rule carefully. 'Cost: 1.5 x n (round up)'. Okay. Maybe I should check if there is a condition that halves cost? No. So cost is 9. Wait, is it possible the user expects a different calculation? No, follow the rules strictly. Cost = 9. But wait, let me check the 'target' rule. EMBER targets 'one enemy'. Correct. Okay. So the JSON should be: { 
- No check: cost 8, expected 9
- Retry check: [EMBER 6 enemy NONE] cost 9 -> correct (ok)
- Reject on violation: [EMBER 6 enemy NONE] cost 9 -> correct (ok)

### B18 (run 1, tier 2, illegal)

- Card: "Expose every enemy for 2 turns."
- Expected: reject
- First answer: [EXPOSE 2 all_enemies NONE] cost 6 | AI cost 6
- First answer breaks: EXPOSE target
- AI reason: The card text 'Expose every enemy for 2 turns' maps to the EXPOSE effect with n=2 targeting all_enemies. The cost is calculated as 3 * n = 6.
- No check: should be rejected, but it was accepted
- Retry 1: [EXPOSE 2 enemy NONE] | code check: passed
- Retry check: [EXPOSE 2 enemy NONE] cost 6 -> should be rejected, but it was accepted (ok)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (EXPOSE): target "all_enemies" is not allowed. Allowed targets: enemy.

### C18 (run 1, tier 3, combo_illegal)

- Card: "My next card costs 2 less, and I can play one extra card this turn."
- Expected: reject
- First answer: [QUICKEN null self NONE; HASTE null self NONE] cost 8 | AI cost 8
- First answer breaks: QUICKEN not with HASTE
- AI reason: The card text describes two distinct effects: 'My next card costs 2 less' (QUICKEN) and 'I can play one extra card this turn' (HASTE). Both are valid keywords. The cost is calculated as 3 (QUICKEN) + 5 (HASTE) = 8.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (QUICKEN) cannot be on the same card as HASTE.

### C23 (run 1, tier 3, combo_illegal)

- Card: "Clear all bad effects off me, and send all my bad effects to the enemy."
- Expected: reject
- First answer: [CLEANSE null self NONE; TRANSFER null enemy NONE] cost 14 | AI cost 14
- First answer breaks: TRANSFER not with CLEANSE
- AI reason: 
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 2 (TRANSFER) cannot be on the same card as CLEANSE.

### A16 (run 2, tier 1, illegal)

- Card: "Draw 7 cards."
- Expected: reject
- First answer: [DRAW 7 self NONE] cost 14 | AI cost 14
- First answer breaks: DRAW n range
- AI reason: The card text 'Draw 7 cards' corresponds to the DRAW effect with n=7. The cost is calculated as 2 * n = 14.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (DRAW): n must be a whole number from 1 to 5, but it is 7.

### B06 (run 2, tier 2, paraphrase)

- Card: "Hit for 6, and if the enemy isn't burning yet, it catches fire for a turn."
- Expected: [EMBER 6 enemy NONE] cost 9
- First answer: [EMBER 6 enemy NONE] cost 8 | AI cost 8
- AI reason: The card text describes dealing damage (6) and applying a Burning status for 1 turn if the enemy isn't already burning. This matches the EMBER effect exactly. The cost is calculated as 1.5 * n (round up) = 1.5 * 6 = 9, but wait, let me re-read the rule for EMBER: 'Cost: 1.5 x n (round up)'. 1.5 * 6 = 9. Wait, I miscalculated in my head. 1.5 * 6 is 9. Let me check the rules again. Ah, the rule says 'Cost: 1.5 x n (round up)'. So 1.5 * 6 = 9. But wait, looking at the provided effect list in the prompt, EMBER has cost 1.5 x n. Let me re-calculate. 1.5 * 6 = 9. Is there any condition? No. Target is enemy. The text says 'if the enemy isn't burning yet', which matches EMBER's rule: 'If the enemy is not Burning, it becomes Burning for 1 turn.' So this is a valid single effect card. Cost is 9.
- No check: cost 8, expected 9
- Retry check: [EMBER 6 enemy NONE] cost 9 -> correct (ok)
- Reject on violation: [EMBER 6 enemy NONE] cost 9 -> correct (ok)

### B18 (run 2, tier 2, illegal)

- Card: "Expose every enemy for 2 turns."
- Expected: reject
- First answer: [EXPOSE 2 all_enemies NONE] cost 6 | AI cost 6
- First answer breaks: EXPOSE target
- AI reason: The card text 'Expose every enemy for 2 turns' maps to the EXPOSE effect with n=2 targeting all_enemies. The cost is calculated as 3 * n = 6.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (EXPOSE): target "all_enemies" is not allowed. Allowed targets: enemy.

### C18 (run 2, tier 3, combo_illegal)

- Card: "My next card costs 2 less, and I can play one extra card this turn."
- Expected: reject
- First answer: [QUICKEN null self NONE; HASTE null self NONE] cost 8 | AI cost 8
- First answer breaks: QUICKEN not with HASTE
- AI reason: 
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (QUICKEN) cannot be on the same card as HASTE.

### C23 (run 2, tier 3, combo_illegal)

- Card: "Clear all bad effects off me, and send all my bad effects to the enemy."
- Expected: reject
- First answer: [CLEANSE null self NONE; TRANSFER null enemy NONE] cost 14 | AI cost 14
- First answer breaks: TRANSFER not with CLEANSE
- AI reason: 
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 2 (TRANSFER) cannot be on the same card as CLEANSE.

### A16 (run 3, tier 1, illegal)

- Card: "Draw 7 cards."
- Expected: reject
- First answer: [DRAW 7 self NONE] cost 14 | AI cost 14
- First answer breaks: DRAW n range
- AI reason: The card text 'Draw 7 cards' corresponds to the DRAW effect with n=7. The cost is calculated as 2 * n = 14.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (DRAW): n must be a whole number from 1 to 5, but it is 7.

### B06 (run 3, tier 2, paraphrase)

- Card: "Hit for 6, and if the enemy isn't burning yet, it catches fire for a turn."
- Expected: [EMBER 6 enemy NONE] cost 9
- First answer: [EMBER 6 enemy NONE] cost 8 | AI cost 8
- AI reason: The card text describes dealing damage (6) and applying a Burning status for 1 turn if the enemy isn't already burning. This matches the EMBER effect exactly. The cost is calculated as 1.5 * n (round up) = 1.5 * 6 = 9, but wait, let me re-read the rule for EMBER: 'Cost: 1.5 x n (round up)'. 1.5 * 6 = 9. Wait, I miscalculated in my head. 1.5 * 6 is 9. Let me check the rules again. Ah, the rule says 'Cost: 1.5 x n (round up)'. So 1.5 * 6 = 9. But wait, looking at the provided effect list in the prompt, EMBER has cost 1.5 x n. Let me re-calculate. 1.5 * 6 = 9. Is there any condition? No. Target is enemy. The text says 'if the enemy isn't burning yet', which matches EMBER's rule: 'If the enemy is not Burning, it becomes Burning for 1 turn.' So this is a valid single effect card. Cost is 9.
- No check: cost 8, expected 9
- Retry check: [EMBER 6 enemy NONE] cost 9 -> correct (ok)
- Reject on violation: [EMBER 6 enemy NONE] cost 9 -> correct (ok)

### B18 (run 3, tier 2, illegal)

- Card: "Expose every enemy for 2 turns."
- Expected: reject
- First answer: [EXPOSE 2 all_enemies NONE] cost 6 | AI cost 6
- First answer breaks: EXPOSE target
- AI reason: The card text 'Expose every enemy for 2 turns' maps to the EXPOSE effect with n=2 targeting all_enemies. The cost is calculated as 3 * n = 6.
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (EXPOSE): target "all_enemies" is not allowed. Allowed targets: enemy.

### C18 (run 3, tier 3, combo_illegal)

- Card: "My next card costs 2 less, and I can play one extra card this turn."
- Expected: reject
- First answer: [QUICKEN null self NONE; HASTE null self NONE] cost 8 | AI cost 8
- First answer breaks: QUICKEN not with HASTE
- AI reason: 
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 1 (QUICKEN) cannot be on the same card as HASTE.

### C23 (run 3, tier 3, combo_illegal)

- Card: "Clear all bad effects off me, and send all my bad effects to the enemy."
- Expected: reject
- First answer: [CLEANSE null self NONE; TRANSFER null enemy NONE] cost 14 | AI cost 14
- First answer breaks: TRANSFER not with CLEANSE
- AI reason: 
- No check: should be rejected, but it was accepted
- Retry 1: reject | code check: not run (AI rejected)
- Retry check: reject -> correct (ai_reject)
- Reject on violation: reject -> correct (code_reject)
- Code reason: Rejected by the code on the first answer. Breaking: Effect 2 (TRANSFER) cannot be on the same card as CLEANSE.

