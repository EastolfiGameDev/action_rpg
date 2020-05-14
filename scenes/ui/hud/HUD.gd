extends CanvasLayer

export(bool) var offline = true

const HEART_SIZE = Vector2(15, 11)
const MAX_HEARTS_PER_ROW = 6

onready var LocalPlayerName: Label = $PlayerList/VBoxContainer/LocalPlayerName
onready var RemotePlayerList: VBoxContainer = $PlayerList/VBoxContainer/RemotePlayerList
onready var HeartEmpty: TextureRect = $HealthDisplay/HeartEmpty
onready var HeartFull: TextureRect = $HealthDisplay/HeartFull
onready var Hint: Label = $Hint
onready var GoldAmountLabel: Label = $Control/CoinAmount

func _ready():
    GameState.connect("player_stats_updated", self, "on_player_stats_updated")
    
    if offline:
        $PlayerList.visible = false
    else:
        Network.connect("player_list_updated", self, "_on_player_list_changed")
        
        update_player_name(GameState.player_info.name)
        update_player_list()
    
    Hint.visible = false
    GoldAmountLabel.text = "0"

func update_health(value: int):
    HeartFull.rect_size.x = clamp(value, 0, GameState.player_stats.max_health) * HEART_SIZE.x

func update_max_health(value: int):
    if value > MAX_HEARTS_PER_ROW:
        # TODO - Handle several rows
        HeartEmpty.rect_size.x = max(value, 1) * HEART_SIZE.x
    else:
        HeartEmpty.rect_size.x = max(value, 1) * HEART_SIZE.x


func update_gold_amount(amount: int):
    GoldAmountLabel.text = str(amount)

func update_player_name(name: String):
    LocalPlayerName.text = name

func update_player_list():
    for child in RemotePlayerList.get_children():
        child.queue_free()
    
    for player_id in Network.players:
        if player_id != GameState.player_info.net_id:
            var label = Label.new()
            label.text = Network.players[player_id].name
            RemotePlayerList.add_child(label)

func _on_player_list_changed():
    print("yay")
    update_player_list()

func on_player_stats_updated(stats: Dictionary):
    if stats.has("health"):
        update_health(stats.health)
    if stats.has("max_health"):
        update_max_health(stats.max_health)
    if stats.has("gold"):
        update_gold_amount(stats.gold)


func show_hint_message(message: String, position: Vector2):
    Hint.text = message
    if message.length() > 30:
        Hint.autowrap = true
        Hint.rect_size.x = 100
    else:
        Hint.rect_size = Vector2.ZERO
    Hint.visible = true
    
    Hint.get_parent().remove_child(Hint)
    get_tree().get_root().add_child(Hint)
#    Hint.rect_global_position = target.global_position - Vector2(20, 40)
    Hint.rect_global_position = position - Vector2(Hint.rect_size.x / 2, Hint.rect_size.y)

func hide_hint_message():
    Hint.visible = false
    
    Hint.get_parent().remove_child(Hint)
    add_child(Hint)
