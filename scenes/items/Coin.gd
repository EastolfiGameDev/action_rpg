extends Area2D

var item_info: Item = Item.new()

func _ready():
    item_info.is_lootable = true
    item_info.damage = 0
    item_info.gold = 1

func _on_Coin_body_entered(body):
    if body.has_method("pick_up"):
        body.pick_up(item_info)
        queue_free()
