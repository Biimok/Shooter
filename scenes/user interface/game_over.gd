extends CanvasLayer

func _on_button_pressed():
	await TransitionLayer.reload_scene()
	hide()
	Globals.restart_level()

func _process(_delta):
	if Globals.health <= 0:
		show()
