extends Spatial

onready var apple_cluster_a = preload("res://Scenes/TimeAttack/AppleCluster_TimeAttackGame_TypeA.tscn")
onready var apple_cluster_b = preload("res://Scenes/TimeAttack/AppleCluster_TimeAttackGame_TypeB.tscn")
onready var apple_cluster_c = preload("res://Scenes/TimeAttack/AppleCluster_TimeAttackGame_TypeC.tscn")
onready var apple_cluster_fall_sound_player = get_node("AppleClusterFallSoundPlayer")
onready var rng = RandomNumberGenerator.new()
onready var cluster_type
onready var cluster_spawn_location
onready var num_cluster = 0

const CLUSTER_PER_BRANCH = 3
const NUM_BRANCH = 3
const TREE_TRANSLATE = Vector3(0, 0, -0.85)
const TREE_ROTATION = Vector3(0, deg2rad(-90), 0)

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
					apple_cluster_a_instance.connect("cluster_finished", self, "_on_AppleCluster_finished")
					child.add_child(apple_cluster_a_instance)
					apple_cluster_a_instance.look_at(Vector3(0, 1, 1), Vector3(0, 1, 0))
					
				elif cluster_type == 1:
					var apple_cluster_b_instance = apple_cluster_b.instance()
					apple_cluster_b_instance.initialize(cluster_spawn_location.translation)
					apple_cluster_b_instance.connect("cluster_finished", self, "_on_AppleCluster_finished")
					child.add_child(apple_cluster_b_instance)
					apple_cluster_b_instance.look_at(Vector3(0, 1, 1), Vector3(0, 1, 0))
					
				else:
					var apple_cluster_c_instance = apple_cluster_c.instance()
					apple_cluster_c_instance.initialize(cluster_spawn_location.translation)
					apple_cluster_c_instance.connect("cluster_finished", self, "_on_AppleCluster_finished")
					child.add_child(apple_cluster_c_instance)
					apple_cluster_c_instance.look_at(Vector3(0, 1, 1), Vector3(0, 1, 0))


func _on_AppleCluster_finished():
	num_cluster -= 1
	if num_cluster == 0:
		$ThinningCompletedSoundPlayer.play()
		emit_signal("all_clusters_thinned")
