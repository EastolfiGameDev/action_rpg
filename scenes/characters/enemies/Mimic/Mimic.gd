extends Enemy

const BARREL_FIRST_FRAME = 56

#onready var sprite: Sprite = $Sprite
onready var animation: AnimationTree = $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation.get("parameters/playback")
onready var state_machine: StateMachine = $StateMachine

#var sleep_queued := false
#
#func _ready():
#    if sleep_queued:
#        sleep()
##        sleep_queued = false
#
#func reset_animation():
#    sprite.frame = BARREL_FIRST_FRAME
#    animation_state.stop()
#
#func queue_sleep():
#    sleep_queued = true
#
#func sleep():
#    reset_animation()
#
## Wake up when player is close and not looking or when hit
#func wake_up():
#    animation_state.travel("wake_up")

# Called from the animation player
#func wake_up_ended():
#    state_machine._change_state(Constants.STATES.IDLE)
    

func _on_DetectionZone_target_found(target):
    state_machine._change_state(Constants.STATES.IDLE)

func _on_DetectionZone_target_lost():
    state_machine._change_state(Constants.STATES.SLEEP)
