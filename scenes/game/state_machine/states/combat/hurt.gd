extends State

class_name Hurt

var damage
var damage_knockback = Vector2.ZERO

func initialize(_damage: int, _knockback: Vector2):
    damage = _damage
    damage_knockback = _knockback

func enter():
    if owner.has_method("hit"):
        owner.hit(damage)
    
    emit_signal("finished", Constants.STATES.CHASE, { knockback = damage_knockback })
