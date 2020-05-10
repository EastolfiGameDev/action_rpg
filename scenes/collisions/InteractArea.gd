extends Area2D

signal interact_start(actor)
signal interact(actor)
signal interact_end(actor)

export(bool) var show_hint: bool = true

onready var shape: Shape2D = $CollisionShape2D.shape

var actor: Node2D = null

func _input(event):
    if actor != null and Input.is_action_just_pressed("interact"):
        interact()

func init_interact():
    if show_hint:
        var message = ""
        if OS.has_touchscreen_ui_hint():
            message = "Tap"
        else:
            for key in InputMap.get_action_list("interact"):
                if message.length() > 0:
                    message += " | "
                message += key.as_text()
        
        get_tree().call_group("HUD", "show_hint_message", message, $HintPosition.global_position)
    
    emit_signal("interact_start", actor)

func end_interact():
    if show_hint:
        get_tree().call_group("HUD", "hide_hint_message")
        
    emit_signal("interact_end", actor)

func interact():
    emit_signal("interact", actor)


func _on_InteractArea_body_entered(body):
    if body.get("can_interact") == true:
        actor = body
        set_process_input(true)
        init_interact()


func _on_InteractArea_body_exited(_body):
    end_interact()
    actor = null
    set_process_input(false)
