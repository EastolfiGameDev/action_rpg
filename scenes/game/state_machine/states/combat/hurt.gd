extends State

class_name Hurt

var damage

func initialize(_damage: int):
    damage = _damage

func enter():
    if owner.has_method("hit"):
        owner.hit(damage)
    
    emit_signal("finished", Constants.STATES.CHASE)
