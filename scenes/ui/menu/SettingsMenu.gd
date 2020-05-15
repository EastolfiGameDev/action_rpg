extends Panel

const CODE_PROMO_TEST = "YETI_MISSING_SAVEFILE"

onready var code_promo: LineEdit = $MarginContainer/VBoxContainer/CodePromoContainer/HBoxContainer/CodePromo

func _on_BottomNavigation_previous():
    GameState.change_scene("res://scenes/ui/menu/TitleScreen.tscn")


func _on_CodePromoSubmit_pressed():
    if code_promo.text == CODE_PROMO_TEST:
        var save_data = GameState.read_game_state()
        
        for key in save_data.keys():
            if key.ends_with("Player/Stats"):
                var stats: Dictionary = save_data[key]
                if stats.has("gold"):
                    stats.gold += 10
                save_data[key] = stats

        GameState.persist_save_data(save_data)
        code_promo.clear()
