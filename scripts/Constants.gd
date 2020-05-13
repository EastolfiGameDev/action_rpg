extends Node

const HOST_PLAYER_ID = 1
#const SAVE_FILE = "user://savegame.save"
const SAVE_FILE = "res://savegame.json"

# BEWARE IF CHANGING THE ORDER OF THE ENUM
# Since it's position-based, if any of the elements is reordered, the app can fail
# Specially the random-next-state variable, as it doesn't update the array items
enum STATES {
    IDLE, SLEEP,
    WANDER, CHASE,
    HURT, DIE,
    PREVIOUS
}
