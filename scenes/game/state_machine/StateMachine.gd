extends Node

class_name StateMachine

signal state_changed(current_state)

export(NodePath) var START_STATE

var states_map = {}
var states_stack: Array = []
var current_state = null

var _active = false

func _ready():
    for child in get_children():
        child.connect("finished", self, "_change_state")
    initialize(START_STATE)

func initialize(start_state):
    set_active(true)
    states_stack.push_front(get_node(start_state))
    current_state = states_stack[0]
    current_state.enter()

func _change_state(state_name, _params = {}):
    if not _active:
        return

    current_state.exit()
    
    if state_name == Constants.STATES.PREVIOUS:
        states_stack.pop_front()
    else:
        states_stack[0] = states_map[state_name]
    
    current_state = states_stack[0]
    emit_signal("state_changed", current_state)
    
    if state_name != Constants.STATES.PREVIOUS:
        current_state.enter()

func _is_state(state_name) -> bool:
    return current_state == states_map[state_name]

func _get_state_label(state) -> String:
    match state:
        Constants.STATES.SLEEP:
            return "Sleep"
        Constants.STATES.IDLE:
            return "Idle"
        Constants.STATES.WANDER:
            return "Wander"
        Constants.STATES.CHASE:
            return "Chase"
        Constants.STATES.HURT:
            return "Hurt"
        Constants.STATES.DIE:
            return "Die"
        Constants.STATES.PREVIOUS:
            return "Previous"
        _:
            return "Unknown (" + str(state) + ")"

#########
func _input(event):
    if current_state.has_method("handle_input"):
        current_state.handle_input(event)

func _process(delta):
    if current_state.has_method("handle_process"):
        current_state.handle_process(delta)

func _physics_process(delta):
    if current_state.has_method("handle_physics_process"):
        current_state.handle_physics_process(delta)

### SETTERS ###
func set_active(value: bool):
    _active = value
    set_process(_active)
    set_physics_process(_active)
    
    if not _active:
        states_stack = []
        current_state = null
