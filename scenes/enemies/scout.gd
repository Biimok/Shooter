extends CharacterBody2D

var player_nearby: bool = false
var can_laser: bool = true
var vulnerable: bool = true
var health: int = 30
@onready var ray_cast_2d = $RayCast2D

signal laser(pos, direction)

func _process(_delta):
	
	if player_nearby:
		ray_cast_2d.look_at(Globals.player_pos)
		var isPlayer = ray_cast_2d.get_collider() is CharacterBody2D
		if isPlayer:
			look_at(Globals.player_pos)
		
		if can_laser && isPlayer:
			var laser_markers = $LaserSpawnPositions.get_children()
			var selected_laser = laser_markers.pick_random()
			var direction: Vector2 = (Globals.player_pos - position).normalized()
			laser.emit(selected_laser.global_position, direction)
			can_laser = false
			$Timers/LaserTimer.start()

func hit():
	if vulnerable:
		health -= 10
		vulnerable = false
		$Timers/HitTimer.start()
		$Sprite2D.material.set_shader_parameter("progress", 1)
		$AudioStreamPlayer2D.play()
	if health <= 0:
		queue_free()

func _on_attack_area_body_entered(body):	
	player_nearby = true

func _on_attack_area_body_exited(_body):
	player_nearby = false

func _on_laser_timer_timeout():
	can_laser = true

func _on_hit_timer_timeout():
	vulnerable = true
	$Sprite2D.material.set_shader_parameter("progress", 0)
