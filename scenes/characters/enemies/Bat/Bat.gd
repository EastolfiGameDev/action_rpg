extends Enemy

onready var state_machine: StateMachine = $StateMachine
onready var effects: AnimationPlayer = $Effects

func _on_DetectionZone_target_found(_target):
    state_machine._change_state(Constants.STATES.CHASE)

func _on_Hurtbox_invincibility_started():
    effects.play("blink_start")

func _on_Hurtbox_invincibility_ended():
    effects.play("blink_stop")

func _on_Hurtbox_area_entered(area):
    state_machine._change_state(Constants.STATES.HURT, { area = area })

func _on_Stats_no_health():
    state_machine._change_state(Constants.STATES.DIE)
