extends StaticBody2D

onready var Animator: AnimationPlayer = $AnimationPlayer
onready var Looter = $Loot

enum States {
    OPEN, CLOSE
}

var state = States.CLOSE
var looted = false

func _ready():
    Animator.play("idle")
    $InteractArea.add_to_group("Interactable")

func end_interact():
    _close_chest()

func interact():
    if state == States.CLOSE:
        _open_chest()
    else:
        _close_chest()

func _open_chest():
    Animator.play("open")
    state = States.OPEN
    
    if not looted:
        Looter.drop_loot(self)
        looted = true

func _close_chest():
    if state != States.CLOSE:
        Animator.play("close")
        state = States.CLOSE


func _on_InteractArea_interact(_actor: Node2D):
    interact()


func _on_InteractArea_interact_end(_actor: Node2D):
    end_interact()
