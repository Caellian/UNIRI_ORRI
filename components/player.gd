extends CharacterBody2D
class_name Player

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
var animator = %WalkAnimator
@onready
var camera = %Camera

func _ready():
	Globals.map_change.connect(_on_map_change)
	_on_map_change(Globals.world.get_child(0))

func _update_input_axis():
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return axis.normalized()

func _apply_friction(amount: float):
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

func apply_movement(acceleration: Vector2):
	velocity += acceleration
	velocity = velocity.limit_length(MAX_SPEED)
	_play_axis_move_animation()

var was_moving = false
func _move(delta: float):
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

func teleport_to(position: Vector2):
	self.global_position = position

func teleport_to_location(name: String):
	var locations = get_tree().get_nodes_in_group("location")
	# TODO: Rotate per location requirements
	for it in locations:
		if it.name == name:
			teleport_to((it as Node2D).global_position)
			return
	for it in locations:
		if it.has_method("get_location_name") and it.get_location_name() == name:
			teleport_to((it as Node2D).global_position)
			return
	print_debug("Player unable to find location: " + name)

func set_camera_bounds(bounds: Rect2):
	print("new_limits " + str(bounds))
	camera.limit_left = bounds.position.x
	camera.limit_top = bounds.position.y
	camera.limit_right = bounds.size.x
	camera.limit_bottom = bounds.size.y

func can_interact(with: Node2D):
	var distance_to_position = global_position.distance_to(with.global_position)
	return distance_to_position <= interaction_distance

func _update_interaction(delta):
	if Input.is_action_pressed("interact"):
		interact.emit(selection)

func _physics_process(delta: float):
	_move(delta)
	if selection != null:
		_update_interaction(delta)


func compute_map_bounds(map: Node):
	var limits = Rect2(Vector2(0,0), Vector2(0,0))
	for child in map.get_children():
		if child == null or !child is TileMap or child.tile_set == null:
			continue
		
		var child_limits = child.get_used_rect()
		var cell_size = child.tile_set.tile_size
		limits.position.x = minf(limits.position.x, child_limits.position.x * cell_size.x)
		limits.position.y = minf(limits.position.y, child_limits.position.y * cell_size.y)
		limits.end.x = maxf(limits.end.x, child_limits.end.x * cell_size.x)
		limits.end.y = maxf(limits.end.y, child_limits.end.y * cell_size.y)
	
	return limits

func _on_map_change(new_map):
	set_camera_bounds(compute_map_bounds(new_map))
