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
    
    var connections = {
        Constants.STATES.IDLE: [
            Constants.STATES.IDLE,
            Constants.STATES.WANDER
        ],
        Constants.STATES.WANDER: [
            Constants.STATES.IDLE,
            Constants.STATES.WANDER
        ]
    }
