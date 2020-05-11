extends Control

func _on_CreateButton_pressed():
    GameState.change_scene("res://scenes/levels/grass/grass_world_1_1.tscn", {
        with_transition = true
    })


func _on_BottomNavigation_previous():
    GameState.change_scene("res://scenes/ui/menu/TitleScreen.tscn")
