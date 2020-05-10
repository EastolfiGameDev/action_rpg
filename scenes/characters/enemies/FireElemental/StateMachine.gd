extends EnemyStateMachine

func _ready():
    # Add available states
    states_map = {
        Constants.STATES.IDLE: $Idle,
        Constants.STATES.WANDER: $Wander,
        Constants.STATES.CHASE: $Chase,
        Constants.STATES.HURT: $Hurt,
        Constants.STATES.DIE: $Die
    }
