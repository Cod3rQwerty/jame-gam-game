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

@export_group("Climbing Parameters")
@export var climb_speed: float = 100.0

@export_group("Physics")
@export var gravity: float = 900.0

# --- Node References ---
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var slime_detector: Area2D = $SlimeDetector
@onready var down: RayCast2D = $Down
@onready var left: RayCast2D = $Left
@onready var right: RayCast2D = $Right

var is_on_slime: bool = false
var is_laying_slime: bool = false

func _physics_process(delta: float) -> void:
	# Only apply slime speed boost if standing on slime and NOT currently laying slime
	is_on_slime = _check_if_on_slime() and not is_laying_slime

	# Check wall collisions using your RayCast2D nodes
	var touching_left_wall = left.is_colliding()
	var touching_right_wall = right.is_colliding()
	var is_on_wall = touching_left_wall or touching_right_wall

	# Select movement attributes based on slime state
	var current_max_speed = slime_speed if is_on_slime else normal_speed
	var current_accel = slime_acceleration if is_on_slime else normal_acceleration
	var current_friction = slime_friction if is_on_slime else normal_friction

	var h_direction = Input.get_axis("move-left", "move-right")
	var v_direction = Input.get_axis("move-up", "move-down") # Change to your vertical action names if custom

	if is_on_wall:
		if touching_left_wall:
			sprite_2d.global_rotation = deg_to_rad(90)
			sprite_2d.flip_h = v_direction <= 0
		else: 
			sprite_2d.global_rotation = deg_to_rad(-90)
			sprite_2d.flip_h = v_direction > 0
			
		# Disable gravity while stuck to a wall so the snail doesn't slide down automatically
		velocity.y = 0.0

		# Vertical climbing movement
		if v_direction != 0:
			velocity.y = v_direction * climb_speed

		# Horizontal control against/away from the wall
		if h_direction != 0:
			velocity.x = move_toward(velocity.x, h_direction * current_max_speed, current_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)
			
	else:
		sprite_2d.global_rotation = deg_to_rad(0)
		sprite_2d.flip_h = h_direction < 0
		
		if not is_on_floor():
			velocity.y += gravity * delta

		if h_direction != 0 and is_on_floor():
			velocity.x = move_toward(velocity.x, h_direction * current_max_speed, current_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)

	move_and_slide()

func _check_if_on_slime() -> bool:
	return slime_detector.get_overlapping_areas() != []

func _on_begun_laying_slime() -> void:
	is_laying_slime = true

func _on_stopped_laying_slime() -> void:
	is_laying_slime = false
