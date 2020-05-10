extends Node

signal server_created
signal join_success
signal join_fail
signal player_list_updated
signal player_removed(player_info)

var server_info = {
    # Holds the name of the server
    name = "Server",
    # Maximum allowed connections
    max_players = 0,
    # Listening port
    port = 0
}

var players = {}

func _ready():
    get_tree().connect("network_peer_connected", self, "_on_player_connected")
    get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
    get_tree().connect("connected_to_server", self, "_on_connected_to_server")
    get_tree().connect("connection_failed", self, "_on_connection_failed")
    get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")

func _update_client_position(node: Node2D, position: Vector2):
    if get_tree().network_peer == null:
        print("ok")
    else:
#    print("local _update_client_position")
        rpc_id(Constants.HOST_PLAYER_ID, "_update_client_position", node, position)

func create_server():
    var net: = NetworkedMultiplayerENet.new()
    
    if net.create_server(server_info.port, server_info.max_players) != OK:
        print("Failed to create the server")
        return
    
    get_tree().network_peer = net
    emit_signal("server_created")
    
    register_player(GameState.player_info)

func join_server(ip: String, port: int):
    var net: = NetworkedMultiplayerENet.new()
    
    if (net.create_client(ip, port) != OK):
        print("Failed to create Client")
        emit_signal("join_fail")
        return
    
    get_tree().network_peer = net

#### RPC ####

remote func register_player(info):
    if get_tree().is_network_server():
        for id in players:
            rpc_id(info.net_id, "register_player", players[id])
            if id != Constants.HOST_PLAYER_ID:
                rpc_id(id, "register_player", info)
    
    print("Registering player %s (%s) to the internal player table" % [info.name, info.net_id])
    players[info.net_id] = info
    emit_signal("player_list_updated")

remote func unregister_player(player_id):
    var player_info = players[player_id]
    
    print("Removing player %s from internal player table" % player_info.name)
    
    players.erase(player_id)
    emit_signal("player_list_updated")
    emit_signal("player_removed", player_info)

#### SIGNALS ####

# Everyone gets notified whenever a new client joins the server
func _on_player_connected(_id):
    pass


# Everyone gets notified whenever someone disconnects from the server
func _on_player_disconnected(id):
    print("Player %s disconnected from the server" % players[id].name)
    
    if get_tree().is_network_server():
        unregister_player(id)
        rpc("unregister_player", id)


# Peer trying to connect to server is notified on success
func _on_connected_to_server():
    emit_signal("join_success")
    
    GameState.player_info.net_id = get_tree().get_network_unique_id()
    rpc_id(Constants.HOST_PLAYER_ID, "register_player", GameState.player_info)
    
    register_player(GameState.player_info)


# Peer trying to connect to server is notified on failure
func _on_connection_failed():
    emit_signal("join_fail")
    get_tree().network_peer = null


# Peer is notified when disconnected from server
func _on_disconnected_from_server():
    print("Disconnected from server")
    
    players.clear()
    GameState.player_info.net_id = Constants.HOST_PLAYER_ID
