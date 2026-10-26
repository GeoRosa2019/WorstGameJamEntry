extends Node2D

signal puzzleSolved

@export var totalRounds := 3
var currentRound := 1
var solved := false

@export var winLabel: Label

# Adding new function for shuffling motherboard slots
func shuffleSlots():
	var slots = get_tree().get_nodes_in_group("pcSlots")
	var positions = []
	for slot in slots:
		positions.append(slot.global_position)

	# Reshuffle until at least one slot actually moves
	var original = positions.duplicate()
	if slots.size() > 1:
		while positions == original:
			positions.shuffle()

	for i in slots.size():
		slots[i].global_position = positions[i]

func _ready():
	winLabel.hide()
	shuffleSlots()
	for slot in get_tree().get_nodes_in_group("pcSlots"):
		slot.partChange.connect(checkAll)
	
		
func checkAll():
	if solved:
		return
	for slot in get_tree().get_nodes_in_group("pcSlots"):
		if not slot.isCorrect():
			return
	solved = true
	if currentRound >= totalRounds:
		puzzleSolved.emit()
		get_tree().change_scene_to_file("res://winScreen.tscn")
	else:
		winLabel.text = "Round %d complete!" % currentRound
		winLabel.show()
		await get_tree().create_timer(1.5).timeout
		winLabel.hide()
		nextRound()

func nextRound():
	currentRound += 1
	for node in get_tree().get_nodes_in_group("resetNodes"):
		node.resetToStart()
	shuffleSlots()
	solved = false
	print("PC Built Successfully! Have a cookie!")
	
