extends SceneTree

func split_card(text: String) -> Array:
	var paren := RegEx.new()
	paren.compile("\\([^)]*\\)")
	var delim := RegEx.new()
	delim.compile("(?i)\\s*[.,]\\s*|\\s+(?:and|then)\\s+")
	var work := text
	var saved: Array = []
	var found := paren.search_all(work)
	for i in range(found.size() - 1, -1, -1):
		var m: RegExMatch = found[i]
		work = work.substr(0, m.get_start()) + "@@P%d@@" % i + work.substr(m.get_end())
	for m in found:
		saved.append(m.get_string())

	var pieces: Array = []
	var last := 0
	for m in delim.search_all(work):
		pieces.append(work.substr(last, m.get_start() - last))
		last = m.get_end()
	pieces.append(work.substr(last))

	var out: Array = []
	for piece in pieces:
		var p: String = piece.strip_edges()
		var changed := true
		while changed:
			changed = false
			for lead in ["and ", "then "]:
				if p.to_lower().begins_with(lead):
					p = p.substr(lead.length()).strip_edges()
					changed = true
		for i in saved.size():
			p = p.replace("@@P%d@@" % i, saved[i])
		if p != "":
			out.append(p)
	return out


func _initialize():
	var data = JSON.parse_string(FileAccess.open("res://eval/card_rulebook_data.json", FileAccess.READ).get_as_text())
	var multi := 0
	for t in data["tests"]:
		var pieces: Array = split_card(t["text"])
		if pieces.size() > 1:
			multi += 1
		print("%-3s (%d) \"%s\"\n      -> %s" % [t["id"], pieces.size(), t["text"], " | ".join(PackedStringArray(pieces))])
	print("cards with more than one piece: %d of %d" % [multi, data["tests"].size()])
	quit()
