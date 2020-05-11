extends Node

signal player_stats_updated(stats)

const FadeIn = preload("res://scenes/effects/FadeIn.tscn")

var player_info = {
    name = "Player",
    net_id = Constants.HOST_PLAYER_ID,
    actor_path = "res://scenes/characters/Player.tscn",
    char_color = Color(1, 1, 1)
}
var player_stats = {
    health = 4,
    max_health = 4
}

func change_scene(path: String, options: Dictionary = {}, params: Dictionary = {}):
    if options.has("with_transition") and options.with_transition == true:
        var fade_in = FadeIn.instance()
        fade_in.connect("fade_ended", self, "_on_FadeIn_fade_ended", [path, params])
        get_tree().current_scene.add_child(fade_in)
        fade_in.fade_in()
    else:
        call_deferred("_change_scene_deferred", path, params)

func _change_scene_deferred(path: String, _params: Dictionary):
    var next_scene = load(path)
    var scene = next_scene.instance()
    if scene:
        get_tree()._change_scene(scene)
        
        if _params.size() > 0 and scene.has_method("initialize"):
            scene.initialize(_params)

func update_player_stats(new_stats):
    for stat in new_stats:
        player_stats[stat] = new_stats[stat]
    
    emit_signal("player_stats_updated", new_stats)

func _on_FadeIn_fade_ended(path: String, scene_params: Dictionary = {}):
    change_scene(path, {}, scene_params)


### SAVE GAME ###

func _notification(event):
    if event == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        print("quit")
#        print(get_tree().current_scene.get_groups())
        save_game_state()
    elif event == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        print("back")

func save_game_state():
    var save_data := {}
    var nodes_to_save = get_tree().get_nodes_in_group("Persist")
    for node in nodes_to_save:
        if node.filename.empty():
            print("persistent node '%s' is not an instanced scene, skipped" % node.name)
            continue

        if not node.has_method("save"):
            print("persistent node '%s' is missing a save() function, skipped" % node.name)
            continue

        var node_data = node.call("save")
        save_data[node.get_path()] = node_data

#        save_game.store_line(to_json(node_data))
    
    if save_data.keys().size() > 0:
        var save_game = File.new()
        save_game.open(Constants.SAVE_FILE, File.WRITE)
        
        save_game.store_line(to_json(save_data))
        
        save_game.close()


func has_saved_game() -> bool:
    var save_game := File.new()
    return save_game.file_exists(Constants.SAVE_FILE)

func load_game_state():
    var save_game = File.new()
    if not save_game.file_exists(Constants.SAVE_FILE):
        # Error! We don't have a save to load.
        return

#    var nodes_to_restore = get_tree().get_nodes_in_group("Persist")
#    for node in nodes_to_restore:
#        node.queue_free()

    save_game.open(Constants.SAVE_FILE, File.READ)
    var save_data: Dictionary = parse_json(save_game.get_as_text())
    for node_path in save_data.keys():
        var node = get_node(node_path)
        
        var node_data = save_data[node_path]
        for attribute in node_data:
            if attribute == "pos_x":
                (node as Node2D).position.x = node_data[attribute]
            if attribute == "pos_y":
                (node as Node2D).position.y = node_data[attribute]

#    while save_game.get_position() < save_game.get_len():
#        var node_data = parse_json(save_game.get_line())
#
#        var new_node = load(node_data["filename"]).instance()
#        get_node(node_data["parent"]).call_deferred("add_child", new_node)
#        new_node.position = Vector2(node_data["pos_x"], node_data["pos_y"])
#
#        for key in node_data.keys():
#            if key == "filename" or key == "parent" or key == "pos_x" or key == "pos_y":
#                # Already handled
#                continue
#
#            new_node.set(key, node_data[key])

    save_game.close()
    
    
    
    
    
    
    
    
