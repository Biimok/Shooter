extends CharacterBody2D

var player_near: bool = false
var active: bool = false
var speed: int = 300
var player
var vulnerable: bool = true
var health: int = 20
@onready var ray_cast_2d = $RayCast2D

func _process(_delta):
	var direction = (Globals.player_pos - position).normalized()
	velocity = direction * speed
	
	
	if active:
		ray_cast_2d.look_at(Globals.player_pos)
		var isPlayer = ray_cast_2d.get_collider() is CharacterBody2D
		
		if isPlayer:
			$AnimatedSprite2D.play("walk")
			look_at(Globals.player_pos)
			move_and_slide()
		else:
			$AnimatedSprite2D.stop()

func hit():
	if vulnerable:
		health -= 10
		vulnerable = false
		$Timers/HitTimer.start()
		$AnimatedSprite2D.material.set_shader_parameter("progress", 0.7)
		$Particles/HitParticles.emitting = true
		$AudioStreamPlayer2D.play()
	if health <= 0:
		await get_tree().create_timer(0.5).timeout
		queue_free()

func _on_notice_area_body_entered(_body):
	active = true
	

func _on_notice_area_body_exited(_body):
	active = false
	$AnimatedSprite2D.stop()

func _on_attack_area_body_entered(body):
	player_near = true
	$AnimatedSprite2D.play("attack")
	player = body

func _on_attack_area_body_exited(_body):
	player_near = false

func _on_attack_cooldown_timeout():
	$AnimatedSprite2D.play("attack")

func _on_hit_timer_timeout():
	vulnerable = true
	$AnimatedSprite2D.material.set_shader_parameter("progress", 0)

func _on_animated_sprite_2d_animation_finished():
	if player_near  && 'hit' in player:
		player.hit()
		$Timers/AttackCooldown.start()
