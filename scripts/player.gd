class_name Player
extends CharacterBody2D

signal damaged

var health = 100

@export var speed = 5.0
@export var BULLET_SCENE: PackedScene

func _ready() -> void:
	$DamageDetector.body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed
	move_and_slide()
	
	look_at(get_global_mouse_position())

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		if $RayCast2D.is_colliding():
			var body = $RayCast2D.get_collider()
			if body is Enemy:
				body.die()
			var local_collision_point = to_local($RayCast2D.get_collision_point())
			$Line2D.set_point_position(1, local_collision_point)
		else:
			$Line2D.set_point_position(1, $RayCast2D.target_position)
		
		$ShootSpark.show()
		$ShootSpark.rotation_degrees = randf() * 360
		$Line2D.show()
		await get_tree().create_timer(0.1).timeout
		$ShootSpark.hide()
		$Line2D.hide()

func _on_body_entered(body):
	if body is Enemy:
		health -= 10
		damaged.emit(health)
