extends StateMachine

class_name EnemyStateMachine

func _change_state(state_name, params = {}):
    if not _active:
        return
    
    if state_name in [Constants.STATES.IDLE, Constants.STATES.WANDER, Constants.STATES.CHASE]:
        states_stack.push_front(states_map[state_name])
    
#    if state_name == "" and _is_state(""):
#        # Perform some actions before entering state
#        pass
    
    if state_name == Constants.STATES.HURT:
        if _has_parameter(params, "area"):
            var area = params.area
            states_map[Constants.STATES.HURT].initialize(area.damage)
            if area.get("knockback_vector") and current_state.has_method("set_knockback_vector"):
                current_state.set_knockback_vector(area.knockback_vector)
        
    ._change_state(state_name)


func _has_parameter(params: Dictionary, param_name: String) -> bool:
    return params and params.has(param_name)
