extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/high_level_example.tscn")
	HighLevelNetworkHandler.start_server()

func _on_connect_pressed() -> void:
	HighLevelNetworkHandler.start_client($VBoxContainer2/ip.text)
	get_tree().change_scene_to_file("res://scenes/high_level_example.tscn")
