extends Node2D

func initialize(params: Dictionary):
    if params.get("load_state") == true:
        GameState.load_game_state()
