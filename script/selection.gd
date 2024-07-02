extends Object
class_name TileAction

const ACTION_COLOR = Vector3(0.65,0.84,0.24)

enum Kind {
	ACTIVE,
	ACTION
}

var target = null
var kind = null
var global_position = null

func _init(target, kind: Kind, global_position: Vector2):
	self.target = target
	self.kind = kind
	self.global_position = global_position

func update_cursor(cursor: Sprite2D):
	var material = cursor.material
	var animator = cursor.get_node("%SelectionAnimator")
	match self.kind:
		Kind.ACTIVE:
			material.set_shader_parameter("color", null)
			animator.play("pulse")
		Kind.ACTION:
			material.set_shader_parameter("color", ACTION_COLOR)
			animator.play("static")

func relative(location: Vector2) -> TileAction:
	var relative = global_position - location
	return TileAction.new(target, kind, relative)

func tile_pos_global() -> Vector2i:
	return Utils.to_grid(self.global_position)

func tile_pos_relative(location: Vector2) -> Vector2i:
	return Utils.to_grid(global_position - location)
