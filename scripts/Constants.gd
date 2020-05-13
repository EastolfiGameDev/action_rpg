extends Node

const HOST_PLAYER_ID = 1
#const SAVE_FILE = "user://savegame.save"
const SAVE_FILE = "res://savegame.json"

enum STATES {
    IDLE, SLEEP,
    WANDER, CHASE,
    HURT, DIE,
    PREVIOUS
}
