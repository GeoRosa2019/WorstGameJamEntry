extends Node2D

signal puzzleSolved

@export var totalRounds := 3
var currentRound := 1
var solved := false
# Last round
@export var fastShuffleSpeed := 1.0
@export var fastShuffleAnimation := 0.3
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

func startFastShuffle():
	while not solved and is_inside_tree():
		await get_tree().create_timer(fastShuffleSpeed).timeout
		if solved or not is_inside_tree():
			return
		fastShuffle()

func fastShuffle():
	var slots = get_tree().get_nodes_in_group("pcSlots").filter(func(s): return not s.sliding)
	var positions = slots.map(func(s): return s.global_position)
	positions.shuffle()

	var tween = create_tween().set_parallel(true)
	for i in slots.size():
		slots[i].sliding = true
		tween.tween_property(slots[i], "global_position", positions[i], fastShuffleAnimation)

	await tween.finished
	for s in slots:
		s.sliding = false

func _ready():
	winLabel.hide()
	shuffleSlots()
	AudioManager.playRoundMusic(currentRound)
	
	#Check if needed to add slot ports
	for slot in get_tree().get_nodes_in_group("pcSlots"):
		slot.partChange.connect(checkAll)
		slot.partPlaced.connect(onPartPlaced)
		slot.toolUsed.connect(onToolUsed)

func onPartPlaced(isRight: bool):
	if isRight:
		AudioManager.playCorrect()
	else:
		AudioManager.playWrong()

func onToolUsed(isRight: bool):
	if isRight:
		AudioManager.playToolCorrect()
	else:
		AudioManager.playToolWrong()
		
func checkAll():
	if solved:
		return
	for slot in get_tree().get_nodes_in_group("pcSlots"):
		if not slot.isCorrect():
			return
	solved = true
	if currentRound >= totalRounds:
		puzzleSolved.emit()
		AudioManager.playMusic(AudioManager.winMusic)
		get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")
	else:
		winLabel.text = "Round %d complete!" % currentRound
		winLabel.show()
		await get_tree().create_timer(1.5).timeout
		winLabel.hide()
		nextRound()

func nextRound():
	currentRound += 1
	AudioManager.playRoundMusic(currentRound)
	for node in get_tree().get_nodes_in_group("resetNodes"):
		node.resetToStart()
	shuffleSlots()
	solved = false
	if currentRound == totalRounds:
		startFastShuffle()
	print("PC Built Successfully! Have a cookie!")
	
