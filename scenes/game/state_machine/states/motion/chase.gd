extends Move

class_name Chase

export(NodePath) var detection_zone_path: NodePath
export(NodePath) var look_raycast_path: NodePath

var target
var detection_zone
var look: RayCast2D

func _ready():
    if detection_zone_path:
        detection_zone = get_node(detection_zone_path)
    
    if look_raycast_path:
        look = get_node(look_raycast_path)

func initialize(_target):
    target = _target

func handle_physics_process(delta):
    if detection_zone:
        target = detection_zone.target
    if target != null:
        var scent_trail = []
        if target.get("scent_trail"):
            scent_trail = target.scent_trail
    
        var target_point = target.global_position    
        var direction := Vector2.ZERO
        if look:
            look.cast_to = target_point - owner.position
            look.force_raycast_update()
    
            if not look.is_colliding():
                direction = look.cast_to.normalized()
            else:
                for scent in scent_trail:
                    look.cast_to = (scent.position - owner.position)
                    look.force_raycast_update()
    
                    if not look.is_colliding():
                        direction = look.cast_to.normalized()

        accelerate_towards(target_point, delta, direction)
    else:
        emit_signal("finished", Constants.STATES.IDLE)
    
    .handle_physics_process(delta)
