extends State

var animation: AnimationTree
var animation_state: AnimationNodeStateMachinePlayback

func enter():
    if owner.has_node("AnimationTree"):
        animation = owner.get_node("AnimationTree")
        animation_state = animation.get("parameters/playback")
        animation_state.travel("sleeping")

func exit():
    if animation_state:
        animation_state.travel("wake_up")
