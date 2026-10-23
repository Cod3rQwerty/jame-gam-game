extends CharacterBody2D

# --- Movement Parameters ---
@export_group("Base Movement")
@export var normal_speed: float = 80.0
@export var normal_acceleration: float = 400.0
@export var normal_friction: float = 800.0

@export_group("Slime Movement")
@export var slime_speed: float = 300.0
@export var slime_acceleration: float = 1200.0
@export var slime_friction: float = 200.0

@export_group("Physics")
@export var gravity: float = 900.0

# --- Node References ---
@onready var slime_detector: Area2D = $SlimeDetector


var is_on_slime: bool = false
var is_laying_slime: bool = false

func _physics_process(delta: float) -> void:
	# Only apply slime speed boost if standing on slime and NOT currently laying slime
	is_on_slime = _check_if_on_slime() and not is_laying_slime

	if not is_on_floor():
		velocity.y += gravity * delta

	# Select movement attributes based on slime state
	var current_max_speed = slime_speed if is_on_slime else normal_speed
	var current_accel = slime_acceleration if is_on_slime else normal_acceleration
	var current_friction = slime_friction if is_on_slime else normal_friction

	var direction = Input.get_axis("move-left", "move-right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * current_max_speed, current_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)

	move_and_slide()

func _check_if_on_slime() -> bool:
	return slime_detector.get_overlapping_areas() != []

func _on_begun_laying_slime() -> void:
	is_laying_slime = true

func _on_stopped_laying_slime() -> void:
	is_laying_slime = false
