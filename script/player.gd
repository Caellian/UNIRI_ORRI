extends CharacterBody2D

@export
var MAX_SPEED = 150
@export
var ACCELERATION  = 800
@export
var FRICTION = 1600

var interaction_distance = 5

signal selection_changed(selection: PlayerSelection)
signal interact(selection: PlayerSelection)
var selection: PlayerSelection = null

@onready
var axis = Vector2.ZERO
@onready
var animator = $WalkAnimator

func _update_input_axis():
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return axis.normalized()

func _apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

enum Direction {
	BACK,
	FORWARD,
	LEFT,
	RIGHT
}

@export
var last_direction = Direction.BACK

func direction_vec():
	match last_direction:
		Direction.BACK:
			return Vector2(0.0, 1.0)
		Direction.FORWARD:
			return Vector2(0.0, -1.0)
		Direction.RIGHT:
			return Vector2(1.0, 0.0)
		Direction.LEFT:
			return Vector2(-1.0, 0.0)

func _play_axis_move_animation():
	if axis.y > 0:
		last_direction = Direction.BACK
		animator.play("walk_back")
	elif axis.y < 0:
		last_direction = Direction.FORWARD
		animator.play("walk_forward")
	elif axis.x > 0:
		last_direction = Direction.RIGHT
		animator.play("walk_right")
	elif axis.x < 0:
		last_direction = Direction.LEFT
		animator.play("walk_left")

func _play_direction_idle_animation():
	match last_direction:
		Direction.BACK:
			animator.play("idle_back")
		Direction.FORWARD:
			animator.play("idle_forward")
		Direction.RIGHT:
			animator.play("idle_right")
		Direction.LEFT:
			animator.play("idle_left")

func apply_movement(acceleration):
	velocity += acceleration
	velocity = velocity.limit_length(MAX_SPEED)
	_play_axis_move_animation()

var was_moving = false
func _move(delta):
	axis = _update_input_axis()
	
	if axis == Vector2.ZERO:
		_apply_friction(FRICTION * delta)
		if was_moving:
			_play_direction_idle_animation()
			was_moving = false
	else:
		was_moving = true
		apply_movement(axis * ACCELERATION * delta)
	
	move_and_slide()

func can_interact(with: Node2D):
	var distance_to_position = global_position.distance_to(with.global_position)
	return distance_to_position <= interaction_distance

func _update_interaction(delta):
	if Input.is_action_pressed("interact"):
		interact.emit(selection)

func _physics_process(delta):
	_move(delta)
	if selection != null:
		_update_interaction(delta)
