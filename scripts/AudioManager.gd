extends Node

# AudioManager - Handles all game sounds and music

@export var music_bus_idx: int = 1
@export var sfx_bus_idx: int = 2

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var max_sfx_players: int = 8

func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create SFX players
	for i in range(max_sfx_players):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func play_music(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream, volume_db: float = 0.0):
	# Find available player
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	
	# If all busy, use first one
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = volume_db
	sfx_players[0].play()

func set_music_volume(volume: float):
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(volume))

func set_sfx_volume(volume: float):
	AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(volume))
