extends CanvasLayer

signal attack_button_down
signal attack_button_pressed
signal movement_skill_button_down
signal movement_skill_button_pressed
signal skill_button_down
signal skill_button_pressed
signal interact_button_pressed

func _ready():
    $InteractButton.enabled = false

func get_joystick_input() -> Vector2:
    return $VirtualJoystick.output

### SIGNALS ###

func _on_AttackButton_button_down():
    emit_signal("attack_button_down")

func _on_AttackButton_button_up():
    pass

func _on_AttackButton_pressed():
    emit_signal("attack_button_pressed")

func _on_MovementSkillButton_button_down():
    emit_signal("movement_skill_button_down")

func _on_MovementSkillButton_button_up():
    pass

func _on_MovementSkillButton_pressed():
    emit_signal("movement_skill_button_pressed")

func _on_SkillButton_button_down():
    emit_signal("skill_button_down")

func _on_SkillButton_button_up():
    pass

func _on_SkillButton_pressed():
    emit_signal("skill_button_pressed")


func _on_InteractButton_pressed():
    emit_signal("interact_button_pressed")
