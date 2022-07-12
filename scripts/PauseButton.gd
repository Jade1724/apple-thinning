extends MeshInstance

signal pause_button_pressed
 
# Called when the node enters the scene tree for the first time.
func _ready():
	enable()

func enable():
	set_visible(true)
	$PauseButtonArea.set_monitoring(true)
	
func disable():
	set_visible(false)
	$PauseButtonArea.set_monitoring(false)
	
func _on_PauseButtonArea_area_entered(area):
	if "HandArea" in area.get_groups():
		emit_signal("pause_button_pressed")
