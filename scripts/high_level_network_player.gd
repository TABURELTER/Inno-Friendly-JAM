extends CharacterBody2D

var BASE_SPEED: float = 150
var SPRINT_MULTIPLIER: float = 3.0

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
