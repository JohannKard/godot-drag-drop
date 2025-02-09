class_name Draggable
extends Area2D
## Add this as a child of a [Node2D] to make it draggable and droppable on [DropZone]s.
## If this is needed beyond [Node2D]s, update the [DropZone] logic to support other node types.

## Set this to true to have the draggable follow it's grandparent [member Draggable.parent_zone]
var is_following := false

@onready var og_parent_zone: Node = get_parent().get_parent() ## Tracks the last [DropZone] that owned this.
@onready var parent_zone: Node = og_parent_zone ## Tracks the current [DropZone] that owns this.
@onready var og_pos: Vector2 = global_position ## Tracks the last stable global_position this was at.
@onready var target_pos: Vector2 = og_pos ## Tracks the target position for this to move toward.


func _physics_process(_delta: float) -> void:
	if is_following:
		target_pos = parent_zone.global_position
	if round(get_parent().global_position) != round(target_pos):
		get_parent().global_position = lerp(get_parent().global_position, target_pos, 0.3)


## Sets the target [DropZone] as [member parent_zone] for this and it's parent.
## Moving it to the [member parent_zone]'s position.
func set_parent_zone(zone: Node) -> void:
	is_following = false
	og_parent_zone = parent_zone
	parent_zone = zone
	get_parent().reparent.call_deferred(parent_zone)
	og_pos = target_pos
	target_pos = parent_zone.global_position


## Resets [member parent_zone] to the [member og_parent_zone].
func reset_parent() -> void:
	set_parent_zone(og_parent_zone)
