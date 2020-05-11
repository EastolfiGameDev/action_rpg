extends StaticBody2D

onready var Animator: AnimationPlayer = $AnimationPlayer

enum States {
    OPEN, CLOSE
}

var state = States.CLOSE

func _ready():
    Animator.play("idle")
    $InteractArea.add_to_group("Interactable")

func end_interact():
    _close_chest()

func interact(actor: Node2D):
    if state == States.CLOSE:
        _open_chest(actor)
    else:
        _close_chest()

func _open_chest(actor: Node2D):
    Animator.play("open")
    state = States.OPEN
    if actor.has_method("chest_opened"):
        actor.chest_opened()

func _close_chest():
    if state != States.CLOSE:
        Animator.play("close")
        state = States.CLOSE


func _on_InteractArea_interact(actor: Node2D):
    interact(actor)


func _on_InteractArea_interact_end(_actor: Node2D):
    end_interact()
