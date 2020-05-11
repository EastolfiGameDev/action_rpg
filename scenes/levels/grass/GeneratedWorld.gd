extends Node2D

const RoomGenerator = preload("res://scenes/levels/grass/RoomGenerator.tscn")
const font = preload("res://assets/fonts/montserrat_24.tres")
const Player = preload("res://scenes/characters/player/Player.tscn")
const Bat = preload("res://scenes/characters/enemies/Bat/Bat.tscn")

const TILE_SIZE = 16
const UNSET_TILE = -1
const DIRT_TILESET = 0
const WATER_TILESET = 1
const CLIFF_DIRT_TILESET = 2
const GRASS_TILESET = 3
const CLIFF_TILESET = 0
const CLIFF_AUTOTILE_COORD = Vector2(0, 0)
const DIRT_AUTOTILE_COORD = Vector2(3, 1)
const WATER_AUTOTILE_COORD = Vector2(3, 1)

onready var Rooms = $Rooms
onready var DirtWaterAutotile = $DirtWaterAutotile
onready var CliffAutotile = $CliffAutotile
onready var PlayerCamera = $Camera2D

var room_number = 5
var min_room_size = 5
var max_room_size = 10
var horizontal_spread = 40
var vertical_spread = 40
var cull = 0.0
var with_background = false
var play_mode = false

var world_data = {
    rooms = []
}

var path: AStar = null
var path_set = false

var start_room = null
var end_room = null

func _ready():
    $CanvasLayer/RoomNumber.value = room_number
    $CanvasLayer/HSpread.value = horizontal_spread
    $CanvasLayer/VSpread.value = vertical_spread
    $CanvasLayer/RoomBackground.pressed = with_background
    $CanvasLayer/CullRatio.value = cull

#    print(Map.get_cell_autotile_coord(0, 0))

    randomize()
    make_rooms()

func _process(delta):
    update()

func _draw():
    if play_mode:
        return
        
    for room in Rooms.get_children():
        if not with_background:
            draw_rect(Rect2(room.position - room.size, room.size * 2), Color(1, 0, 0), false)
        
        var rect = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
        
        var room_top_left = room.position - room.size
        var room_top_right = room_top_left + Vector2(room.size.x * 2, 0)
        var room_bottom_right = room.position + room.size
        var room_bottom_left = room_bottom_right - Vector2(room.size.x * 2, 0)
        draw_string(font, room.position, "X", Color(1,1,1))
        
#        var tiles_size = room.size / 16
#        for top in range(room_top_left.x, room_top_right.x, 16):
#            draw_string(font, Vector2(top, room_top_left.y), "@", Color(1,1,1))
#
#        for left in range(room_top_left.y, room_bottom_left.y, 16):
#            draw_string(font, Vector2(room_top_left.x, left), "@", Color(1,1,1))
#
#        for right in range(room_top_right.y, room_bottom_right.y, 16):
#            draw_string(font, Vector2(room_top_right.x, right), "@", Color(1,1,1))
#
#        for bottom in range(room_bottom_left.x, room_bottom_right.x, 16):
#            draw_string(font, Vector2(bottom, room_bottom_left.y), "@", Color(1,1,1))
        
#        for x in range(room_top_left.x, room_top_right.x, 32):
#            for y in range(room_top_left.y, room_bottom_right.y, 32):
#                draw_string(font, Vector2(x, y), "@", Color(1,1,1))
                

#        if path_set:
#            var path_id = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
#            var point_position: Vector3 = path.get_point_position(path_id)
#
#            for edge in path.get_point_connections(path_id):
#                var edge_position: Vector3 = path.get_point_position(edge)
#
#                draw_line(Vector2(point_position.x, point_position.y),
#                Vector2(edge_position.x, edge_position.y), Color(0, 1, 0), 2, true)


func set_tileset_cell(tilemap_node: TileMap, pos: Vector2, tile_index: int, autotile_coord: Vector2 = Vector2(-1, -1)):
    var is_autotile = (autotile_coord != Vector2(-1, -1))
    
    if is_autotile:
        tilemap_node.set_cell(pos.x, pos.y, tile_index, false, false, false, autotile_coord)
        tilemap_node.update_bitmask_area(pos)
    else:
        tilemap_node.set_cell(pos.x, pos.y, tile_index)

func clear_tilemaps():
    DirtWaterAutotile.clear()
    CliffAutotile.clear()

func fill_full_map(Tileset: TileMap, tile_size: int, tile_index: int, autotile_coord: Vector2 = Vector2(-1, -1)):
    var full_rect: = Rect2()

    for room in world_data.rooms:
        var rect = Rect2(room.top_left, room.size)
        full_rect = full_rect.merge(rect)
    
    var outer_border_tile_number = 5
    var outer_border = Vector2(outer_border_tile_number * tile_size, outer_border_tile_number * tile_size)
    var top_left = Tileset.world_to_map(full_rect.position - outer_border)
    var bottom_right = Tileset.world_to_map(full_rect.end + outer_border)
    
    # Add one extra tile cause it seems offseted
    for x in range(top_left.x, bottom_right.x + 1):
        for y in range(top_left.y, bottom_right.y + 1):
            set_tileset_cell(Tileset, Vector2(x, y), tile_index, autotile_coord)
        
func carve_rooms(Tileset: TileMap, tile_size: int, tile_index: int, autotile_coord: Vector2 = Vector2(-1, -1)):
    for room in world_data.rooms:
        var top_left = Tileset.world_to_map(room.top_left)
        var bottom_right = Tileset.world_to_map(room.bottom_right)
        
        for x in range(top_left.x, bottom_right.x):
            for y in range(top_left.y, bottom_right.y):
                set_tileset_cell(Tileset, Vector2(x, y), tile_index, autotile_coord)
    
func carve_paths(Tileset: TileMap, tile_size: int, tile_index: int, autotile_coord: Vector2 = Vector2(-1, -1)):
    
    
    # Corridors
    var corridors = []
    for room in world_data.rooms:
##        var size_in_tiles = (room.size / 2 / tile_size).floor()
##        var size = (room.size / TILE_SIZE).floor()
#        # Review source map
##        var pos = GrassTilemap.world_to_map(room.position)
##        var top_left_in_tiles = (room.center / tile_size).floor() - size_in_tiles
##        var top_left_in_tiles_2 = (room.top_left / tile_size).floor()
##        var ul = (room.position / TILE_SIZE).floor() - size
#        var corridor_wide_size = 2
##        var room_top_left = CliffAutotile.world_to_map()
#
#        var room_top_left_cliff = Tileset.world_to_map(room.top_left)
#        var room_bottom_right_cliff = Tileset.world_to_map(room.bottom_right)
#
#        # Carve Cliff-size room
#        for x in range(room_top_left_cliff.x, room_bottom_right_cliff.x):
#            for y in range(room_top_left_cliff.y, room_bottom_right_cliff.y):
#                set_tileset_cell(CliffAutotile, Vector2(x, y), -1, CLIFF_AUTOTILE_COORD)
        
        # Make corridors and carve rooms
#        for x in range(corridor_wide_size, size.x * 2 - 1):
#            for y in range(corridor_wide_size, size.y * 2 - 1):
#                set_tileset_cell(GrassTilemap, Vector2(ul.x + x, ul.y + y), GRASS_TILE)
##                set_tileset_cell(CliffAutotile, Vector2(ul.x + x, ul.y + y), -1, CLIFF_AUTOTILE_COORD)
                
        # Carve connecting corridor
        if path:
            var point = path.get_closest_point(Vector3(room.center.x, room.center.y, 0))
            for connection in path.get_point_connections(point):
                if not connection in corridors:
                    var point_position = path.get_point_position(point)
                    var connection_position = path.get_point_position(connection)
                    # Review source map
                    var start = Tileset.world_to_map(Vector2(point_position.x, point_position.y))
                    var end = Tileset.world_to_map(Vector2(connection_position.x, connection_position.y))
                    
                    carve_path(start, end, Tileset, tile_size, tile_index, autotile_coord)
            corridors.append(point)
    
    
    
func fill_border_tilemap():
    fill_full_map(CliffAutotile, 32, CLIFF_TILESET, CLIFF_AUTOTILE_COORD)
    carve_rooms(CliffAutotile, 32, UNSET_TILE, CLIFF_AUTOTILE_COORD)
    carve_paths(CliffAutotile, 32, UNSET_TILE, CLIFF_AUTOTILE_COORD)
func fill_ground_tilemap():
    fill_full_map(DirtWaterAutotile, 16, CLIFF_DIRT_TILESET, DIRT_AUTOTILE_COORD)
    carve_rooms(DirtWaterAutotile, 16, GRASS_TILESET)
    carve_paths(DirtWaterAutotile, 16, DIRT_TILESET, DIRT_AUTOTILE_COORD)

func populate_props():
    pass

func populate_enemies():
    var bats_container = YSort.new()
    bats_container.name = "Bats"
    add_child(bats_container)
    for room in world_data.rooms:
        if randf() < 0.5:
            var bat = Bat.instance()
            bats_container.add_child(bat)
            bat.global_position = room.center

func make_map():
    find_start_room()
    find_end_room()
    
    clear_tilemaps()
    
    fill_border_tilemap()
    fill_ground_tilemap()

func _make_map():
    find_start_room()
    find_end_room()
    clear_tilemaps()
    
    fill_border_tilemap()
    fill_ground_tilemap()
#    populate_props()
#    populate_enemies()
    
    
    var full_rect: = Rect2()

    for room in Rooms.get_children():
        var rect = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
        full_rect = full_rect.merge(rect)

    # Review source map
    var top_left_cliff = CliffAutotile.world_to_map(full_rect.position)
    var bottom_right_cliff = CliffAutotile.world_to_map(full_rect.end)

#    var room_top_left = room.position - room.size
#    var room_top_right = room_top_left + Vector2(room.size.x * 2, 0)
#    var room_bottom_right = room.position + room.size
#    var room_bottom_left = room_bottom_right - Vector2(room.size.x * 2, 0)
#    draw_string(font, room.position, "X", Color(1,1,1))
#    for x in range(room_top_left.x, room_top_right.x, 32):
#        for y in range(room_top_left.y, room_bottom_right.y, 32):
#            draw_string(font, Vector2(x, y), "@", Color(1,1,1))

    # Make the base layout
    for x in range(top_left_cliff.x - 1, bottom_right_cliff.x + 1):
        for y in range(top_left_cliff.y - 1, bottom_right_cliff.y + 1):
            set_tileset_cell(CliffAutotile, Vector2(x, y), CLIFF_TILESET, CLIFF_AUTOTILE_COORD)
#            set_tileset_cell(GrassTilemap, Vector2(x, y), GRASS_TILE)
#            set_tileset_cell(DirtWaterAutotile, Vector2(x, y), DIRT_TILESET, DIRT_AUTOTILE_COORD)

#    set_tileset_cell(CliffAutotile, Vector2(top_left_cliff.x + 3, top_left_cliff.y), -1, CLIFF_AUTOTILE_COORD)

    var top_left = DirtWaterAutotile.world_to_map(full_rect.position)
    var bottom_right = DirtWaterAutotile.world_to_map(full_rect.end)
    # Make the base layout
#    for x in range(top_left.x, bottom_right.x):
#        for y in range(top_left.y, bottom_right.y):
#            set_tileset_cell(GrassTilemap, Vector2(x, y), GRASS_TILE)
##            set_tileset_cell(DirtWaterAutotile, Vector2(x, y), DIRT_TILESET, DIRT_AUTOTILE_COORD)

    # Make rooms layout
#    for room in Rooms.get_children():
#        var collision = room.get_node("CollisionShape2D")
#        var rect = Rect2(room.position - room.size, collision.shape.extents * 2)
#        set_tileset_cell(GrassTilemap, rect.position, GRASS_TILE)
##        set_tileset_cell(CliffAutotile, rect.position, -1)
    
#    spawn_bat(1.0, true)
    
    # Corridors
    var corridors = []
    for room in Rooms.get_children():
        var size = (room.size / TILE_SIZE).floor()
        # Review source map
#        var pos = GrassTilemap.world_to_map(room.position)
        var ul = (room.position / TILE_SIZE).floor() - size
        var corridor_wide_size = 2
#        var room_top_left = CliffAutotile.world_to_map()
        
        var room_top_left_cliff = CliffAutotile.world_to_map(room.position - room.size)
        var room_bottom_right_cliff = CliffAutotile.world_to_map(room.position + room.size)
        
        # Carve Cliff-size room
        for x in range(room_top_left_cliff.x, room_bottom_right_cliff.x):
            for y in range(room_top_left_cliff.y, room_bottom_right_cliff.y):
                set_tileset_cell(CliffAutotile, Vector2(x, y), -1, CLIFF_AUTOTILE_COORD)
        
        # Make corridors and carve rooms
#        for x in range(corridor_wide_size, size.x * 2 - 1):
#            for y in range(corridor_wide_size, size.y * 2 - 1):
#                set_tileset_cell(GrassTilemap, Vector2(ul.x + x, ul.y + y), GRASS_TILE)
##                set_tileset_cell(CliffAutotile, Vector2(ul.x + x, ul.y + y), -1, CLIFF_AUTOTILE_COORD)
                
        # Carve connecting corridor
        if path:
            var point = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
            for connection in path.get_point_connections(point):
                if not connection in corridors:
                    var point_position = path.get_point_position(point)
                    var connection_position = path.get_point_position(connection)
                    # Review source map
                    var start = DirtWaterAutotile.world_to_map(Vector2(point_position.x, point_position.y))
                    var start_cliff = CliffAutotile.world_to_map(Vector2(point_position.x, point_position.y))
                    var end = DirtWaterAutotile.world_to_map(Vector2(connection_position.x, connection_position.y))
                    var end_cliff = CliffAutotile.world_to_map(Vector2(connection_position.x, connection_position.y))
    
#                    carve_path(start_cliff, end_cliff)
            corridors.append(point)
#
#        var rect = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)


func carve_path(start: Vector2, end: Vector2, Tileset: TileMap, tile_size: int, tile_index: int, autotile_coord: Vector2 = Vector2(-1, -1)):
    var x_diff = sign(end.x - start.x)
    var y_diff = sign(end.y - start.y)
    
    if x_diff == 0:
        x_diff = pow(-1.0, randi() % 2)
    if y_diff == 0:
        y_diff = pow(-1.0, randi() % 2)
    
    var x_to_y = start
    var y_to_x = end
    
    if randi() % 2 > 0:
        x_to_y = end
        y_to_x = start
    
    for x in range(start.x, end.x, x_diff):
        set_tileset_cell(Tileset, Vector2(x, x_to_y.y), tile_index, autotile_coord)
        set_tileset_cell(Tileset, Vector2(x, x_to_y.y + y_diff), tile_index, autotile_coord)
        
#        set_tileset_cell(DirtWaterAutotile, Vector2(x, x_to_y.y), DIRT_TILESET, DIRT_AUTOTILE_COORD)
#        set_tileset_cell(DirtWaterAutotile, Vector2(x, x_to_y.y), WATER_TILESET, WATER_AUTOTILE_COORD)
#        set_tileset_cell(DirtWaterAutotile, Vector2(x, x_to_y.y + y_diff), DIRT_TILESET, DIRT_AUTOTILE_COORD)
#        set_tileset_cell(DirtWaterAutotile, Vector2(x, x_to_y.y + y_diff), WATER_TILESET, WATER_AUTOTILE_COORD)

    for y in range(start.y, end.y, y_diff):
#        set_tileset_cell(DirtWaterAutotile, Vector2(y_to_x.x, y), DIRT_TILESET, DIRT_AUTOTILE_COORD)
#        set_tileset_cell(DirtWaterAutotile, Vector2(y_to_x.x, y), WATER_TILESET, WATER_AUTOTILE_COORD)
#        set_tileset_cell(DirtWaterAutotile, Vector2(y_to_x.x + x_diff, y), DIRT_TILESET, DIRT_AUTOTILE_COORD)
#        set_tileset_cell(DirtWaterAutotile, Vector2(y_to_x.x + x_diff, y), WATER_TILESET, WATER_AUTOTILE_COORD)
        set_tileset_cell(Tileset, Vector2(y_to_x.x, y), tile_index, autotile_coord)
        set_tileset_cell(Tileset, Vector2(y_to_x.x + x_diff, y), tile_index, autotile_coord)
        
    
#    CliffAutotile.update_bitmask_region(Vector2(start.x, end.x), Vector2(start.y, end.y))

func make_rooms():
    clear_tilemaps()
    world_data.rooms = []
    
    for i in range(room_number):
        var pos = Vector2(rand_range(-horizontal_spread, horizontal_spread), 0)
        var room = RoomGenerator.instance()
        room.init(with_background)
        var width = min_room_size + (randi() % (max_room_size - min_room_size))
        var height = min_room_size + (randi() % (max_room_size - min_room_size))

        # The size of the room (aka the shape extents) is hal of the real room size
        room.make_room(pos, Vector2(width, height) * TILE_SIZE)
        Rooms.add_child(room)

    yield(get_tree().create_timer(1.1), "timeout")

    # Remove some random rooms and make static the rest
    var room_positions = []
    for room in Rooms.get_children():
        if is_instance_valid(room):
            if randf() < cull:
                room.queue_free()
            else:
                room.mode = RigidBody2D.MODE_STATIC
                room_positions.append(Vector3(room.position.x, room.position.y, 0))
                
                var room_top_left: Vector2 = room.position - room.size
                var room_bottom_right: Vector2 = room.position + room.size
                var room_center: Vector2 = room.position
                var room_size: Vector2 = room.size * 2
                world_data.rooms.append({
                    top_left = room_top_left,
                    bottom_right = room_bottom_right,
                    center = room_center,
                    size = room_size
                })

    yield(get_tree(), "idle_frame")
    find_mst(room_positions)

func find_mst(nodes: Array):
    if nodes.size() <= 1:
        return

    path = AStar.new()
    path.add_point(path.get_available_point_id(), nodes.pop_front())

    while nodes.size():
        var min_distance = INF
        var next_min_node = null
        var current_node = null

        for point in path.get_points():
            var point_position = path.get_point_position(point)

            for node in nodes:
                if point_position.distance_to(node) < min_distance:
                    min_distance = point_position.distance_to(node)
                    next_min_node = node
                    current_node = point_position

        var point_id = path.get_available_point_id()
        path.add_point(point_id, next_min_node)

        path.connect_points(path.get_closest_point(current_node), point_id)
        nodes.erase(next_min_node)

    print("MST Completed")
    path_set = true

func find_start_room():
    var min_x = INF
    for room in Rooms.get_children():
        if room.position.x < min_x:
            start_room = room
            min_x = room.position.x

func find_end_room():
    var max_x = -INF
    for room in Rooms.get_children():
        if room.position.x > max_x:
            end_room = room
            max_x = room.position.x

func spawn_enemies():
    spawn_bat(0.7)

func spawn_bat(bat_spawn_ratio: float, spawn_at_origin: bool = false):
    for room in Rooms.get_children():
        if randf() < bat_spawn_ratio:
            var bat = Bat.instance()
            room.add_child(bat)
            if spawn_at_origin:
                bat.position = Vector2.ZERO
            else:
                bat.position = room.position

func spawn_player():
    var player = Player.instance()
    add_child(player)
    player.position = start_room.position
    var ps = player.get_node("Stats")

func clear_generation_nodes():
    PlayerCamera.current = false
    $CanvasLayer.queue_free()
    for room in Rooms.get_children():
        var collision = room.get_node("CollisionShape2D")
        # Remove collisions
        room.remove_child(collision)

func start_game():
    play_mode = true
    clear_generation_nodes()
    
    spawn_player()
    spawn_enemies()
    

func _on_Button_pressed():
    for room in Rooms.get_children():
        room.queue_free()

#        Rooms.get_children().clear()
    make_rooms()


func _on_Button2_pressed():
    make_map()

func _on_HSlider_value_changed(value):
    PlayerCamera.zoom = Vector2(value, value)

func _on_RoomNumber_value_changed(value):
    room_number = value

func _on_HSpread_value_changed(value):
    horizontal_spread = value

func _on_VSpread_value_changed(value):
    vertical_spread = value


func _on_RoomBackground_toggled(button_pressed):
    with_background = button_pressed


func _on_Start_pressed():
    start_game()


func _on_CullRatio_value_changed(value):
    cull = value
