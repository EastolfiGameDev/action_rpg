extends Control

onready var new_game: Button = $MarginContainer/Menu/HBoxContainer/CenterRow/Buttons/NewGameButton
onready var continue_game: Button = $MarginContainer/Menu/HBoxContainer/CenterRow/Buttons/ContinueButton
onready var lang_button: Button = $MarginContainer/Menu/HBoxContainer2/LangButton

var next_lang: String

func _ready():
    new_game.grab_focus()
    
    if not GameState.has_saved_game():
        continue_game.disabled = true
        continue_game.modulate.a = 0.2
    
    var lang = GameState.get_user_language()
    _update_lang_button(lang)

func _update_lang_button(current_lang: String):
    var icon: Resource

    match current_lang:
        Constants.LANGUAGES.ENGLISH:
            icon = load("res://assets/icons/flags/spain.png")
            next_lang = Constants.LANGUAGES.SPANISH
        Constants.LANGUAGES.SPANISH:
            icon = load("res://assets/icons/flags/uk.png")
            next_lang = Constants.LANGUAGES.ENGLISH

    lang_button.icon = icon    

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

func _on_MenuButton_pressed():
    GameState.change_scene("res://scenes/ui/menu/multiplayer/OnlineMenu.tscn", {
        with_transition = true
    })

func _on_SettingsButton3_pressed():
    GameState.change_scene("res://scenes/ui/menu/SettingsMenu.tscn", {
        with_transition = true
    })

func _on_LangButton_pressed():
    GameState.change_language(next_lang)
    _update_lang_button(next_lang)
