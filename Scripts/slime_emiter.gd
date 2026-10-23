extends Node2D

const SLIME: PackedScene = preload("res://Scenes/Slime.tscn")

@onready var slime_detector: Area2D = $"../SlimeDetector"

signal begun_laying_slime
signal stopped_laying_slime

@export var drop_interval: float = 0.15  # Time (seconds) between dropping slime chunks
var drop_timer: float = 0.0
var is_active: bool = false

func _process(delta: float) -> void:
	var wants_to_lay = Input.is_action_pressed("lay-slime")
	
	if wants_to_lay and not is_active:
		is_active = true
		begun_laying_slime.emit()
		drop_timer = 0.0
	elif not wants_to_lay and is_active:
		is_active = false
		stopped_laying_slime.emit()
	
	# Drop Slime
	if is_active:
		drop_timer -= delta
		if drop_timer <= 0.0:
			drop_timer = drop_interval
			spawn_slime()

func spawn_slime() -> void:
	var new_slime: Area2D = SLIME.instantiate()
	new_slime.global_position = global_position
	get_tree().root.add_child(new_slime)
