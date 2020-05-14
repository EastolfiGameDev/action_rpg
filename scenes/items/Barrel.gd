extends StaticBody2D

const BARREL_FIRST_FRAME = 0

onready var sprite: Sprite = $Sprite
onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
    sprite.frame = BARREL_FIRST_FRAME

func destroy():
    animation.play("destroy")

func drop_loot():
    $Loot.drop_loot(self)

func _on_Hurtbox_area_entered(_area):
    destroy()
