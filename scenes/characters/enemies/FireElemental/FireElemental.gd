extends Enemy

onready var state_machine: StateMachine = $StateMachine

func _on_Hurtbox_area_entered(area):
    state_machine._change_state(Constants.STATES.HURT, { area = area })


func _on_Stats_no_health():
    state_machine._change_state(Constants.STATES.DIE)
