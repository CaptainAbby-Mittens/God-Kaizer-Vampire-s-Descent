# MusicManager.gd
extends AudioStreamPlayer

func _ready():
	# Load your music file
	var music_stream = load("res://8 bit fantasy music.wav")
	stream = music_stream

	volume_db = -45  # Slightly quieter than normal
	play()
