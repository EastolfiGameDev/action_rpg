extends Move

class_name Wander

export(NodePath) var WanderControllerPath: NodePath
export(int) var min_wander_time := 1
export(int) var max_wander_time := 3

onready var WanderController = get_node(WanderControllerPath)

func enter():
    WanderController.set_timer_duration(rand_range(min_wander_time, max_wander_time))

func exit():
    WanderController.stop_wander()

func handle_physics_process(delta):
    WanderController.wander()
    accelerate_towards(WanderController.target_position, delta)
    
    .handle_physics_process(delta)


func _on_WanderControler_wander_finish():
    pick_random_state()
