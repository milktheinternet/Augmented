extends "res://Scripts/Base/EntityBase.gd"

@export
var SPEED : float

@export
var PROC_CHANCE : float

@export
var DAMAGE : float

@export
var PENETRATION : float

@export
var KNOCKBACK : float

@export
var targetGroup : String = "Enemy"

@export
var fireBeats : int = 1

var isCrit : bool

var projectileDeathScene = preload("res://Entities/Projectiles/projectile_death.tscn")

func animate_death():
	var projectileDeath : Node2D = projectileDeathScene.instantiate()
	projectileDeath.position = position
	get_tree().get_root().add_child(projectileDeath)

func _physics_process(delta):
	move_and_collide(velocity)

func damage_body(pos : Vector2, body : Node):
	var attack = Attack.new()
	attack.damage = DAMAGE * (1 + int(isCrit))
	attack.penetration = PENETRATION
	attack.knockback = KNOCKBACK
	attack.pos = pos
	body.hurt(attack)

func _on_area_2d_body_entered(body):
	if body.is_in_group(targetGroup):
		damage_body(global_position, body)
	animate_death()
	queue_free()
		


func _on_area_2d_area_entered(area : Node):
	if area.is_in_group(targetGroup):
		damage_body(global_position, area.get_parent())
	animate_death()
	queue_free()

