extends VBoxContainer

# Если HighLevelNetworkHandler в автозагрузах:
@onready var net_handler = HighLevelNetworkHandler

var lobbies: Array = []

func _ready() -> void:
	clear_lobby_buttons()

func _process(_delta: float) -> void:
	# Проверяем, изменился ли список
	if lobbies.size() != net_handler.found_lobbies.size():
		update_lobbies(net_handler.found_lobbies)

func update_lobbies(new_lobbies: Array) -> void:
	lobbies = new_lobbies
	clear_lobby_buttons()
	
	for lobby in lobbies:
		var btn := Button.new()
		btn.text = "%s (%s:%d)" % [lobby["name"], lobby["ip"], lobby["port"]]
		btn.pressed.connect(_on_connect_pressed.bind(lobby))
		add_child(btn)

func clear_lobby_buttons() -> void:
	for child in get_children():
		child.queue_free()

func _on_connect_pressed(lobby: Dictionary) -> void:
	print("Подключаемся к:", lobby)
	net_handler.start_client(lobby["ip"])
	get_tree().change_scene_to_file("res://scenes/high_level_example.tscn")
