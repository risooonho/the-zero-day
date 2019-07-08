extends GActor

class_name GPlayer

# Es la data del player y la logica del mismo
var data : PHCharacter # Este es el que equipa el arma

export (int) var speed = 3000

var move_x
var move_y

var can_fire := false

var reload_progress := 0.0
var need_reload := false
# Tiempo para la proxima accion de la arma
var time_to_next_action := 1.0
# Tiempo de espera entre cada bala
var time_to_next_action_progress := 0.0

# Tiempo para la proxima accion melee
var melee_time_to_next_action := 0.4
# Tiempo de espera entre cada ataque melee
var melee_time_to_next_action_progress := 0.0

# Total current ammo
var total_ammo = -1

# Escena para mostrar el daño en forma numérica
var damage_label = preload("res://scenes/hud/floating_hud/FloatingText.tscn")

var fire_dir := Vector2()
var current_move_dir := Vector2()
var old_current_move_dir := Vector2.RIGHT

var hud

# Mobile
#

# GActors seleccionados
var selectables := []
# Indice del GActor actual
var selected_num := -1 # -1 es nignuno seleccionado
# GActor seleccionado
var selected_enemy

onready var mobile_selected_pos = get_tree().get_nodes_in_group("GameCamera")

signal fire(dir)
signal dead
signal spawn
signal reload
signal item_taken(item)

func _ready():
	connect("fire", self, "_on_fire")
	
	data.connect("dead", self, "_on_dead")
	data.connect("remove_hp", self, "_on_remove_hp")
	
	# Al iniciar el data equip se va a null siempre
	# para que no suceda un bug, de un arma fantasma.
	data.equip = null
	
	update_weapon()
	
	if mobile_selected_pos.size() > 0:
		mobile_selected_pos = mobile_selected_pos[0].get_node("MobileSelected/Pos")

func _move_handler(delta, distance, run):
	var dir := Vector2()
	
	if not Main.is_mobile:
		dir.x = sign(distance.x)
		dir.y = sign(distance.y)
	else:
		dir = distance.normalized()
		
	
	if not run:
		move_x = dir.x * speed * delta
		move_y = dir.y * speed * delta
		$Sprite.speed_scale = 0.6
	else:
		move_x = dir.x * speed * 2 * delta
		move_y = dir.y * speed * 2 * delta
		$Sprite.speed_scale = 1.2
	
	if dir.y > 0.49:
		$Anim.play("MoveDown")
		if dir.x > 0 : $Sprite.flip_h = false
		elif dir.x < 0 : $Sprite.flip_h = true
	elif dir.y < -0.49:
		$Anim.play("MoveUp")
		if dir.x > 0 : $Sprite.flip_h = false
		elif dir.x < 0 : $Sprite.flip_h = true
	else:
		$Anim.play("MoveSide")
		if dir.x > 0 : $Sprite.flip_h = false
		elif dir.x < 0 : $Sprite.flip_h = true
		
	if move_x != 0 and move_y != 0:
		move_x /= 1.5
		move_y /= 1.5
		
	move_and_slide(Vector2(move_x, move_y), Vector2())

func _stop_handler(delta):
	if $Anim.current_animation != "Idle" and $Anim.current_animation != "hit" or not $Anim.is_playing():
			$Anim.play("Idle")
			$Sprite.speed_scale = 0.1

func _fire_handler():
	if data.equip is PHDistanceWeapon and can_fire and time_to_next_action_progress >= time_to_next_action and data.equip.fire():
		if not Main.is_mobile:
			fire_dir = $GWeaponInBattle/Sprite.get_global_mouse_position() - global_position
		else:
			if selected_enemy:
				fire_dir = selected_enemy.global_position - global_position
				print("hola")
			else:
				if current_move_dir != Vector2.ZERO:
					fire_dir = current_move_dir
				else:
					fire_dir = old_current_move_dir
				
		time_to_next_action_progress = 0.0
		emit_signal("fire", fire_dir.normalized())
	elif not data.equip and melee_time_to_next_action_progress >= melee_time_to_next_action:
		melee_time_to_next_action_progress = 0.0
		melee_attack()
	
func _reload_handler():
	if data.equip is PHDistanceWeapon and total_ammo != 0:
		if reload():
			SoundManager.play(SoundManager.Sound.RELOAD_1)
			reload_progress = 0.0

func _physics_process(delta):
	if not can_move or is_disabled:
		return
		
	if data.equip and time_to_next_action_progress < time_to_next_action:
		time_to_next_action_progress += delta
		return
	elif not data.equip and melee_time_to_next_action_progress < melee_time_to_next_action:
		melee_time_to_next_action_progress += delta
		return
	
	if data.equip is PHDistanceWeapon and data.equip.current_shot == 0 and total_ammo != 0:
		if reload_progress > data.equip.time_to_reload:
			if reload():
				SoundManager.play(SoundManager.Sound.RELOAD_1)
				reload_progress = 0.0
		else:
			reload_progress += delta
	
func update_weapon():
	total_ammo = -1
	
	if data.equip is PHDistanceWeapon:
		$GWeaponInBattle.set_weapon(data.equip)
		can_fire = true
		time_to_next_action = data.equip.time_to_next_action
	else:
		$GWeaponInBattle.set_weapon(null)
		can_fire = false
		
func disable_player(_visible := false):
	is_disabled = true
	disable_interact(_visible)
	
func enable_player(_can_fire := false):
	is_disabled = false
	enable_interact(_can_fire)
	
func disable_interact(_visible := false):
	visible = _visible
	can_move = false
	can_fire = false
	$Collision.disabled = true
	
	# Puede que no exista data ya que el player se
	# puede instanciar directamente.
	if data:
		data.disconnect("item_equiped", self, "_on_item_equiped")

func enable_interact(_can_fire := false):
	visible = true
	can_move = true
	can_fire = _can_fire
	$Collision.disabled = false
	
	data.connect("item_equiped", self, "_on_item_equiped")
	
# Esta funcion se llama mas de lo necesario - Necesita Revisión
# Retorna true si hace reload correctamente y
# false de lo contrario.
func reload():
	# Prevenir que se llame a esta funcion inecesariamente
	if not data.equip is PHDistanceWeapon or data.equip.current_shot >= data.equip.weapon_capacity:
		return false
	
	# Obtener las municiones
	var ammunition_inv = []
	total_ammo = 0
	
	for ammo in DataManager.get_current_inv().inv:
		if ammo is PHAmmo and ammo.ammo_type == data.equip.ammo_type:
			ammunition_inv.append(ammo)
			total_ammo += ammo.ammo_amount
	
	# Si no hay ammunition_inv entonces se sale de la
	# funcion
	if ammunition_inv.size() < 1:
		return false
	
	for ammo in ammunition_inv:
		if data.equip.reload(ammo):
			break
	
	for i in ammunition_inv.size() - 1:
		if ammunition_inv[i].ammo_amount == 0:
			ammunition_inv.pop_front()
	
	# Para que BulletInfo se actualize
	emit_signal("reload")
	
	return true

func melee_attack():
	$BoxingAttack/Anim.play("box_hit")
	SoundManager.play(SoundManager.Sound.HIT_1)

# Player tiene acceso al hud y lo configura
func set_hud(_hud):
	hud = _hud
	
	# Configurar HUD
	hud.get_node("Analog").connect("current_force_updated", self, "_on_current_force_updated")

# Mobile
func select_next():
	if selectables.size() > 1:
		if (selected_num + 1) % selectables.size() == 0 or selected_num >= selectables.size():
			selected_num = 0
		else:
			selected_num += 1
		selected_enemy = selectables[selected_num]
	elif selectables.size() == 1:
		selected_num = 0
		selected_enemy = selectables[selected_num]
	else:
		selected_num = -1

func _on_dead():
	is_mark_to_dead = true
	disable_player(true)
	$Anim.play("dead")
	SoundManager.play(SoundManager.Sound.PLAYER_DEAD_1)

func _on_remove_hp(amount):
	if is_inmortal: return

	$Anim2.play("hit")
	
	# Instancia un label indicando el daño recibido y lo agrega al árbol
	var dmg_label : FloatingText = damage_label.instance()
	dmg_label.init(amount, FloatingText.Type.DAMAGE)
	dmg_label.position = global_position
	get_parent().add_child(dmg_label)

func _on_item_equiped(item):
	update_weapon()

func _on_fire(dir):
	# Temp
	var bullet = ShootManager.fire(dir, data.equip.ammo_type, data.equip.damage)
	bullet.global_position = $GWeaponInBattle/Sprite/FireSpawn.global_position
	bullet.rotation = $GWeaponInBattle/Sprite.rotation
	get_parent().add_child(bullet)

func _on_Anim_animation_finished(anim_name):
	if anim_name == "dead":
		visible = false

func _on_InteractArea_body_entered(body):
	if body is ItemInWorld:
		if DataManager.inventories.size() > 0:
			body.take_item(DataManager.inventories[DataManager.current_player])
			total_ammo = -1
			emit_signal("item_taken", body.data)
	elif body is GBullet and not is_inmortal:
		data.damage(body.damage)
		body.dead()
	elif body is GBullet and is_inmortal:
		body.dead()

func _on_DetectArea_body_entered(body):
	if body is GActor:
		if body == self:
			return
		
		selectables.append(body)
		
		if selectables.size() == 1:
			select_next()
	
func _on_DetectArea_body_exited(body):
	if body is GActor:
		if body == self:
			return
		
		if selectables.has(body) or body.has_meta("structure_owner"):
			var enemy_exited_num = selectables.find(body)
			selectables.remove(enemy_exited_num)
			
			if selected_num == enemy_exited_num:
				select_next()

func _on_current_force_updated(force):
	current_move_dir = force
	
	# Arreglo para corregir la dirección
	current_move_dir.y *= -1

	if current_move_dir != Vector2.ZERO:
		old_current_move_dir = current_move_dir