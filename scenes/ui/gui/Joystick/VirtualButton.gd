extends TextureRect

enum State { NONE, PRESS, DRAG_OUTSIDE }

signal button_down
signal button_up
signal pressed

export(Color) var _pressed_color := Color.gray
export(bool) var enabled := true

onready var effects := $Tween

var _original_color: Color = modulate
var _isPressed = false
# Current input finger. For each finger touching the screen, the index increments by 1
var _current_index = -1
# Current state of the button
var _current_state = State.NONE

func _ready():

    if OS.has_touchscreen_ui_hint() and enabled:
        modulate.a = 0.3
        _original_color.a = 0.3
        set_process(true)
        set_process_input(true)
    elif OS.has_touchscreen_ui_hint() and not enabled:
        modulate.a = 0.1
        set_process_input(false)
    else:
        visible = false
        set_process(false)
        set_process_input(false)

func _input(event):
    if event is InputEventScreenTouch and _is_valid_index(event.index):
        # If we pressed and we are doing nothing, initiate the PRESS state
        if event.pressed and _is_state(State.NONE) and _is_within_rect(event.position):
            _button_click_down(event.index)
        elif _is_state(State.PRESS):
            _button_release()
    
    if event is InputEventScreenDrag and _is_valid_index(event.index) and \
    _is_state(State.PRESS) and not _is_within_rect(event.position):
        _change_state(State.DRAG_OUTSIDE)
        _button_release()

func _button_click_down(index: int) -> void:
    _set_input_index(index)
    _change_state(State.PRESS)
    fade_in()
    emit_signal("button_down")

func _button_release() -> void:
    # If we are releasing the joystick after a click down, we fire a RELEASE state (emulates a click)
    if _is_state(State.PRESS):
        emit_signal("pressed")
    # If the release is after a DRAG/DRAG_START state, trigger a DRAG_END state
    elif _is_state(State.DRAG_OUTSIDE):
        emit_signal("button_up")
    
    fade_out()
    _reset_input_index()
    _change_state(State.NONE)

func fade_in():
    var origin = modulate
    origin.a = 0.3
    var target = _pressed_color
    
    effects.interpolate_property(self, "modulate", origin, target, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    effects.start()

func fade_out():
    var origin = _pressed_color
    var target = _original_color
    target.a = 0.3
    
    effects.interpolate_property(self, "modulate", origin, target, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    effects.start()

func _is_within_rect(position: Vector2) -> bool:
    var offset = (Vector2.ONE - rect_scale) * (rect_pivot_offset)
    var size = rect_size * rect_scale
    
    var top_right = rect_global_position# + offset
    var bottom_right = rect_global_position + size

    # Improve to handle the circle instead a square
    var is_within_x: bool = (top_right.x <= position.x and position.x <= bottom_right.x)
    var is_within_y: bool = (top_right.y <= position.y and position.y <= bottom_right.y)
    
    return is_within_x and is_within_y

func _change_state(new_state):
    _current_state = new_state

func _is_state(state):
    return _current_state == state

func _set_input_index(index: int):
    _current_index = index

func _reset_input_index():
    _current_index = -1

func _is_valid_index(index: int) -> bool:
    return _current_index == -1 or _current_index == index
