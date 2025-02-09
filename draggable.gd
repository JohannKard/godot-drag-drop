class_name Draggable
extends Area2D
## Add this as a child of a [Node2D] to make it draggable and droppable on [DropZone]s.
## If this is needed beyond [Node2D]s, update the [DropZone] logic to support other node types.

## Set this to true to have the draggable follow it's grandparent [member Draggable.parent_zone]
var is_following := false

@onready var og_parent_zone: Node = get_parent().get_parent()
@onready var parent_zone: Node = og_parent_zone
@onready var og_pos: Vector2 = global_position
@onready var target_pos: Vector2 = og_pos


func _physics_process(_delta: float) -> void:
	if is_following:
		target_pos = parent_zone.global_position
	if round(get_parent().global_position) != round(target_pos):
		get_parent().global_position = lerp(get_parent().global_position, target_pos, 0.3)


func set_parent_zone(zone: Node) -> void:
	is_following = false
	og_parent_zone = parent_zone
	parent_zone = zone
	get_parent().reparent.call_deferred(parent_zone)
	og_pos = target_pos
	target_pos = parent_zone.global_position


func reset_parent() -> void:
	set_parent_zone(og_parent_zone)


func shift_global_position(pos: Vector2) -> void:
	og_pos = target_pos
	target_pos = pos


func reset_position() -> void:
	target_pos = og_pos
