class_name DropArea
extends Node2D
## This represents and manages a collection of [DropZone]s, each tracking
## when [Draggable]s are dropped on them and signaling up to this.
## It uses it's exported values to create the desired number of areas, at
## a desired size, and a desired distance between them.

@export var max_zones := 5 ## The number of drop zones to instantiate.
@export var zone_size := Vector2(50, 50) ## The size (px) of the collision area for a drop zone.
@export var gap := 100 ## The gap (px) between each drop zone in the area.
@export var overflow_area: DropArea

var zones: Array[DropZone] = [] : ## The array of drop zone nodes.
	get:
		var z: Array[DropZone] = []
		for child in zones_container.get_children():
			z.push_back(child as DropZone)
		return z

@onready var zones_container: Node2D = $Zones

func _ready() -> void:
	for i in range(max_zones):
		var zone_pos := Vector2(i * (zone_size.x + gap), global_position.y)
		var drop_zone := DropZone.new(zone_pos, zone_size)
		drop_zone.draggable_added.connect(_on_zone_draggable_added)
		drop_zone.draggable_removed.connect(_on_zone_draggable_removed)
		drop_zone.try_shift_contents.connect(_on_try_shift_contents)
		zones_container.add_child(drop_zone)


## Returns the first [DropZone] in the drop area that has space to drop a [Draggable].
func get_available_space_zone() -> DropZone:
	for zone in zones:
		if zone.can_drop():
			return zone
	return null


## Tries to shift contents between [member zones] to make space for a [Draggable] to be dropped.
## If [member overflow_area] is available, will also use that space when moving contents.
func _on_try_shift_contents(zone: DropZone) -> void:
	var idx := zones.find(zone)
	if idx == -1:
		return
	# Check left first, starting from curr zone's idx - 1
	var left_idx := _find_left_space(idx)
	if left_idx != -1:
		_shift_left(idx, left_idx)
		return
	# Then check right starting from curr zone's idx + 1
	var right_idx = _find_right_space(idx)
	if right_idx != -1:
		_shift_right(idx, right_idx)
		return
	# Then check if there's any overflow spaces available
	if overflow_area != null:
		var overflow_zone = overflow_area.get_available_space_zone()
		if overflow_zone != null:
			zone.get_draggable().set_parent_zone(overflow_zone.drops)


## Returns index of the first [member zones] array without a [Draggable] left of idx.
func _find_left_space(idx: int) -> int:
	for i in range(idx - 1, -1, -1): # Use -1 as bottom threshold because an array is 0-based
		if zones[i].can_drop():
			return i
	return -1


## Returns index of the first [member zones] array without a [Draggable] right of idx.
func _find_right_space(idx: int) -> int:
	for i in range(idx + 1, zones.size()):
		if zones[i].can_drop():
			return i
	return -1


## Shifts [Draggable] of each [DropZone] in [member zones] between left_idx and idx to the left.
func _shift_left(idx: int, left_idx: int) -> void:
	for i in range(left_idx + 1, idx + 1):
		zones[i].remove_draggable()
		zones[i - 1].add_draggable(zones[i].get_draggable())


## Shifts [Draggable] of each [DropZone] in [member zones] between idx and right_idx to the right.
func _shift_right(idx: int, right_idx: int) -> void:
	for i in range(right_idx - 1, idx - 1, -1):
		zones[i].remove_draggable()
		zones[i + 1].add_draggable(zones[i].get_draggable())


func _on_zone_draggable_added(_zone: DropZone, _node: Node2D) -> void:
	print("added")
	pass


func _on_zone_draggable_removed(_zone: DropZone, _node: Node2D) -> void:
	print("removed")
	pass
