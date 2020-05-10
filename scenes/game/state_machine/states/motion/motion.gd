extends State

class_name Motion

export(int) var MAX_SPEED: = 50
export(int) var ACCELERATION: = 300
export(int) var FRICTION: = 200
export(int) var KNOCKBACK_STRENGTH := 150

var motion = Vector2.ZERO
var knockback: = Vector2.ZERO

# Watch out if explicity receiving a Vector2.ZERO as direction
func accelerate_towards(point: Vector2, delta, direction: Vector2 = Vector2.ZERO):
    if direction == Vector2.ZERO:
        direction = owner.global_position.direction_to(point)

    motion = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
    owner.set_look_direction(motion)

func set_knockback_vector(_knockback: Vector2):
    knockback = _knockback * KNOCKBACK_STRENGTH
