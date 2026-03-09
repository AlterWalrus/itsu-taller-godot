class_name Bullet
extends Area2D

var direction := Vector2.ZERO
var speed := 0
var alive := true

func _ready() -> void:
	body_entered.connect(_collision)

func _process(delta: float) -> void:
	position += direction * speed * delta

func _collision(body):
	if body is Enemy and alive:
		alive = false
		body.die()
		call_deferred("queue_free")
