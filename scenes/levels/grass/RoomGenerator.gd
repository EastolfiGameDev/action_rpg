extends RigidBody2D

#export(bool) var with_background = true

var size: Vector2

func _ready():
    $Sprite.centered = false
    $Sprite.region_enabled = true
    

func init(with_background: bool):
    $Sprite.visible = with_background

func make_room(_position: Vector2, _size: Vector2):
    position = _position
    size = _size
    
    var shape = RectangleShape2D.new()
    shape.extents = size
    $CollisionShape2D.shape = shape
    $Sprite.position = Vector2.ZERO - _size
    $Sprite.region_rect = Rect2(Vector2.ZERO, _size * 2)
