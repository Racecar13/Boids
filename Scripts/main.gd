extends Node2D

# Server to receive camera data
const PORT: int = 4242
const BOID = preload("res://Scenes/boid.tscn")
var server:= UDPServer.new()

# Boid parameters
var max_speed: float = 1
var color: Color = Color.BLACK
var avoid_radius: float = 30
var neighbor_radius: float = 40
var noise_strength = 0.1
var attract_strength = 1
var avoid_strength = 1
var align_strength = 1

# Process identifier for python script
@onready var pid

func _ready():
	# Spawn boids
	for i in range(100):
		add_child(BOID.instantiate())
	
	# Setup server
	server.listen(PORT)
	
	# Run hand_detection.py script
	var python = "Python/.venv/Scripts/python"
	var hand_detection_py = "Python/hand_detection.py"
	if OS.has_feature("editor"):
		python = ProjectSettings.globalize_path(python)
		hand_detection_py = ProjectSettings.globalize_path(hand_detection_py)
	else:
		python = OS.get_executable_path().get_base_dir().path_join(python)
		hand_detection_py = OS.get_executable_path().get_base_dir().path_join(hand_detection_py)
	pid = OS.create_process(python, [hand_detection_py])

func _parse_data(data: PackedByteArray) -> Dictionary:
	# Convert json packet to dictionary
	var json_string = data.get_string_from_utf8()
	var json = JSON.new()
	
	var error = json.parse(json_string)
	assert(error == OK)
	
	var data_received = json.data
	assert(typeof(data_received) == TYPE_DICTIONARY)
	
	return data_received

func _process(_delta: float) -> void:
	server.poll()
	if server.is_connection_available():
#		# Receive packet
		var peer = server.take_connection()
		var data = peer.get_packet()
		var hands = _parse_data(data)
		
		# Can be null if no hand detected
		if hands["left"] != null and hands["right"] != null:
			update_parameters(hands)

func update_parameters(hands):
	# Hands
	var left_hand = hands["left"]
	var right_hand = hands["right"]
	
	# Fingers
	var left_thumb = Vector3(left_hand[4][0], left_hand[4][1], left_hand[4][2])
	var right_thumb = Vector3(right_hand[4][0], right_hand[4][1], right_hand[4][2])
	var left_index = Vector3(left_hand[8][0], left_hand[8][1], left_hand[8][2])
	var right_index = Vector3(right_hand[8][0], right_hand[8][1], right_hand[8][2])
	
	# Set parameters
	noise_strength = left_index.distance_to(left_thumb) * 3
	attract_strength = right_index.distance_to(right_thumb) * 3
	align_strength = right_index.distance_to(right_thumb) * 3
	Engine.time_scale = left_index.distance_to(right_index) * 300
	color = Color(2 * (left_index - left_thumb).angle_to(Vector3.UP) / PI, 0, (right_index - right_thumb).angle_to(Vector3.UP) / PI)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		OS.kill(pid) # kill hand_detection.py on quit
		get_tree().quit() # default behavior
