extends KinematicBody2D

class_name Enemy

onready var sprite: Sprite = $Sprite
onready var stats: Stats = $Stats
onready var hurtbox: Area2D = $Hurtbox

func set_look_direction(value: Vector2):
    if sprite:
        if value.x < 0:
            sprite.flip_h = true
        elif value.x > 0:
            sprite.flip_h = false

func hit(damage: int):
    if stats:
        stats.health -= damage
    
    if hurtbox:
        hurtbox.create_hit_effect()
        hurtbox.start_invincibility(0.3)
