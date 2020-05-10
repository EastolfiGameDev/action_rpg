extends State

class_name Die

const Effects = preload("res://scenes/effects/Effects.gd")
const EnemyDeathEffect = preload("res://scenes/effects/EnemyDeathEffect.tscn")

func enter():
    Effects.create_effect(owner.get_parent(), owner.global_position, EnemyDeathEffect)
    owner.queue_free()
