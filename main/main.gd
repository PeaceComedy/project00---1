extends Node

@export var main_menu_scene: PackedScene # 初始主菜单
@export var default_player: PackedScene # 默认玩家
@export var first_level: PackedScene # 初始关卡

@onready var world_container: Node2D = $WorldContainer
@onready var gui: CanvasLayer = $GUI


func _ready():
	GlobalPlayerManager.player_scene = default_player # 初始化全局玩家配置
	load_level(first_level) # 加载第一关

func load_main_menu(): # 加载主菜单
	_clear_world() # 清空旧关卡
	if main_menu_scene:
		var menu_instance = main_menu_scene.instantiate() # 实例化主菜单
		gui.add_child(menu_instance)
		if menu_instance.has_signal("start_game"): # 接受信号：点了start
			menu_instance.start_game.connect(_on_game_started)

func _on_game_started(): # 开始游戏(信号回调)
	for child in gui.get_children(): # 清除 GUI 里的主菜单
		child.queue_free()
	
	load_level(first_level) # 加载第一关

func load_level(level_packed: PackedScene): # 加载关卡
	_clear_world() # 清空旧关卡
	if level_packed: # 实例化新关卡
		var level_instance = level_packed.instantiate()
		world_container.call_deferred("add_child", level_instance)

func _clear_world(): # 辅助函数：清空世界容器
	for child in world_container.get_children():
		child.queue_free()
	
