class_name Enemy
extends StaticBody2D

signal died

var alive = true

@export var player: CharacterBody2D
@export var speed := 50

func _ready() -> void:
	var c = randf()
	modulate = Color(0.5, c, c)

func _process(delta: float) -> void:
	if player != null and alive:
		var direction = (player.global_position - global_position).normalized()
		move_and_collide(direction * speed * delta)
		look_at(player.position)

func die():
	alive = false
	died.emit(position)
	$Blood.emitting = true
	$CollisionShape2D.set_deferred("disabled", true)
	var t = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
	t.set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE * 0.01, 1)
	t.tween_property(self, "modulate", Color.DARK_RED, 0.5)
	
	
	
	t.finished.connect(queue_free)
