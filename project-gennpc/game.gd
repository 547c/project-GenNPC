extends Node2D

enum State { EXPLORING, DIALOGUE }

var state: State = State.EXPLORING
var npc_in_range: String = ""
var current_dialogue_npc: String = ""

@onready var player = $Player
@onready var classifier = $NPCClassifier
@onready var hint_label = $UI/HintLabel
@onready var dialogue_panel = $UI/DialoguePanel
@onready var npc_name_label = $UI/DialoguePanel/VBoxContainer/NPCNameLabel
@onready var response_label = $UI/DialoguePanel/VBoxContainer/ResponseLabel
@onready var input_field = $UI/DialoguePanel/VBoxContainer/InputField
@onready var close_button = $UI/DialoguePanel/VBoxContainer/CloseButton


func _ready():
	dialogue_panel.hide()
	hint_label.hide()

	classifier.classification_completed.connect(_on_classification_completed)
	classifier.classification_failed.connect(_on_classification_failed)
	input_field.text_submitted.connect(_on_input_submitted)
	close_button.pressed.connect(close_dialogue)

	$NPC_Hunter/InteractionArea.body_entered.connect(_on_npc_area_entered.bind("hunter"))
	$NPC_Hunter/InteractionArea.body_exited.connect(_on_npc_area_exited.bind("hunter"))
	$NPC_Miner/InteractionArea.body_entered.connect(_on_npc_area_entered.bind("miner"))
	$NPC_Miner/InteractionArea.body_exited.connect(_on_npc_area_exited.bind("miner"))


func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if state == State.EXPLORING:
		if (event.keycode == KEY_E or event.keycode == KEY_SPACE) and npc_in_range != "":
			open_dialogue(npc_in_range)
	elif state == State.DIALOGUE:
		if event.keycode == KEY_ESCAPE:
			close_dialogue()


func _on_npc_area_entered(body, npc_id):
	if body == player:
		npc_in_range = npc_id
		hint_label.text = "[E] Talk to %s" % classifier.get_npc_name(npc_id)
		hint_label.show()


func _on_npc_area_exited(body, npc_id):
	if body == player and npc_in_range == npc_id:
		npc_in_range = ""
		hint_label.hide()


func open_dialogue(npc_id: String):
	state = State.DIALOGUE
	current_dialogue_npc = npc_id
	player.set_physics_process(false)
	hint_label.hide()
	npc_name_label.text = classifier.get_npc_name(npc_id)
	response_label.text = ""
	input_field.text = ""
	input_field.editable = true
	dialogue_panel.show()
	input_field.grab_focus()


func close_dialogue():
	state = State.EXPLORING
	dialogue_panel.hide()
	player.set_physics_process(true)
	input_field.release_focus()


func _on_input_submitted(text: String):
	if text.strip_edges() == "":
		return
	response_label.text = "..."
	input_field.editable = false
	classifier.classify_input(current_dialogue_npc, text)


func _on_classification_completed(npc_id: String, matched_id: String, response_text: String):
	if npc_id != current_dialogue_npc or not dialogue_panel.visible:
		return
	if response_text == "":
		response_label.text = "%s doesn't seem to understand what you mean." % classifier.get_npc_name(npc_id)
	else:
		response_label.text = response_text
	input_field.editable = true
	input_field.text = ""
	input_field.grab_focus()


func _on_classification_failed(npc_id: String, error_text: String):
	if npc_id != current_dialogue_npc or not dialogue_panel.visible:
		return
	response_label.text = "(error) " + error_text
	input_field.editable = true
	input_field.grab_focus()
