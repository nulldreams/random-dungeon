extends Node2D

export var weapon_owner = ""
export var weapon_texture = "sword"
onready var sprite = $Area2D/Sprite
onready var bow = $Area2D/Bow
onready var animation_player = $Area2D/animation_player

func _ready():
	sprite.texture = load(WeaponsMap.weapon_list[weapon_texture])

func _physics_process(delta):
	sprite.texture = load(WeaponsMap.weapon_list[weapon_texture])
	if weapon_texture == "bow":
		bow.visible = true
		sprite.visible = false
	else:
		bow.visible = false
		sprite.visible = true

func can_deal_damage(body):
	return body.name != weapon_owner.name# and animation_player.current_animation == "attacking"


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		var knockbak_direction = (global_position - body.global_position).normalized()
		var knockback_range = knockbak_direction * 10000
		body.hit(null, knockback_range * Vector2(-1, -1))
