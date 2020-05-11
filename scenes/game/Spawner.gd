extends Node

export(bool) var disabled = true
export(NodePath) var SpawnPointsPath: NodePath

#onready var AttackButton = get_tree().current_scene.get_node("AttackButton")
#onready var RollButton = get_tree().current_scene.get_node("RollButton")

var SpawnPoints: Node2D

func _ready():
    SpawnPoints = get_node(SpawnPointsPath)
    if not disabled:
        # Offline mode
    #    if get_tree().network_peer == null:
    #        var player_actor: Node = load(GameState.player_info.actor_path).instance()
    #        player_actor.position = SpawnPoints.get_node("Spawn_%s" % 1).position
    #        SpawnPoints.add_child(player_actor)
    #    else:
        if get_tree().is_network_server():
            Network.connect("player_removed", self, "_on_player_removed")
            
            spawn_players(GameState.player_info, Constants.HOST_PLAYER_ID)
    #        spawn_character()
        else:
            rpc_id(Constants.HOST_PLAYER_ID, "spawn_players", GameState.player_info, -1)
    #        rpc_id(Constants.HOST_PLAYER_ID, "spawn_character")

remote func spawn_players(player_info, spawn_index):
    if spawn_index == -1:
        spawn_index = Network.players.size()
    
    if get_tree().is_network_server() && player_info.net_id != Constants.HOST_PLAYER_ID:
        var index = 1
        for id in Network.players:
            # Spawn the current iterated player within the new player's scene, skiping the new one
            if id != player_info.net_id:
                rpc_id(player_info.net_id, "spawn_players", Network.players[id], index)
            
            # Spawn the new player within the current iterated player's scene
            if id != Constants.HOST_PLAYER_ID:
                rpc_id(id, "spawn_players", player_info, spawn_index)
            
            index += 1
    
    var player_actor: Node = load(player_info.actor_path).instance()
    player_actor.position = SpawnPoints.get_node("Spawn_%s" % spawn_index).position
#    AttackButton.connect("pressed", player_actor, "_on_AttackButton_pressed")
#    RollButton.connect("pressed", player_actor, "_on_RollButton_pressed")
    
    if player_info.net_id != Constants.HOST_PLAYER_ID:
        player_actor.set_network_master(player_info.net_id)
        player_actor.name = str(player_info.net_id)
    
    SpawnPoints.add_child(player_actor)

remote func despawn_player(player_info):
    if get_tree().is_network_server():
        for id in Network.players:
            if id != player_info.net_id and id != Constants.HOST_PLAYER_ID:
                rpc_id(id, "despawn_player", player_info)
    
    var player_node = get_node(str(player_info.net_id))
    if not player_node:
        print("Cannot remove invalid node from tree")
    
    player_node.queue_free()

remote func spawn_character():
    var bat = load("res://scenes/characters/enemies/Bat.tscn").instance()
    bat.position = Vector2(70, 100)
    SpawnPoints.add_child(bat)

#### SIGNALS ####

func _on_player_removed(player_info):
    despawn_player(player_info)
