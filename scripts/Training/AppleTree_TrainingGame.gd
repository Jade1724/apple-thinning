extends Spatial

onready var apple_cluster_a = preload("res://Scenes/Training/AppleCluster_TrainingGame_TypeA.tscn")
onready var apple_cluster_b = preload("res://Scenes/Training/AppleCluster_TrainingGame_TypeB.tscn")
onready var apple_cluster_c = preload("res://Scenes/Training/AppleCluster_TrainingGame_TypeC.tscn")
onready var apple_cluster_fall_sound_player = get_node("AppleClusterFallSoundPlayer")
onready var rng = RandomNumberGenerator.new()
onready var cluster_type
onready var cluster_spawn_location
onready var num_cluster = 0
var TrainingGameData = load("res://scripts/Classes/TrainingGameData.gd")

const CLUSTER_PER_BRANCH = 3
const NUM_BRANCH = 3
const TREE_TRANSLATE = Vector3(0, 0, -0.85)
const TREE_ROTATION = Vector3(0, deg2rad(-90), 0)
const MAX_APPLE_NUM_TO_LEAVE = 2

enum EvaluateNumFruitletLeftResult {
	SUCCESSFUL, OVERTHINNED, UNDERTHINNED, MISSED
}

signal all_clusters_thinned

func _ready():
	
	set_translation(TREE_TRANSLATE)
	set_rotation(TREE_ROTATION)
	
	rng.randomize()
	
	# Iterate over branches in the tree
	for child in get_children():
		if 'Branch' in child.get_groups() and child.get_node("AppleClusterSpawnPath"):
			
			var cluster_spawn_location = child.get_node("AppleClusterSpawnPath/PathFollow")
			
			# Spawn the given number of clusters per branch
			for i in range(1, CLUSTER_PER_BRANCH + 1):
				
				# Count the number of apple clusters spawned in the tree.
				num_cluster += 1
				
				# Spanw a cluster with equal spacing distribution
				cluster_spawn_location.set_unit_offset(float(i) / float(CLUSTER_PER_BRANCH))
				# Pick a type of apple cluster to spawn randomly
				cluster_type = rng.randi() % 3

				# Instantiate the apple cluster
				if cluster_type == 0:
					var apple_cluster_a_instance = apple_cluster_a.instance()
					apple_cluster_a_instance.initialize(cluster_spawn_location.translation)
					child.add_child(apple_cluster_a_instance)
					apple_cluster_a_instance.look_at(Vector3(0, 1, 1), Vector3(0, 1, 0))
					
				elif cluster_type == 1:
					var apple_cluster_b_instance = apple_cluster_b.instance()
					apple_cluster_b_instance.initialize(cluster_spawn_location.translation)
					child.add_child(apple_cluster_b_instance)
					apple_cluster_b_instance.look_at(Vector3(0, 1, 1), Vector3(0, 1, 0))
					
				else:
					var apple_cluster_c_instance = apple_cluster_c.instance()
					apple_cluster_c_instance.initialize(cluster_spawn_location.translation)
					child.add_child(apple_cluster_c_instance)
					apple_cluster_c_instance.look_at(Vector3(0, 1, 1), Vector3(0, 1, 0))



# Evaluate the Rule 1: Thin down each cluster into two fruitlets
# Returns enum of result of rule 1 eval. 
func evaluate_num_fruitlet_left(cluster):
	var fruitlet_num_left = cluster.get_remaining_apple_count()
	
	if fruitlet_num_left == MAX_APPLE_NUM_TO_LEAVE:
		return EvaluateNumFruitletLeftResult.SUCCESSFUL
	elif fruitlet_num_left == cluster.initial_apple_count:
		return EvaluateNumFruitletLeftResult.MISSED
	elif fruitlet_num_left > MAX_APPLE_NUM_TO_LEAVE:
		return EvaluateNumFruitletLeftResult.UNDERTHINNED
	else:
		return EvaluateNumFruitletLeftResult.OVERTHINNED



# Evaluate the Rule 2: Remove damaged/diseased fruitlets and leave healthy fruitlets
# Returns the number of diseased fruitlet left on the cluster
func evaluate_diseased_fruitlet_left(cluster):
	return cluster.get_diseased_apple_count()



# Evaluate the Rule 3: Remove smaller fruitlets and leave larger fruitlets
func evaluate_fruitlet_size(cluster):
	var num_large = cluster.get_large_apple_count()
	var num_small = cluster.get_small_apple_count()

	return Vector2(num_large, num_small)



# Evaluate the Rule 4. Leave fruitlets with more sun exposure
#func evaluate_fruitlet_sun_exposure(cluster):
#	return cluster.get_sunshine_apple_count()


func evaluate():
	var training_game_data = TrainingGameData.new()
	
	# For whole tree stats.
	var num_successful_clusters = 0
	var num_overthinned_clusters = 0
	var num_underthinned_clusters = 0
	var num_missed_clusters = 0
	var num_left_damaged = 0
	var num_left_large = 0
	var num_left_small = 0
#	var num_sunshine_apple = 0
	
	# For per cluster stats
	var num_left_damaged_fruitlet
	var nun_left_large_fruitlet
	var num_left_small_fruitlet
	var evaluate_num_fruitlet_left_result
	var large_and_small_count
	
	# Iterate over branches in the tree
	for child in get_children():
		if 'Branch' in child.get_groups():
			for branch_child in child.get_children():
				if "AppleCluster" in branch_child.get_groups():
					# Evaluate the cluster based on the four rules
					
					# Rule 1: Thin down each cluster into two fruitlets
					evaluate_num_fruitlet_left_result = evaluate_num_fruitlet_left(branch_child)
					if evaluate_num_fruitlet_left_result == EvaluateNumFruitletLeftResult.MISSED:
						num_missed_clusters += 1
					elif evaluate_num_fruitlet_left_result == EvaluateNumFruitletLeftResult.UNDERTHINNED:
						num_underthinned_clusters += 1
					elif evaluate_num_fruitlet_left_result == EvaluateNumFruitletLeftResult.OVERTHINNED:
						num_overthinned_clusters += 1
						
					# Rule 2: Remove damaged/diseased fruitlets and leave healthy fruitlets
					num_left_damaged_fruitlet = evaluate_diseased_fruitlet_left(branch_child)
					num_left_damaged += num_left_damaged_fruitlet
					
					# Rule 3: Remove smaller fruitlets and leave larger fruitlets
					large_and_small_count = evaluate_fruitlet_size(branch_child)
					nun_left_large_fruitlet = large_and_small_count.x
					num_left_large += large_and_small_count.x
					num_left_small += large_and_small_count.y
					
					# Rule 4: Leave fruitlets with more sun exposure
#					num_sunshine_apple += evaluate_fruitlet_sun_exposure(branch_child)
					
					# Based on the results of the four rules, show a feedback icon
					if evaluate_num_fruitlet_left_result == EvaluateNumFruitletLeftResult.SUCCESSFUL:
						if num_left_damaged_fruitlet == 0:
							num_successful_clusters += 1
						branch_child.show_evaluation_feedback(true, num_left_damaged_fruitlet, nun_left_large_fruitlet)
					else:
						branch_child.show_evaluation_feedback(false, num_left_damaged_fruitlet, nun_left_large_fruitlet)
					
	training_game_data.set_num_successful_clusters(num_successful_clusters)
	training_game_data.set_num_missed_clusters(num_missed_clusters)
	training_game_data.set_num_underthinned_clusters(num_underthinned_clusters)
	training_game_data.set_num_overthinned_clusters(num_overthinned_clusters)
	training_game_data.set_num_left_damaged(num_left_damaged)
	training_game_data.set_num_left_large(num_left_large)
	training_game_data.set_num_left_small(num_left_small)
	
	return training_game_data
