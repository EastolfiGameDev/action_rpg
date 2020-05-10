extends Node2D

const Effects = preload("res://scenes/effects/Effects.gd")
const GrassEffect = preload("res://scenes/effects/GrassEffect.tscn")

func destroy():
    Effects.create_effect(get_parent(), global_position, GrassEffect)
    queue_free()

func _on_Hurtbox_area_entered(_area):
    destroy()
