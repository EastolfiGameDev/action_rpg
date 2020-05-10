extends ColorRect

class_name FadeEffects

signal fade_ended

func fade_in():
    visible = true
    $AnimationPlayer.play("fade_in")


func _on_AnimationPlayer_animation_finished(anim_name):
    visible = false
    emit_signal("fade_ended")
