extends KinematicBody2D

const ScentScene = preload("res://scenes/IA/Scent.tscn")

const ACCELERATION: = 600
const MAX_SPEED: = 85
const ROLL_SPEED: = 110
const FRICTION: = 750
# const ICE_FRICTION = 200

enum States {
    MOVE,
    ROLL,
    ATTACK
}

export(bool) var god_mode = false
export(bool) var can_interact = true

#puppet var state_slave = States.MOVE
#puppet var direction_slave: = Vector2.ZERO

onready var ScreenControls = $ScreenControls
onready var animator: AnimationTree = $AnimationTree
onready var effect_animator: AnimationTree = $Effects
onready var animation_state: AnimationNodeStateMachinePlayback = animator.get("parameters/playback")
onready var sword_hitbox: Area2D = $HitboxPivot/SwordHitbox
onready var hurtbox: Area2D = $Hurtbox
onready var stats = $Stats
onready var ScentTimer: Timer = $Timers/ScentTimer

var state = States.MOVE
var direction: = Vector2.ZERO
var roll_vector: = Vector2.ZERO
var motion: = Vector2.ZERO

var scent_trail: Array = []
var enemies_chasing: int = 0 setget enemies_chasing

func _ready():
#    randomize()
    
    animator.active = true
    $HitboxPivot/SwordHitbox/CollisionShape2D.disabled = true
    
    roll_vector = Vector2.DOWN
    animator.set("parameters/Roll/blend_position", Vector2.LEFT)
    
#    GameState.load_game_state()

func _process(_delta):
#    if is_network_master():
#        if state == States.MOVE:
#            _get_input()
#
#        _check_action()
    if state == States.MOVE:
        _get_input()
    
        _check_action()
        
    if direction != Vector2.ZERO:
        roll_vector = direction
        sword_hitbox.knockback_vector = direction
        
        animator.set("parameters/Idle/blend_position", direction)
        animator.set("parameters/Run/blend_position", direction)
        animator.set("parameters/Attack/blend_position", direction)
        animator.set("parameters/Roll/blend_position", direction)
    

func _physics_process(delta):
#    if not is_network_master():
#        state = state_slave
#        direction = direction_slave
        
    match state:
        States.MOVE:
            state_move(delta)
        States.ATTACK:
            state_attack()
        States.ROLL:
            state_roll()

func _get_input():
    if OS.has_touchscreen_ui_hint():
        direction = ScreenControls.get_joystick_input()
    else:
        direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
        direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
        direction = direction.normalized()
    
#    direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#    direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    
    # Uncomment
#    rset("direction_slave", direction)

func _check_action():
    if Input.is_action_just_pressed("attack"):
        perform_attack()
    elif Input.is_action_just_pressed("move_skill"):
        perform_movement_skill()

func pick_up(item: Item):
    if item.damage > 0:
        stats.damage += item.damage
    if item.gold > 0:
        stats.gold += item.gold

func get_stats() -> Stats:
    return stats

func perform_attack():
    change_state(States.ATTACK)

func perform_movement_skill():
    change_state(States.ROLL)

func change_state(new_state):
    state = new_state
#    rset("state_slave", state)

func state_move(delta):  
    if direction != Vector2.ZERO:
        animation_state.travel("Run")
            
        motion = motion.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
    else:
        animation_state.travel("Idle")
        motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
    
    motion = move_and_slide(motion)
#    rset("replicate_position", position)

func state_attack():
    if animation_state.get_current_node() != "Attack":
        motion = Vector2.ZERO
        animation_state.travel("Attack")

func state_roll():
    motion = roll_vector * ROLL_SPEED
    animation_state.travel("Roll")
    
    motion = move_and_slide(motion)

func add_scent():
    var scent = ScentScene.instance()
    scent.source = self
    scent.global_position = global_position
    get_tree().current_scene.add_child(scent)
    scent_trail.push_front(scent)

#### PERSISTENCE ####

func save() -> Dictionary:
    return {
        "filename": get_filename(),
#        "parent": get_parent().get_path(),
        "pos_x": position.x, # Vector2 is not supported by JSON
        "pos_y": position.y,
#        "attack" : attack,
#        "defense" : defense,
#        "current_health" : current_health,
#        "max_health" : max_health,
#        "damage" : damage,
#        "regen" : regen,
#        "experience" : experience,
#        "tnl" : tnl,
#        "level" : level,
#        "attack_growth" : attack_growth,
#        "defense_growth" : defense_growth,
#        "health_growth" : health_growth,
#        "is_alive" : is_alive,
#        "last_attack" : last_attack
    }

#### SET - GET ####
func enemies_chasing(value: int):
    enemies_chasing = value
    
    if enemies_chasing == 1:
        ScentTimer.start()
    elif enemies_chasing == 0:
        ScentTimer.stop()

#### FROM ANIMATION PLAYER ####

func attack_animation_ended():
    change_state(States.MOVE)

func roll_animation_endend():
    change_state(States.MOVE)

#### SIGNALS ####

func _on_AttackButton_pressed():
    perform_attack()

func _on_MovementSkillButton_pressed():
    perform_movement_skill()

func _on_SkillButton_pressed():
    # Invisible skill
    if visible:
        visible = false
        yield(get_tree().create_timer(1.0), "timeout")
        visible = true

func _on_ScreenControls_interact_button_pressed():
    get_tree().call_group("Interactable", "interact_from_button")

func _on_Stats_no_health():
    for scent in scent_trail:
        scent.queue_free()
    
    queue_free()

func _on_Hurtbox_area_entered(area):
    if not god_mode:
        stats.health -= area.damage
    hurtbox.start_invincibility(1.0)
    hurtbox.create_hit_effect()
    
    var player_hit := AudioStreamPlayer.new()
    var stream := load("res://assets/sfx/Hurt.wav")
    player_hit.stream = stream
    get_tree().current_scene.add_child(player_hit)
    player_hit.connect("finished", player_hit, "queue_free")
    player_hit.play()

func _on_ScentTimer_timeout():
    add_scent()

func _on_Hurtbox_invincibility_started():
    effect_animator.play("blink_start")

func _on_Hurtbox_invincibility_ended():
    effect_animator.play("blink_stop")

