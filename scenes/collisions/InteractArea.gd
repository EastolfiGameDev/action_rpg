extends Area2D

signal interact_start(actor)
signal interact(actor)
signal interact_end(actor)

export(bool) var show_hint := true
export(String) var hint_message := ""

onready var shape: Shape2D = $CollisionShape2D.shape

var actor: Node2D = null

func _input(event):
    if actor != null and Input.is_action_just_pressed("interact"):
        interact()

func init_interact():
    get_tree().call_group("InteractButtons", "set_enabled", true)

    if show_hint:
        var message: String
        if OS.has_touchscreen_ui_hint():
            message = tr(hint_message + ".MOBILE")
        else:
            message = tr(hint_message)
        
        # Interpolation string - can be improved
        var key_list = ""
        for key in InputMap.get_action_list("interact"):
            if key_list.length() > 0:
                key_list += " | "
            key_list += key.as_text()
        message = message.replace("%interact_key%", key_list)
        
        get_tree().call_group("HUD", "show_hint_message", message, $HintPosition.global_position)

    emit_signal("interact_start", actor)

func end_interact():
    get_tree().call_group("InteractButtons", "set_enabled", false)

    if show_hint:
        get_tree().call_group("HUD", "hide_hint_message")
        
    emit_signal("interact_end", actor)

func interact():
    emit_signal("interact", actor)

func interact_from_button():
    ### HANDLE MULTIPLE ITEMS IN RANGE!!!
    if actor != null:
        interact()

func _on_InteractArea_body_entered(body):
    if body.get("can_interact") == true:
        actor = body
        set_process_input(true)
        init_interact()


func _on_InteractArea_body_exited(_body):
    end_interact()
    actor = null
    set_process_input(false)
