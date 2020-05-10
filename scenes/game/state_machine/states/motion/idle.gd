extends Motion

class_name Idle

func handle_physics_process(delta):
    motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)

    pick_random_state()
