class_name Hurtbox
extends Area2D

signal hurt(hitbox: Hitbox) # 声明信号：触发受伤

func _ready()-> void:
	# 触发区域进入信号：执行_on_area_entered函数
	area_entered.connect(_on_area_entered)

# 定义函数：有area进入
func _on_area_entered(area_2d: Area2D)-> void:
	if area_2d is not Hitbox: return # 如果不是Hitbox，直接忽略
	hurt.emit(area_2d) # 否则触发受伤
