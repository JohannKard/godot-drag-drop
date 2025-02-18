extends Node2D


func _on_button_pressed() -> void:
	var contents: Array[Node2D] = $DropArea.get_contents_raw()
	contents.append_array($DropArea2.get_contents_raw())
	print(contents)
