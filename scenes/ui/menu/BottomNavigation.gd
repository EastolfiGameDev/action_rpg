extends HBoxContainer

export(String) var previous_text = "Previous"
export(String) var next_text = "Next"
export(bool) var show_previous = true
export(bool) var show_next = true

signal previous
signal next

onready var previous_button: Button = $CenterContainer/PreviousButton
onready var next_button: Button = $CenterContainer2/NextButton

func _ready():
    previous_button.visible = show_previous
    previous_button.text = previous_text
    
    next_button.text = next_text
    next_button.visible = show_next

func disable_previous_button() -> void:
    next_button.disabled = true
    next_button.modulate = Color(0.5, 0.5, 0.5, 0.5)

func disable_next_button() -> void:
    next_button.disabled = true
    next_button.modulate = Color(0.5, 0.5, 0.5, 0.5)

func enable_previous_button() -> void:
    next_button.disabled = false
    next_button.modulate = Color(1, 1, 1, 1)

func enable_next_button() -> void:
    next_button.disabled = false
    next_button.modulate = Color(1, 1, 1, 1)

func _on_PreviousButton_pressed():
    emit_signal("previous")


func _on_NextButton_pressed():
    emit_signal("next")
