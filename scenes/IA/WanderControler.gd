extends Node2D

export(int) var wander_range = 32
export(int) var wander_threshold = 4

signal wander_finish

onready var start_position = global_position
onready var target_position = global_position
onready var timer: Timer = $Timer

func _ready():
    timer.wait_time = 1
    update_target_position()

func _physics_process(delta):
    if global_position.distance_to(target_position) < wander_threshold:
        target_position = global_position

func update_target_position():
    var target = Vector2(rand_range(-wander_range, wander_range), rand_range(-wander_range, wander_range))
    target_position = start_position + target

func wander():
    if timer.is_stopped():
        timer.start()

func stop_wander():
    if not timer.is_stopped():
        timer.stop()

func set_timer_duration(duration: int):
    timer.wait_time = duration

func _on_Timer_timeout():
    update_target_position()
    emit_signal("wander_finish")
