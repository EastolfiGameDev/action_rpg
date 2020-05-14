extends Node

class_name Stats

signal no_health

export(bool) var is_player := false
export(int) var max_health := 1 setget set_max_health
export(int) var damage := 1# setget set_damage

var health: int setget set_health
var gold := 0 setget set_gold_amount

func _ready():
    health = max_health

    _notify_player_stats({
        health = health,
        max_health = max_health
    })

func set_health(value: int):
    health = value
    var stats_changes = {
        health = health
    }
    
    # Review max health increase
    if health > max_health:
        max_health = health
        stats_changes.max_health = max_health

    _notify_player_stats(stats_changes)
    
    if health <= 0:
        emit_signal("no_health")

func set_max_health(value: int, replenish = false):
    max_health = value
    
    if replenish:
        health = max_health
    else:
        health = min(health, max_health)

    _notify_player_stats({
        health = health,
        max_health = max_health
    })

func set_gold_amount(value: int):
    gold = value

    _notify_player_stats({
        gold = gold
    })


func _notify_player_stats(stats: Dictionary):
    if is_player:
        GameState.update_player_stats(stats)



func save() -> Dictionary:
    return {
        "filename": get_filename(),
#        "parent": get_parent().get_path(),
        "gold": gold,
        "health": health,
        "max_health": max_health,
        "damage": damage
    }
