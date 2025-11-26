extends Node

@export var default_player: PackedScene # 默认玩家场景
@export var first_level: PackedScene # 初始关卡
@onready var world_container: Node2D = $WorldContainer

func _ready():
	# 把player.tscn交给GlobalPlayerManager保管，就有了生成玩家的能力
	GlobalPlayerManager.player_scene = default_player
	
	load_level(first_level) # 加载第一关

func load_level(level_packed: PackedScene): # 关卡切换逻辑
	for child in world_container.get_children(): # 清空旧关卡
		child.queue_free()
		
	if level_packed: # 实例化新关卡
		var level_instance = level_packed.instantiate()
		world_container.call_deferred("add_child", level_instance)
