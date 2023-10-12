extends CharacterBody2D

var can_laser: bool = true
var can_grenade: bool = true

@export var max_speed: int = 500
var speed: int = max_speed

@onready var gpu_particles_2d = $GPUParticles2D


signal laser(pos, direction)
signal grenade(pos, direction)

func _process(_delta):
	if Globals.health <= 0:
		return
	# input
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	Globals.player_pos = global_position
	
	#rotate
	look_at(get_global_mouse_position())
	# laser shooting input
	var playerDirection = (get_global_mouse_position() - position).normalized()
	if Input.is_action_pressed("primary action") and can_laser and Globals.laser_amount > 0:
		Globals.laser_amount -= 1
		var laser_markers = $LaserStartPositions.get_children()
		var selected_laser = laser_markers[randi() % laser_markers.size()]
		can_laser = false
		$TimerLaser.start()
		laser.emit(selected_laser.global_position, playerDirection)
	
	# grenade shooting input
	if Input.is_action_pressed("secondary action") and can_grenade and Globals.grenade_amount > 0:
		Globals.grenade_amount -= 1
		var pos = $LaserStartPositions.get_children()[0].global_position
		can_grenade = false
		$TimerGrenade.start()
		grenade.emit(pos, playerDirection)

func _on_timer_laser_timeout():
	can_laser = true

func _on_timer_grenade_timeout():
	can_grenade = true

func hit():
	Globals.health -= 10
