import json, math, sys
# Reference rules check for big_rulebook_v1.json. Usage: python big_reference_check.py big_rulebook_v1.json
DATA = json.load(open(sys.argv[1] if len(sys.argv) > 1 else "big_rulebook_v1.json", encoding="utf-8"))
RULES = {r["keyword"]: r for r in DATA["rules"] + DATA["distractors"] + DATA.get("distractors_xl", [])}
COND = set(DATA["conditions"]); DAMAGE = set(DATA["damage_group"]); STATUS = set(DATA["status_group"])

def eff_cost(e, card):
    if RULES[e["keyword"]].get("variant_of", e["keyword"]) == "ECHO":
        return eff_cost(card[card.index(e) - 1], card)
    r = RULES[e["keyword"]]
    c = math.ceil(r["cost_per_n"] * e["n"]) + r["cost_flat"] if r["has_n"] else r["cost_flat"]
    if e["target"] == "all_enemies" and not r.get("no_all_multiplier"): c *= 2
    if e["condition"] != "NONE" and not r.get("no_condition_discount"): c = math.ceil(c / 2)
    return c

def validate(card):
    errs = []
    if not 1 <= len(card) <= 3: errs.append("effect count")
    kws = [e["keyword"] for e in card]
    for i, e in enumerate(card):
        k = e["keyword"]
        if k not in RULES: errs.append(f"unknown {k}"); continue
        r = RULES[k]
        family = r.get("variant_of", k)
        if family in ("ECHO", "CATALYST"):
            if e["target"] != "none" or e["n"] is not None: errs.append(f"{k} target/n")
            if family == "ECHO" and e["condition"] != "NONE": errs.append(f"{k} condition")
        else:
            if e["target"] not in r["targets"]: errs.append(f"{k} target")
            if r["has_n"]:
                if e["n"] is None or not r["n_min"] <= e["n"] <= r["n_max"]: errs.append(f"{k} n range")
            elif e["n"] is not None: errs.append(f"{k} has no n")
        if e["condition"] != "NONE" and e["condition"] not in COND: errs.append(f"{k} bad condition")
        if r.get("forbid_condition") and e["condition"] != "NONE": errs.append(f"{k} forbids condition")
        if r.get("requires_condition") and e["condition"] not in r["requires_condition"]: errs.append(f"{k} requires condition")
        others = kws[:i] + kws[i + 1:]
        for nw in r.get("not_with", []):
            if nw in others: errs.append(f"{k} not with {nw}")
        if r.get("not_with_group") == "damage" and any(o in DAMAGE for o in others): errs.append(f"{k} not with damage")
        if r.get("requires_group") == "damage" and not any(o in DAMAGE for o in others): errs.append(f"{k} needs damage")
        if r.get("requires_group") == "status" and not any(o in STATUS for o in others): errs.append(f"{k} needs status")
        pos = r.get("position")
        if pos == "first" and i != 0: errs.append(f"{k} must be first")
        if pos == "last" and i != len(card) - 1: errs.append(f"{k} must be last")
        if pos == "not_first" and i == 0: errs.append(f"{k} cannot be first")
        if r.get("max_per_card") and kws.count(k) > r["max_per_card"]: errs.append(f"{k} max per card")
        if r.get("only_effect") and len(card) > 1: errs.append(f"{k} must be only effect")
    return sorted(set(errs))


if __name__ == "__main__":
    bad = 0
    for t in DATA["tests"]:
        for a in t["accepted"]:
            if validate(a) or sum(eff_cost(e, a) for e in a) != t["cost"]:
                bad += 1; print("accepted fails", t["id"], validate(a))
        for ex in t["illegal_examples"]:
            if not validate(ex["effects"]):
                bad += 1; print("illegal passes", t["id"])
    print("problems:", bad)
