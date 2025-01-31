extends Spatial

onready var go_to_game_results_scene_timer = $GoToGameResultsSceneTimer
onready var exit_to_menu = $ExitToMenu
onready var finish_training_game = $FinishTrainingGame

var total_score: int = 0
var num_apples_picked: int = 0
var max_combo = 0
var game_play_data
var is_evaluation_mode = false

const WAIT_BEFORE_GO_TO_RESULTS_TIME = 3

signal exit_to_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	exit_to_menu.connect("exit_to_menu", self, "_on_ExitToMenu_exit_to_menu")
	finish_training_game.connect("start_evaluation", self, "_on_FinishTrainingGame_start_evaluation")
	# Set up the go to game results scene timer
	go_to_game_results_scene_timer.set_one_shot(true)
	go_to_game_results_scene_timer.set_wait_time(WAIT_BEFORE_GO_TO_RESULTS_TIME)
	
	# Set up interactive objects
	setup_apples()

	
func set_player(player):
	# Add the player to GamePlayScene with human readable name
	add_child(player, true)
	player.set_name("ARVROrigin")
	$ARVROrigin/LeftHand/RemainingTimeWatch.set_visible(false)
	$ARVROrigin/RightHand/ScoreAndComboWatch.set_visible(false)

func set_game_play_data(data):
	game_play_data = data

# Connect custom signals with apples and make them interactable
func setup_apples():
	for child in $AppleTree_TrainingGame.get_children():
		if "Branch" in child.get_groups():
			for branch_child in child.get_children():
				if "AppleCluster" in branch_child.get_groups():
					branch_child.is_interactable = true

func set_apple_pickable():
	for child in $AppleTree_TrainingGame.get_children():
		if "Branch" in child.get_groups():
			for branch_child in child.get_children():
				if "AppleCluster" in branch_child.get_groups():
					branch_child.is_interactable = true
	
func set_apple_not_pickable():
	for child in $AppleTree_TrainingGame.get_children():
		if "Branch" in child.get_groups():
			for branch_child in child.get_children():
				if "AppleCluster" in branch_child.get_groups():
					branch_child.is_interactable = false
					
func _on_ExitToMenu_exit_to_menu():
	emit_signal("exit_to_menu")

func _on_GoToGameResultsSceneTimer_timeout():
	# Set the game play data
	if game_play_data:
		game_play_data.set_score(total_score)
		game_play_data.set_highest_score(0)
		game_play_data.set_num_picked(num_apples_picked)
		game_play_data.set_max_combo(max_combo)
		
	emit_signal("go_to_game_results", game_play_data)
	
func _on_FinishTrainingGame_start_evaluation():
	is_evaluation_mode = true
	set_apple_not_pickable()
	var evaluation_stats = $AppleTree_TrainingGame.evaluate()
	$EvaluationStatsBoard.show_data(evaluation_stats)
	$Instructions.set_visible(false)
	$FeedbackIconBoard.set_visible(true)
	

func _on_BGM_Player_finished():
	if !is_evaluation_mode:
		$BGM_Player.play()
