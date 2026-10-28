extends Node2D

@export var roundMusic: Array[AudioStream] = [] 
@export var winMusic: AudioStream

@onready var correctSound = $correctSound
@onready var wrongSound = $wrongSound
@onready var toolCorrectSound = $toolkitCorrectSound
@onready var toolWrongSound = $toolkitWrongSound
@onready var musicPlayer = $bgMusic

func playCorrect():
	correctSound.play()

func playWrong():
	wrongSound.play()

func playToolCorrect():
	toolCorrectSound.play()

func playToolWrong():
	toolWrongSound.play()

func playRoundMusic(roundNumber: int):
	if roundMusic.is_empty():
		return
	var index = clamp(roundNumber - 1, 0, roundMusic.size() - 1)
	playMusic(roundMusic[index])

func playMusic(stream: AudioStream, fadeTime := 1.0):
	if stream == null:
		return
	if musicPlayer.stream == stream and musicPlayer.playing:
		return  
	if musicPlayer.playing and fadeTime > 0:
		var tween = create_tween()
		tween.tween_property(musicPlayer, "volume_db", -40.0, fadeTime)
		await tween.finished
	musicPlayer.stream = stream
	musicPlayer.volume_db = 0.0
	musicPlayer.play()

func stopMusic():
	musicPlayer.stop()
