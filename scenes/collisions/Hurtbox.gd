extends Area2D

const Effects = preload("res://scenes/effects/Effects.gd")
const HitEffect = preload("res://scenes/effects/HitEffect.tscn")

signal invincibility_started
signal invincibility_ended

onready var timer: Timer = $Timer

var invincible: = false setget set_invicible

func set_invicible(value: bool):
    invincible = value
    
    if invincible:
        emit_signal("invincibility_started")
    else:
        emit_signal("invincibility_ended")

func start_invincibility(duration: float):
    set_invicible(true)
    timer.start(duration)

func create_hit_effect():
    # Review position offset --> X - Vector2(0, 8)
    Effects.create_effect(get_tree().current_scene, global_position, HitEffect)


func _on_Timer_timeout():
    set_invicible(false)

func _on_Hurtbox_invincibility_started():
    set_deferred("monitorable", false)

func _on_Hurtbox_invincibility_ended():
    set_deferred("monitorable", true)
