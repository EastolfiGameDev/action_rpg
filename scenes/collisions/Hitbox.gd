extends Area2D

export(int) var damage: = 1 setget set_damage, get_damage
export(bool) var is_player := false

func set_damage(value: int):
    damage = value

func get_damage() -> int:
    if is_player:
        return owner.get_stats().damage as int
    else:
        return damage
