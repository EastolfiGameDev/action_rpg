extends Node2D

func _ready():
    var net: = NetworkedMultiplayerENet.new()
    
    if (net.create_client("127.0.0.1", 5000) != OK):
        print("Failed to create Client")
#        emit_signal("join_fail")
        return
    
    get_tree().network_peer = net

func _process(delta):
    $icon.position.x += 1
    Network._update_client_position(self, position)

func _update_client_position(position):
    print("local _update_client_position")
