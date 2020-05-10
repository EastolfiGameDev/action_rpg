extends Motion

class_name Move

func handle_physics_process(delta):
    knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
    knockback = owner.move_and_slide(knockback)
    
    motion = owner.move_and_slide(motion)
