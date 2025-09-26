extends CharacterBody2D

var BASE_SPEED: float = 150
var SPRINT_MULTIPLIER: float = 3.0

@export var max_health: int = 100
@export var current_health: int = 100

#func _check_state_transitions(delta: float):
	#if self.health < 0:
		#if current_state != UnitState.DIED: # If not already dead
			#current_state = UnitState.DYING
	
	#elif Input.is_action_just_pressed("left_mouse_button") and self in get_tree().get_nodes_in_group("selected_units"):
		# reset path when clicked
		#current_agent_path.clear() # Can be a source of bug, if extended script expects path to be there
		#current_agent_path_index = 0
		#current_state = UnitState.MOVING

	# Clear the path when the destination is reached
	#elif current_agent_path_index >= current_agent_path.size():
		#current_state = UnitState.IDLE


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	# Камеру активируем только для локального владельца
	var is_local := is_multiplayer_authority()
	$Camera2D.enabled = is_local
	#$Camera2D.current = is_local

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority(): 
		return

	var speed = BASE_SPEED
	var move_vector = Input.get_vector("player_left", "player_right", "player_up", "player_down")

	# Проверка на спринт
	if Input.is_action_pressed("sprint") and move_vector != Vector2.ZERO:
		speed *= SPRINT_MULTIPLIER
		$AnimatedSprite2D.play("run_fast")
	elif move_vector != Vector2.ZERO:
		$AnimatedSprite2D.play("run_slow")
	else:
		$AnimatedSprite2D.play("idle")

	velocity = move_vector * speed

	# Отражение спрайта
	var directions = Input.get_axis("player_left","player_right")
	if directions == 1:
		$AnimatedSprite2D.flip_h = false
	elif directions == -1:
		$AnimatedSprite2D.flip_h = true

	move_and_slide()
