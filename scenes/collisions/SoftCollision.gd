extends Area2D

export(float) var push_force = 1.0

func is_colliding() -> bool:
    var areas = get_overlapping_areas()
    
    return areas.size() > 0

func get_push_vector() -> Vector2:
    var push_vector = Vector2.ZERO
    
    if is_colliding():
        var area: Area2D = get_overlapping_areas()[0]
        push_vector = area.global_position.direction_to(global_position) * push_force
    
    return push_vector
