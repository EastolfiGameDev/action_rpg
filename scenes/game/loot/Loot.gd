extends Node

enum LootStat {
    GOLD, GOLD_RAND, HEALTH, MAX_HEALTH, DAMAGE, DEFENSE, SPEED
}

const DamageItemLoot = preload("res://scenes/items/DamageWeapon.tscn")
const Coin = preload("res://scenes/items/Coin.tscn")

const LOOT_RADIUS = 30
const MIN_LOOT_RADIUS = 10

export(Array, LootStat) var loot_content_type := []
export(Array, int) var loot_content_value := []

# REVIEW - Change the loot to be an static body that get pushed toward the position
# With that, it should collide with the world and keep it at reach
# Also, move the configuration to an external file
func drop_loot(source: Node2D):
    for loot in loot_content_type:
        var instance
    
        if loot == LootStat.DAMAGE:
            instance = DamageItemLoot.instance()
        elif loot == LootStat.GOLD:
            instance = Coin.instance()
        
        if instance:
            instance.global_position = source.global_position + _get_loot_position()
            source.get_parent().add_child(instance)


func _get_loot_position() -> Vector2:
    var pos_x = rand_range(-LOOT_RADIUS, LOOT_RADIUS)
    while pos_x < MIN_LOOT_RADIUS and pos_x > -MIN_LOOT_RADIUS:
        pos_x = rand_range(-LOOT_RADIUS, LOOT_RADIUS)

    var pos_y = rand_range(-LOOT_RADIUS, LOOT_RADIUS)
    while pos_y < MIN_LOOT_RADIUS and pos_y > -MIN_LOOT_RADIUS:
        pos_y = rand_range(-LOOT_RADIUS, LOOT_RADIUS)

    return Vector2(pos_x, pos_y)
