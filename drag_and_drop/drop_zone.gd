class_name DropZone
extends Area2D
## This is a simple node that creates a rectangular [Area2D] according to the size it's instantiated
## at. It tracks [Draggable] items that are dropped on it, signaling it's parent [DropArea].

## Emitted when a [Draggable] is added to [member drops].
signal draggable_added(zone: DropZone, node: Node2D)
## Emitted when a [Draggable] is removed from [member drops].
signal draggable_removed(zone: DropZone, node: Node2D)
## Emitted when a [Draggable] is hovered over this, calls up to parent [DropArea] to try and make
## space for the [Draggable] to be dropped on this drop zone.
signal try_shift_contents(zone: DropZone, draggable: Draggable)

var drop_type := Consts.DropType.NONE ## The type of [Draggable]s allowed to be dropped in the zone.
var drops: Node2D ## An container for [Draggable] child nodes (should be restricted to 1).


func _init(pos: Vector2 = Vector2.ZERO, size: Vector2 = Vector2(50, 50),
						type: Consts.DropType = Consts.DropType.NONE) -> void:
	global_position = pos
	var col_shape := CollisionShape2D.new()
	col_shape.shape = RectangleShape2D.new()
	col_shape.shape.size = size
	self.add_child(col_shape)
	## Add a node to act as a container for [Draggable]s
	var drop_node := Node2D.new()
	drop_node.name = "Drops"
	self.add_child(drop_node)
	drops = drop_node
	drop_type = type


## Determines if a [Draggable] can be dropped in this drop zone.
func can_drop(draggable: Draggable) -> bool:
	var is_type := true
	if draggable != null:
		is_type = draggable.drop_type == drop_type
	return drops.get_child_count() == 0 and is_type


## Emits a signal to try getting the [DropArea] to shift contents.
func check_for_space(draggable: Draggable) -> void:
	if not can_drop(draggable):
		try_shift_contents.emit(self, draggable)


## Retrieves the node stored as the dropped content (The parent of a [Draggable]).
func get_dropped_node() -> Node2D:
	if drops.get_child_count() > 0:
		return drops.get_child(0)
	return null


## Retrieves the [Draggable] child content.
func get_draggable() -> Draggable:
	var dropped := get_dropped_node()
	if dropped == null:
		return null
	return dropped.find_child("Draggable")


## Emits a signal consumed by the parent [DropArea] to add a dropped [Draggable].
## Handles reparenting of the [Draggable] and it's parent node.
## Invoke from a [MoseZone] node when dropped over this drop zone.
func add_draggable(draggable: Draggable) -> void:
	draggable.set_parent_zone(drops)
	draggable_added.emit(self, draggable.get_parent())


## Emits a signal consumed by the parent [DropArea] to remove a dropped [Draggable].
## Invoke from a [Draggable] node when removed from this drop zone.
func remove_draggable() -> void:
	draggable_removed.emit(self, get_draggable())
