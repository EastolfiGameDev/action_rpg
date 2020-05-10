extends Control

### Enums ###

# FIXED: The joystick doesn't move.
# DYNAMIC: Every time the joystick area is pressed, the joystick position is set on the touched position.
# FOLLOWING: If the finger moves outside the joystick background, the joystick follows it.
enum Joystick_mode {FIXED, DYNAMIC, FOLLOWING}
# REAL: return a vector with a lenght beetween 0 (deadzone) and 1; useful for implementing different velocity or acceleration.
# NORMALIZED: return a normalized vector.
enum Vector_mode {REAL, NORMALIZED}
# NONE: The joystick isn't moving
# PRESS: The joystick is pressed
# DRAG_START: The joystick just started moving
# DRAG: The joystick is moving
enum State { NONE, PRESS, DRAG_START, DRAG }

### Signals ###

signal joystick_down
signal joystick_up
signal joystick_pressed
signal joystick_click_down
signal joystick_click_release
signal joystick_drag_end

### Exported variables ###

# Joystick movement mode
export(Joystick_mode) var joystick_mode := Joystick_mode.FIXED
# Type of the output vector
export(Vector_mode) var vector_mode := Vector_mode.REAL
# Color for the pressed status
export(Color) var _pressed_color := Color.gray
# The max distance the handle can reach, in proportion to the background size.
export(float, 0.5, 2) var clamp_zone := 1;
# If the handle is inside this range, in proportion to the background size, the output is zero.
export(float, 0, 0.5) var dead_zone := 0.2;
# The number of directions, e.g. a D-pad is joystick with 4 directions, keep 0 for a free joystick.
export(int, 0, 12) var directions := 0
# It changes the angle of simmetry of the directions.
export(int, -180, 180) var simmetry_angle := 90

### Onready variables ###

# The joystick (with the handle) background
onready var _background = $Background
# The initial position of the joystick
onready var _original_position : Vector2 = _background.rect_position
onready var _handle: TextureRect = $Background/Handle
onready var _original_color: Color = _handle.modulate
onready var effects := $Tween

### Local variables ###

# If the joystick is receiving inputs.
var is_working = false
# The joystick output.
var output := Vector2.ZERO

# Current input finger. For each finger touching the screen, the index increments by 1
var _current_index = -1
# Current state of the joystick
var _current_state = State.NONE

### DEBUG ###

#export(bool) var is_left := true

#func _draw():
#    print("LEFT" if is_left else "RIGHT")
#    print("Position: ", _background.rect_position)
#    print("Global Position: ", _background.rect_global_position)
#    print("Size: ", _background.rect_size)
#    print("Scale: ", _background.rect_scale)
#    var offset = (Vector2.ONE - _background.rect_scale) * (_background.rect_pivot_offset)
#    var origin = _background.rect_position + offset
#    var size = _background.rect_size * _background.rect_scale
#    draw_rect(Rect2(origin, size), Color.lightblue)

### END DEBUG ###

func _ready():
    if OS.has_touchscreen_ui_hint():
        modulate.a = 0.3
        set_process(true)
        set_process_input(true)
    else:
        visible = false
        set_process(false)
        set_process_input(false)

func _input(event):
    _container_input(event)
    _background_input(event)
    
func _container_input(event):
    if (joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING) and \
    event is InputEventScreenTouch and _is_valid_index(event.index):
        if event.pressed and _is_within_rect(event.position) and _is_state(State.NONE):
            _update_joystick_background(event.position)
            _set_input_index(event.index)
        elif not _is_state(State.NONE):
            _reset_joystick_background()
            _reset_input_index()

func _update_output(vector: Vector2) -> void:
    var dead_size = dead_zone * _background.rect_size.x / 2
    var clamp_size = clamp_zone * _background.rect_size.x / 2
    vector = vector.clamped(clamp_size)
    if directions > 0:
        vector = _directional_vector(vector, directions, deg2rad(simmetry_angle))
    output = vector.normalized()
    if vector_mode == Vector_mode.REAL and vector.length() < clamp_size:
        output *= (vector.length() - dead_size) / (clamp_size - dead_size)

    set_handle_center_position(output * clamp_size + _background.rect_size / 2)

func _following(vector: Vector2) -> void:
    var clamp_size = clamp_zone * _background.rect_size.x / 2
    if vector.length() > clamp_size:
        var radius = vector.normalized() * clamp_size
        var delta = vector - radius
        var new_pos = _background.rect_position + delta
        new_pos.x = clamp(new_pos.x, -_background.rect_size.x / 2, rect_size.x - _background.rect_size.x / 2)
        new_pos.y = clamp(new_pos.y, -_background.rect_size.y / 2, rect_size.y - _background.rect_size.y / 2)
        _background.rect_position = new_pos

func _directional_vector(vector: Vector2, n_directions: int, simmetry_angle := PI/2) -> Vector2:
    var angle := (vector.angle() + simmetry_angle) / (PI / n_directions)
    angle = floor(angle) if angle >= 0 else ceil(angle)
    if abs(angle) as int % 2 == 1:
        angle = angle + 1 if angle >= 0 else angle - 1
    angle *= PI / n_directions
    angle -= simmetry_angle
    return Vector2(cos(angle), sin(angle)) * vector.length()

func _update_joystick_background(position: Vector2):
    var new_pos = (position - _background.rect_size / 2) - rect_position
    _background.rect_position = new_pos

func _reset_joystick_background():
    _background.rect_position = _original_position

func _is_within_rect(position: Vector2) -> bool:
    var top_right = rect_position #rect_global_position
    var bottom_right = rect_position + rect_size #rect_global_position

    return _is_within_boundary(position, top_right, bottom_right)


############# BACKGROUND ###############
func _joystick_click_down(index: int) -> void:
    is_working = false
    _set_input_index(index)
    _change_state(State.PRESS)
    change_handle_color(_pressed_color)
    emit_signal("joystick_down")

func _joystick_release() -> void:
    # Reset the joystick
    is_working = false
    output = Vector2.ZERO
    reset_handle_center_position()
    change_handle_color()
    
    # If we are releasing the joystick after a click down, we fire a RELEASE state (emulates a click)
    if _is_state(State.PRESS):
        emit_signal("joystick_pressed")
    # If the release is after a DRAG/DRAG_START state, trigger a DRAG_END state
    elif _is_state(State.DRAG) or _is_state(State.DRAG_START):
        fade_out()
        emit_signal("joystick_up")

func _background_input(event):
    if event is InputEventScreenTouch and _is_valid_index(event.index):
        # If we pressed and we are doing nothing, initiate the PRESS state
        if event.pressed and _is_state(State.NONE) and _is_within_background(event.position):
            _joystick_click_down(event.index)
        else:
            _joystick_release()

            # Reset the joystick state
            _reset_input_index()
            _change_state(State.NONE)
    
    if event is InputEventScreenDrag and _is_valid_index(event.index):
        var event_position = (event.position - _background.rect_global_position) / _background.rect_scale
        var vector: Vector2 = event_position - _background.rect_size / 2
        var dead_size = dead_zone * _background.rect_size.x / 2

        if vector.length() >= dead_size:
            if _is_state(State.PRESS):
                is_working = true
                fade_in()
                _change_state(State.DRAG_START)
                _update_output(vector)
            elif _is_state(State.DRAG_START) or _is_state(State.DRAG):
                is_working = true
                _change_state(State.DRAG)
                _update_output(vector)
                if joystick_mode == Joystick_mode.FOLLOWING:
                    _following(vector)

func _is_within_background(position: Vector2) -> bool:
    var offset = (Vector2.ONE - _background.rect_scale) * (_background.rect_pivot_offset)
    var size = _background.rect_size * _background.rect_scale
    
    var top_right = _background.rect_global_position# + offset
    var bottom_right = _background.rect_global_position + size

    return _is_within_boundary(position, top_right, bottom_right)

func _is_within_boundary(position: Vector2, top_right: Vector2, bottom_left: Vector2) -> bool:
    # Improve to handle the circle instead a square
    var is_within_x: bool = (top_right.x <= position.x and position.x <= bottom_left.x)
    var is_within_y: bool = (top_right.y <= position.y and position.y <= bottom_left.y)
    
    return is_within_x and is_within_y

func fade_in():
    var color = modulate
    var origin = Color(color.r, color.b, color.g, 0.3)
    var target = Color(color.r, color.b, color.g, 1.0)
    
    effects.interpolate_property(self, "modulate", origin, target, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    effects.start()

func fade_out():
    var color = modulate
    var origin = Color(color.r, color.b, color.g, 1.0)
    var target = Color(color.r, color.b, color.g, 0.3)
    
    effects.interpolate_property(self, "modulate", origin, target, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    effects.start()

func change_handle_color(color: Color = _original_color):
    _handle.modulate = color

func set_handle_center_position(new_position: Vector2) -> void:
    _handle.rect_position = new_position - _handle.rect_size / 2

func reset_handle_center_position():
    set_handle_center_position(_background.rect_size / 2)

func _set_input_index(index: int):
    _current_index = index

func _reset_input_index():
    _current_index = -1

func _is_valid_index(index: int) -> bool:
    return _current_index == -1 or _current_index == index

func _change_state(new_state):
    _current_state = new_state

func _is_state(state):
    return _current_state == state
