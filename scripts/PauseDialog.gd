extends MeshInstance

signal resume_button_pressed
signal exit_button_pressed


# Called when the node enters the scene tree for the first time.
func _ready():
	disable()
	
func enable():
	set_visible(true)
	$ResumeButton/ResumeButtonArea.set_monitoring(true)
	$ExitButton/ExitButtonArea.set_monitoring(true)
	
func disable():
	set_visible(false)
	$ResumeButton/ResumeButtonArea.set_monitoring(false)
	$ExitButton/ExitButtonArea.set_monitoring(false)

func _on_ResumeButtonArea_area_entered(area):
	if "HandArea" in area.get_groups():
		emit_signal("resume_button_pressed")


func _on_ExitButtonArea_area_entered(area):
	if "HandArea" in area.get_groups():
		emit_signal("exit_button_pressed")
