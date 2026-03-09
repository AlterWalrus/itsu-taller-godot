extends Node

var score = 0

@export var ENEMY_SCENE: PackedScene
@export var BLOOD_SCENE: PackedScene

func _ready() -> void:
	$EnemySpawner.timeout.connect(_enemy_spawn)
	$Player.damaged.connect(_on_player_damaged)
	$GameOver.show()
	$GameOver/TexturedRect.modulate = Color.TRANSPARENT
	$UI/BloodDamage.show()
	$UI/BloodDamage.modulate = Color.TRANSPARENT

func _enemy_spawn():
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	var center = Vector2(320, 240)
	enemy.position = center + Vector2.from_angle(randf() * 360) * 480
	enemy.player = $Player
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)

func _on_enemy_died(pos):
	var tween = create_tween()
	tween.tween_method(func(value: int): $UI/Score.text = str(value), score, score + 100, 0.5)
	score += 100
	
	var b: Sprite2D = BLOOD_SCENE.instantiate()
	b.position = pos
	b.scale = Vector2.ONE * 0.1
	b.rotation_degrees = randf() * 360
	b.modulate.a = randf_range(0.5, 0.8)
	var v = randf_range(-0.2, 0.2)
	create_tween().tween_property(b, "scale", Vector2.ONE + (Vector2.ONE * v) , 0.5).set_trans(Tween.TRANS_CUBIC)
	$Blood.add_child(b)

func _on_player_damaged(health):
	var t = create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property($UI/HealthBar, "value", health, 0.5)
	
	$UI/BloodDamage.modulate.a = 0.5
	create_tween().tween_property($UI/BloodDamage, "modulate", Color.TRANSPARENT, 1).set_trans(Tween.TRANS_QUAD)
	
	await t.finished
	
	if health <= 0:
		create_tween().tween_property($GameOver/TexturedRect, "modulate", Color.WHITE, 2)
		get_tree().paused = true
