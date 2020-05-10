extends Area2D

signal target_found(target)

var target = null

func _process(delta):
    seek_target()

func seek_target():
    if can_see_target():
        emit_signal("target_found", target)

func can_see_target() -> bool:
    return target != null

func _on_DetectionZone_body_entered(body):
    target = body
    if body.get("enemies_chasing") != null:
        body.enemies_chasing += 1

func _on_DetectionZone_body_exited(body):
    target = null
    if body.get("enemies_chasing") != null:
        body.enemies_chasing -= 1
