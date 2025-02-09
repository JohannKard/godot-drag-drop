class_name DropZone
extends Area2D
## This is a simple node that creates a rectangular area2D according to the size it's instantiated
## at. It tracks [Draggable] items that are dropped on it, signaling it's parent [DropArea].

signal draggable_added(zone: DropZone, node: Node2D)
signal draggable_removed(zone: DropZone, node: Node2D)
signal try_shift_contents(zone: DropZone)

@onready var drops: Node2D = $Drops


func _init(pos: Vector2 = Vector2.ZERO, size: Vector2 = Vector2(50, 50)) -> void:
	global_position = pos
	var col_shape := CollisionShape2D.new()
	col_shape.shape = RectangleShape2D.new()
	col_shape.shape.size = size
	self.add_child(col_shape)
	var drop_node := Node2D.new()
	drop_node.name = "Drops"
	self.add_child(drop_node)
	print(self, global_position)


## Determines if a [Draggable] can be dropped in this drop zone.
func can_drop(_node: Node2D = null) -> bool:
	return drops.get_child_count() == 0


## Emits a signal to try getting the [DropArea] to shift contents.
func check_for_space() -> void:
	if not can_drop():
		try_shift_contents.emit(self)


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
