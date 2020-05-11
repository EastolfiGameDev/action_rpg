extends Control

onready var new_game: Button = $MarginContainer/Menu/CenterRow/Buttons/NewGameButton
onready var continue_game: Button = $MarginContainer/Menu/CenterRow/Buttons/ContinueButton

func _ready():
    new_game.grab_focus()
    
    if not GameState.has_saved_game():
        continue_game.disabled = true
        continue_game.modulate.a = 0.2


func _on_NewGameButton_pressed():
    GameState.change_scene("res://scenes/ui/menu/NewGame.tscn", {
        with_transition = true
    })


func _on_ContinueButton_pressed():
    GameState.change_scene("res://scenes/levels/grass/grass_world_1_1.tscn", {
        with_transition = true
    }, {
        load_state = true
    })


func _on_SettingsButton3_pressed():
    pass # Replace with function body.
