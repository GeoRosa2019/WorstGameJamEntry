extends Node2D

signal puzzleSolved

@export var totalRounds := 3
var currentRound := 1
var solved := false

@export var winLabel: Label

# Add group pcSlots
func _ready():
	winLabel.hide()
	for slot in get_tree().get_nodes_in_group("pcSlots"):
		slot.partChange.connect(checkAll)
	
		
func checkAll():
	if solved:
		return
	for slot in get_tree().get_nodes_in_group("pcSlots"):
		if not slot.isCorrect():
			return
	solved = true
	puzzleSolved.emit()
	winLabel.show()
	print("PC Built Successfully! Have a cookie!")
	
