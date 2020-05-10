extends AnimatedSprite

func _ready():
    connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
    
    frame = 0
    play("animate")

static func create_effect(root: Node2D, target_position: Vector2, scene: PackedScene) -> void:
    var effect: Node2D = scene.instance()
    root.add_child(effect)
    effect.global_position = target_position
    

func _on_AnimatedSprite_animation_finished():
    queue_free()
