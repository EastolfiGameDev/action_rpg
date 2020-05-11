extends Panel

onready var PlayerName: LineEdit = $MarginContainer/MainContainer/PlayerInfoPanel/HBoxContainer/PlayerName
onready var HostServerName: LineEdit = $MarginContainer/MainContainer/OnlineContainer/HostPanel/VBoxContainer/ServerNameContainer/ServerName
onready var HostServerPort: LineEdit = $MarginContainer/MainContainer/OnlineContainer/HostPanel/VBoxContainer/ServerPortContainer/ServerPort
onready var HostMaxPlayers: SpinBox = $MarginContainer/MainContainer/OnlineContainer/HostPanel/VBoxContainer/MaxPlayersContainer/MaxPlayers
onready var JoinIP: LineEdit = $MarginContainer/MainContainer/OnlineContainer/JoinPanel/VBoxContainer/JoinIPContainer/JoinIP
onready var JoinPort: LineEdit = $MarginContainer/MainContainer/OnlineContainer/JoinPanel/VBoxContainer/JoinPortContainer/JoinPort

func _ready():
    Network.connect("server_created", self, "_on_ready_to_play")
    Network.connect("join_success", self, "_on_ready_to_play")
    Network.connect("join_fail", self, "_on_join_fail")

func set_player_info():
    if not PlayerName.text.empty():
        GameState.player_info.name = PlayerName.text

func _on_ready_to_play():
    GameState.change_scene("res://scenes/levels/grass/grass_world_1_1.tscn")

func _on_join_fail():
    print("Failed to join server")

func _on_CreateButton_pressed():
    set_player_info()
    
    if not HostServerName.text.empty():
        Network.server_info.name = HostServerName.text
    
    Network.server_info.port = int(HostServerPort.text)
    Network.server_info.max_players = int(HostMaxPlayers.value)

    Network.create_server()


func _on_JoinButton_pressed():
    set_player_info()
    
    if not JoinIP.text.empty():
        Network.join_server(JoinIP.text, int(JoinPort.text))


func _on_BottomNavigation_previous():
    GameState.change_scene("res://scenes/ui/menu/TitleScreen.tscn")
