extends Node

export (int) var start_player_count = 3											# Starting amount of AudioStreamPlayers
export (String) var bus_name:String = 'SFX'										# Name of the bus sample players will be aassigned to, if wrong defaults to Master
export (Array, AudioStream) var sample_collection								# If added in scene, can preload from Inspector
var sample_dictionary: = {}														# Holds loaded samples

export (float) var retrigger_time:float = 1.0/60.0*2							# Choose time when same sample can be triggered again
onready var players: = get_children()
onready var free_players: = players												# List of AudioStreamPlayer not playing sounds
var active_players: = {}														# List of AudioStreamPlayer playing samples


func add_players(value:int)->void:
	for i in value:
		var player: = AudioStreamPlayer.new()									# Create new player
		players.append(player)
		add_child(player)

func _ready():																	# Add to database all samples preloaded in the Inspector
	for i in sample_collection.size():
		var sample:AudioStreamSample = sample_collection[i]						# Reference sample
		sample_dictionary[sample.get_path().get_file().get_basename()] = i		# Create entry with file name to reference index in array
	add_players(start_player_count)												# Add some players to start with

func play(sample_name:String,vol:float = 0.0)->void:
	if active_players.has(sample_name):											# Same sample is already playing
		var player:AudioStreamPlayer = active_players[sample_name]
		if player.get_playback_position() > retrigger_time:						# Checks if same sample has played at least certain length
			player.volume_db = vol
			player.play()
	else:
		if !free_players.empty():												# There are un-active players
			var player:AudioStreamPlayer = free_players.pop_back()
			active_players[sample_name] = player
			player.stream = sample_collection[ sample_dictionary[sample_name] ]
			player.volume_db = vol
			player.play()
			player.connect("finished", self, "sample_finished", [sample_name])
		else:
			print("not enough audio players - creating new")
			var player: = AudioStreamPlayer.new()								# Create new player
			add_child(player)
			active_players[sample_name] = player
			player.stream = sample_collection[ sample_dictionary[sample_name] ]
			player.volume_db = vol
			player.play()
			player.connect("finished", self, "sample_finished", [sample_name])


func sample_finished(sample_name:String)->void:									# Triggered when player is finished sample and not retriggered while playing.
	var player:AudioStreamPlayer = active_players[sample_name]
	player.disconnect("finished", self, "sample_finished")
	active_players.erase(sample_name)
	free_players.append(player)


