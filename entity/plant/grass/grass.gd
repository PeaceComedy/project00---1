extends Node2D

@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	hurtbox.hurt.connect(_on_hurt) # 手动连接信号
	
# 定义函数：受伤。有hitbox接触，执行破坏动画，稍后消失
func _on_hurt(other_hitbox: Hitbox) -> void:
	$AnimatedSprite2D.play("destruction")
	await get_tree().create_timer(0.6).timeout
	queue_free()
