extends Camera2D

const SPEED = 150

var following

enum Mode {FOLLOW, FREE}
var mode = Mode.FOLLOW

var input_dir : Vector2
var input_change_focus : bool

func _ready():
	PlayerManager.connect("player_shooting", self, "_on_player_shooting")

func _physics_process(delta):
	
	# Verificamos si following no a sido borrado
	if following and not weakref(following).get_ref():
		# Ha sido borrado
		
		# NEEDFIX: Esto se llama muchas veces y puede
		# que sea caro llamara mucho a weakref
		return
	
	input_change_focus = Input.is_action_just_pressed("change_focus")
	
	if input_change_focus:
		change_focus()

	if mode == Mode.FOLLOW:
		if following and not following.is_disabled:
			global_position = following.global_position
		else:
			mode = Mode.FREE
	elif mode == Mode.FREE:
		input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		
		if input_dir.x == 1:
			global_position.x += SPEED * delta
		elif input_dir.x == - 1:
			global_position.x -= SPEED * delta
		
		if input_dir.y == 1:
			global_position.y += SPEED * delta
		elif input_dir.y == - 1:
			global_position.y -= SPEED * delta
		
func change_focus():
	following.can_move = false
	following = PlayerManager.get_next_player()
	following.can_move = true

func _on_player_shooting(player, dir):
	$Anim.play("fire")