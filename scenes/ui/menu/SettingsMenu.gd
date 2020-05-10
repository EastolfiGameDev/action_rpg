extends Panel

onready var JoystickToggle: CheckButton = $JoystickToggle

func _ready():
    JoystickToggle.pressed = Settings.get_setting("controls", "touch_screen")

func _on_CheckButton_toggled(button_pressed: bool):
    Settings.save_single_setting("controls", "touch_screen", button_pressed)


func _on_BottomNavigation_previous():
    GameState.change_scene("res://scenes/ui/menu/MainMenu.tscn")
