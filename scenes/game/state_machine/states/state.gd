extends Node

class_name State

signal finished(next_state_name)

export(Array, Constants.STATES) var possible_next_random_states = []

# Initialize the state
func enter():
    return

# Clean up the state
func exit():
    return

func handle_input(event):
    return

func handle_process(delta):
    return

func handle_physics_process(delta):
    return


func pick_random_state():
    if possible_next_random_states and possible_next_random_states.size() > 1:
        var state_list = possible_next_random_states.duplicate()
        state_list.shuffle()
        var new_state = state_list.pop_front()
        
        emit_signal("finished", new_state)
