extends EnemyStateMachine

func _ready():
    # Add available states
    states_map = {
        Constants.STATES.IDLE: $Idle,
        Constants.STATES.SLEEP: $Sleep
#        Constants.STATES.CHASE: $Chase,
#        Constants.STATES.HURT: $Hurt,
#        Constants.STATES.DIE: $Die
    }

#func _change_state(state_name, params = {}):
#    if not _active:
#        return
#
##    if _is_state(Constants.STATES.SLEEP) and state_name in [Constants.STATES.IDLE, Constants.STATES.CHASE]:
##        pass
#
#    ._change_state(state_name, params)
