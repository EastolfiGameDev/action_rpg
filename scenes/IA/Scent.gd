extends Node2D

var source: Node2D

func _ready():
    $ColorRect.visible = false

func remove_scent():
    if source and source.get("scent_trail"):
        source.scent_trail.erase(self)
    
    queue_free()

func _on_Timer_timeout():
    remove_scent()
