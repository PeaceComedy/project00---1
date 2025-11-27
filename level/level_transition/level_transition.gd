class_name LevelTransition
extends Area2D

# 对应着信号level_change_requested的两个参数
@export_file("*.tscn") var target_scene_path: String
@export var target_entry_point: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered) # 信号连接：玩家进入区域

func _on_body_entered(body: Node2D) -> void:
	# 确认是玩家进入了区域（玩家在 "player"组，或者通过 class_name 判断），呼叫全局管理器
	if body is Player or body.is_in_group("player"):
		# 使用 call_deferred 延迟调用请求，等到当前物理帧处理完毕后，再通知全局管理器，避免物理锁冲突
		GlobalLevelManager.call_deferred("request_level_change", target_scene_path, target_entry_point)
