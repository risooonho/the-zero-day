extends Control

class_name Avatar

var actor

onready var avatar_selected = preload("res://scenes/hud/avatar_handler/images/avatar-background-selected.png")
onready var avatar_not_selected = preload("res://scenes/hud/avatar_handler/images/avatar-background-normal.png")

func _ready():
	PlayerManager.connect("player_gain_hp", self, "_on_player_gain_hp")
	PlayerManager.connect("player_get_damage", self, "_on_player_get_damage")
	PlayerManager.connect("player_gain_xp", self, "_on_player_gain_xp")
	PlayerManager.connect("player_level_up", self, "_on_player_level_up")

#func _exit_tree():
#	PlayerManager.disconnect("player_gain_hp", self, "_on_player_gain_hp")
#	PlayerManager.disconnect("player_get_damage", self, "_on_player_get_damage")
#	PlayerManager.disconnect("player_gain_xp", self, "_on_player_gain_xp")
#	PlayerManager.disconnect("player_level_up", self, "_on_player_level_up")

func add_avatar_actor(avatar_actor : GActor):
	$HealthBar.value = avatar_actor.data.hp
	$HealthBar.max_value = avatar_actor.data.max_hp
	
	$Level.text = str(avatar_actor.data.level)
	
	$XPBar.value = avatar_actor.data.xp
	$XPBar.max_value = avatar_actor.data.xp_required
	
	$Photo.texture = get_photo(avatar_actor.data.player_type)
	
	actor = avatar_actor

# NEEDFIX: Se requiere usar preload en ves de load
# Recibe un Enums.PlayerType
func get_photo(player_type):
	match player_type:
		Enums.PlayerType.DORBOT:
			return load("res://scenes/hud/avatar_handler/players_images/dorbot-face.png")
		Enums.PlayerType.MATBOT:
			return load("res://scenes/hud/avatar_handler/players_images/matbot-face.png")
		Enums.PlayerType.PIXBOT:
			return load("res://scenes/hud/avatar_handler/players_images/pixbot-face.png")
		Enums.PlayerType.SERBOT:
			return load("res://scenes/hud/avatar_handler/players_images/serbot-face.png")

func select():
	$AvatarBackground.texture = avatar_selected
	
func deselect():
	$AvatarBackground.texture = avatar_not_selected
	
func _on_player_gain_hp(player, hp):
	# Solución parche a un problema de que al cargar por segunda
	# ves los GPlayer esta conectado a instancias removidas.
	if not is_instance_valid(player):
		return
	
	$HealthBar.value = player.data.hp
	$HealthBar/AnimHealth.play("health")
	
func _on_player_get_damage(player, damage):
	# Solución parche a un problema de que al cargar por segunda
	# ves los GPlayer esta conectado a instancias removidas.
	if not is_instance_valid(player):
		return
	
	$HealthBar.value = player.data.hp
	$HealthBar/AnimHealth.play("damage")
	
	SoundManager.play(SoundManager.Sound.PLAYER_DAMAGE_1)
	
func _on_player_gain_xp(player, xp):
	# Solución parche a un problema de que al cargar por segunda
	# ves los GPlayer esta conectado a instancias removidas.
	if not is_instance_valid(player):
		return
	
	$XPBar.value = player.data.xp
	$XPBar.max_value = player.data.xp_required
	
	if not $XPBar/AnimXP.current_animation == "level_up" and not $XPBar/AnimXP.is_playing():
		$XPBar/AnimXP.play("gain_xp")
	
func _on_player_level_up(player):
	# Solución parche a un problema de que al cargar por segunda
	# ves los GPlayer esta conectado a instancias removidas.
	if not is_instance_valid(player):
		return
	
	$HealthBar.max_value = player.data.max_hp
	$Level.text = str(player.data.level)
	$XPBar/AnimXP.play("level_up")
	SoundManager.play(SoundManager.Sound.LEVEL_UP)
	