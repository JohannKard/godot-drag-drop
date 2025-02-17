class_name MouseZone
extends Area2D

var hovered_drop_zone: DropZone = null
var held_draggable: Draggable = null


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	if held_draggable != null:
		held_draggable.target_pos = self.global_position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('mouse_drag') and held_draggable == null:
		for area in self.get_overlapping_areas():
			if area is Draggable:
				held_draggable = area
				break
		if held_draggable:
			held_draggable.set_parent_zone(self)
			held_draggable.is_following = true
	if event.is_action_released('mouse_drag') and held_draggable != null:
		if hovered_drop_zone != null and hovered_drop_zone.can_drop(held_draggable):
			hovered_drop_zone.add_draggable(held_draggable)
		else:
			held_draggable.reset_parent()
		held_draggable = null
		hovered_drop_zone = null


func _on_area_entered(area: Area2D) -> void:
	if area is DropZone and held_draggable != null:
		hovered_drop_zone = area
		hovered_drop_zone.check_for_space(held_draggable)
