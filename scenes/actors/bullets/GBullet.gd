extends KinematicBody2D

class_name GBullet

export (int) var bullet_speed = 250

enum Trajectory {
	LINEAL,
	SEEKER
}
var trajectory = Trajectory.LINEAL
var direction : Vector2

# El que dispara las balas le dice a la bala cuanto daño
# hace, por ejemplo. Una torreta dispara y le asigna
# 2 de daño a la bala y la bala cuando choca con el
# player le hace 2 de daño.
var damage := 1

# Previene que se haga la animacion de dead mas
# de una vez.
var is_mark_to_dead := false

var collision
var collision_count := 0

var bullet_owner : GActor

var common_bullet_collision = preload("res://scenes/bullet_collision/common/CommonBulletCollision.tscn")
var ot_bullet_collision = true

func _ready():
	$Sprite.playing = true
	
func _physics_process(delta):
	if trajectory == Trajectory.LINEAL:
		move_and_slide(direction * bullet_speed)
	
	collision_count = get_slide_count()
	
	if not is_mark_to_dead and collision_count > 0:
		for i in collision_count:
			collision = get_slide_collision(i)
			if collision.collider.is_in_group("Structures") or collision.collider.is_in_group("Enviroment"):
				dead()
			elif collision.collider.is_in_group("Bullet") and collision.collider.bullet_owner != self.bullet_owner:
				bullet_collision()
				dead()
	
func dead():
	if not is_mark_to_dead:
		is_mark_to_dead = true
#		$HitWall.play()
		$Anim.play("dead")

func bullet_collision():
	if ot_bullet_collision:
		ot_bullet_collision = false
		
		var explosion = common_bullet_collision.instance()
		explosion.global_position = global_position
		get_parent().add_child(explosion)

func _on_TimeToDead_timeout():
	if not is_mark_to_dead:
		dead()

func _on_Anim_animation_finished(anim_name):
	if anim_name == "dead":
		queue_free()
