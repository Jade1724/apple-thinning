extends "res://scripts/AppleCluster_Training_Thinning_Tutorial.gd"


# On ready attach all apples to correct groups
func _ready():
	var apple_type
	for apple in get_children():
		if apple.get_groups().has("Apple"):
			apple_type = apple.get_groups()
			if "HealthyLarge" in apple_type:
				apple.connect("on_picked", self, "_on_HealthyLargeApple_on_picked")
			elif "HealthySmall" in apple_type:
				apple.connect("on_picked", self, "_on_HealthySmallApple_on_picked")
			elif "Damaged" in apple_type:
				apple.connect("on_picked", self, "_on_DamagedApple_on_picked")

#Checks cluster health and returns bool; true if no damaged apples exist, false if damagage apples still unpicked
func check_health():
	var all_healthy = true
	for child in get_children():    
		if child.get_groups().has("Damaged") and !child.picked_off:   #check there are no damaged apples remaining in cluster using their "picked_off" var
			all_healthy = false
	return all_healthy

# function to hide all stars
func hide_stars():
	$OneStar.set_visible(false)
	$DoubleStars.set_visible(false)
	$TripleStars.set_visible(false)

# function to display correct amount of stars
func display_stars():
	var apple_type
	var score = 1

	#traverse nodes checking for large apples, add star for each large
	for apple in get_children():
		if apple.get_groups().has("Apple"):
			apple_type = apple.get_groups()
			if "HealthyLarge" in apple_type and !apple.picked_off:
				score += 1
	
	# display the score to player
	if score == 1:
		$OneStar.set_visible(true)
	elif score == 2:
		$DoubleStars.set_visible(true)
	else:
		$TripleStars.set_visible(true)


# Following three functions are inherited and check_apples() added on pick triggers
func check_apples():
	var healthy = check_health()  #checks if any unhealth apples, true if only healty remain
	if MAX_APPLE_NUM_TO_LEAVE == remaining_apple_count and healthy:
		$Tick.set_visible(true)
		$Exclamation.set_visible(false)
		$Warning.set_visible(false)
		display_stars()
	elif MAX_APPLE_NUM_TO_LEAVE == remaining_apple_count:
		$Exclamation.set_visible(false)
		$Tick.set_visible(false)
		$Warning.set_visible(true)
	else:
		$Tick.set_visible(false)
		$Exclamation.set_visible(true)
		$Warning.set_visible(false)
		hide_stars()


# Following three functions are inherited and check_apples() added on pick triggers


func _on_HealthyLargeApple_on_picked(apple):
	emit_signal("apple_picked")
	play_apple_picked_sound()
	remaining_apple_count -= 1
	check_apples()
	

func _on_HealthySmallApple_on_picked(apple):
	emit_signal("apple_picked")
	play_apple_picked_sound()
	remaining_apple_count -= 1
	check_apples()

func _on_DamagedApple_on_picked(apple):
	emit_signal("apple_picked")
	play_apple_picked_sound()
	remaining_apple_count -= 1
	check_apples()
