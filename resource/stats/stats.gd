class_name Stats
extends Resource

signal health_changed(new_health) # 生命值变化信号
signal no_health()
signal max_health_changed(new_max_health) # 最大生命值变化信号

@export var max_health := 1
@export var health := 1:
	set(value): # setter函数为变量被修改时自动执行的函数
		var previous_health = health
		health = value
		if health != previous_health: health_changed.emit(health)
		if health <= 0: no_health.emit()

@export var move_speed := 100.0
