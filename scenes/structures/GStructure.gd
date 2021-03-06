# Estructuras fijas con las que se puede interactuar

extends GActor

class_name GStructure

var damage_label = preload("res://scenes/hud/floating_hud/FloatingText.tscn")

var is_invulnerable := false
var is_mark_to_destroy := false
# Se puede interactuar con el? Es util cuando queremos
# desplegar un panel cuando presionamos la tecla e
# o interact
var is_interactable := false
# Para activarla solo cuando esta visible, etc.
var is_active := false

var structure_owner = Enums.ActorOwner.UNDEFINED

# Puede interacturar
var _can_iteract := false

# De momento esto esta replicado en el Enums, mas adelante
# hay que borrarlo
enum StructureSize {
	W1X1, # Wall 1x1
	S1X1, # Structure 1x1
	S2X2, # ... 2x2
	S3X3, # ..
	S2X3,
	S3X2
}
var structure_size

signal interacted

func _ready():
	set_process(false)
	set_physics_process(false)

# Puede recibir daño de un player, enemigo u otro
func damage(amount, who_damage = null):
	# Instancia un label indicando el daño recibido y lo agrega al árbol
	var dmg_label : FloatingText = damage_label.instance()
	dmg_label.init("-" + str(amount), FloatingText.Type.DAMAGE)
	dmg_label.position = global_position
	get_parent().add_child(dmg_label)

func _on_InteractArea_body_entered(body):
	if body is GPlayer:
		_can_iteract = true

func _on_InteractArea_body_exited(body):
	if body is GPlayer:
		_can_iteract = false
	
func _on_VisibilityNotifier_screen_entered():
	set_process(true)
	set_physics_process(true)

func _on_VisibilityNotifier_screen_exited():
	set_process(false)
	set_physics_process(false)
