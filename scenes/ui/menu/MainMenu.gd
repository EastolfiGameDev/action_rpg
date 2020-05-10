extends Panel

func _ready():
    Network.server_info.name = "127.0.0.1"
    Network.server_info.port = 4242
    Network.server_info.max_players = 1
    Network.connect("server_created", self, "_on_game_ready")

func _on_game_ready():
    GameState.change_scene("res://scenes/levels/grass/grass_world_1_1.tscn")

func _on_OfflineButton_pressed():
    Network.create_server()
#    Network.register_player(GameState.player_info)

func _on_OnlineButton_pressed():
    GameState.change_scene("res://scenes/ui/menu/OnlineMenu.tscn")

func _on_SettingsButton_pressed():
    GameState.change_scene("res://scenes/ui/menu/SettingsMenu.tscn")
