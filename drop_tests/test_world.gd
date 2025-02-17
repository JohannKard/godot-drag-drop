extends Node2D


func _on_button_pressed() -> void:
	var contents: Array[Draggable] = $DropArea.get_contents()
	contents.append_array($DropArea2.get_contents())
	print(contents)
