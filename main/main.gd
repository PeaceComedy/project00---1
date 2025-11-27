extends Node

@export var main_menu_scene: PackedScene # 初始主菜单
@export var game_over_menu_scene: PackedScene # 死亡菜单
@export var default_player: PackedScene # 默认玩家
@export var first_level: PackedScene # 初始关卡

@onready var world_container: Node2D = $WorldContainer
@onready var gui: CanvasLayer = $GUI


func _ready():
	GlobalPlayerManager.player_scene = default_player # 初始化全局玩家配置
	GlobalLevelManager.level_change_requested.connect(_on_global_level_changed) # 监听全局关卡切换请求
	GlobalPlayerManager.player_died.connect(_on_player_died) # 监听玩家死亡
	load_main_menu() # 加载主菜单

func load_main_menu(): # 加载主菜单
	_clear_world() # 清空旧关卡
	if main_menu_scene:
		var menu_instance = main_menu_scene.instantiate() # 实例化主菜单
		gui.add_child(menu_instance)
		# 连接信号：当菜单发出"start_game"时，执行_on_game_started
		if menu_instance.has_signal("start_game"): 
			menu_instance.start_game.connect(_on_game_start)

func _on_game_start(): # 开始游戏
	for child in gui.get_children(): # 清除GUI里的主菜单
		child.queue_free()
	load_level(first_level) # 加载第一关

func load_level(level_packed: PackedScene): # 加载关卡
	_clear_world() # 清空旧关卡
	if level_packed: # 实例化新关卡
		var level_instance = level_packed.instantiate()
		world_container.call_deferred("add_child", level_instance)

func _on_global_level_changed(next_scene_path: String, target_point_name: String): # 全局关卡切换
	_clear_world() # 清理旧关卡
	var new_level = load(next_scene_path) # 加载新关卡
	if new_level:
		var level_instance = new_level.instantiate()
		world_container.add_child(level_instance)
		
		await get_tree().physics_frame # 等待物理帧，确保新地图的碰撞体和玩家都已初始化
		
		var entry_point = level_instance.find_child(target_point_name) # 在新关卡寻找名字匹配的节点
		if is_instance_valid(GlobalPlayerManager.player): # 安全检查，确保玩家实例存在，且没有被释放
			GlobalPlayerManager.player.global_position = entry_point.global_position

func _on_player_died(): # 玩家死亡处理
	if game_over_menu_scene:
		var game_over_instance = game_over_menu_scene.instantiate()
		gui.add_child(game_over_instance)
		if game_over_instance.has_signal("respawn_requested"): # 连接UI的重生信号
			game_over_instance.respawn_requested.connect(_on_respawn)

func _on_respawn(): # 重生逻辑
	for child in gui.get_children(): # 清除Game Over界面
		child.queue_free()


func _clear_world(): # 辅助函数：清空世界容器
	for child in world_container.get_children():
		child.queue_free()
