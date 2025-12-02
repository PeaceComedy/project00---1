extends Node

@export var main_menu_scene: PackedScene # 初始主菜单
@export var game_over_menu_scene: PackedScene # 死亡菜单
@export var default_player: PackedScene # 默认玩家
@export var first_level: PackedScene # 初始关卡
@export var hud_scene: PackedScene # 游戏内ui

@onready var world_container: Node2D = $WorldContainer
@onready var gui: CanvasLayer = $GUI
@onready var hud: CanvasLayer = $HUD

var current_main_menu_instance: Node = null # 用来存储当前的主菜单实例
var current_game_over_menu: Node = null # 用来存储当前打开的死亡菜单


func _ready():
	GlobalPlayerManager.player_scene = default_player # 初始化全局玩家配置
	GlobalLevelManager.level_change_requested.connect(_on_global_level_changed) # 监听全局关卡切换请求
	GlobalPlayerManager.player_died.connect(_on_player_died) # 监听玩家死亡
	load_main_menu() # 加载主菜单


func load_main_menu(): # 加载主菜单
	_clear_world() # 清空旧关卡
	_clear_hud() # 清空旧ui
	
	current_main_menu_instance = main_menu_scene.instantiate()
	gui.add_child(current_main_menu_instance)
	# 连接信号：当菜单发出"start_game"时，执行_on_game_started
	if current_main_menu_instance.has_signal("start_game"): 
		current_main_menu_instance.start_game.connect(_on_game_start)

func _on_game_start(): # 开始游戏
	current_main_menu_instance.queue_free()
	current_main_menu_instance = null
	
	load_level(first_level) # 加载初始场景
	load_hud() # 加载战斗ui

func load_level(level_packed: PackedScene): # 加载关卡
	_clear_world() # 清空旧关卡
	var level_instance = level_packed.instantiate() # 实例化新关卡
	world_container.call_deferred("add_child", level_instance)

func load_hud(): # 加载HUD
	var ui_instance = hud_scene.instantiate()
	hud.add_child(ui_instance)

func _on_global_level_changed(next_scene_path: String, target_point_name: String): # 全局关卡切换
	_clear_world() # 清理旧关卡
	var new_level = load(next_scene_path) # 加载新关卡
	var level_instance = new_level.instantiate()
	world_container.add_child(level_instance)
		
	await get_tree().physics_frame # 等待物理帧，确保新地图的碰撞体和玩家都已初始化
		
	var entry_point = level_instance.find_child(target_point_name) # 在新关卡寻找名字匹配的节点
	if is_instance_valid(GlobalPlayerManager.player): # 安全检查，确保玩家实例存在，且没有被释放
		GlobalPlayerManager.player.global_position = entry_point.global_position

func _on_player_died(): # 玩家死亡处理
	hud.visible = false
	current_game_over_menu = game_over_menu_scene.instantiate() # 实例化GameOver界面
	gui.add_child(current_game_over_menu)
	if current_game_over_menu.has_signal("respawn_requested"): # 连接UI的重生信号
		current_game_over_menu.respawn_requested.connect(_on_respawn)

func _on_respawn(): # 重生逻辑
	current_game_over_menu.queue_free() # 清除Game Over界面
	current_game_over_menu = null # 清空引用，防止后续误判
	
	var player = GlobalPlayerManager.player # 获取现有信息
	# 获取当前正在运行的关卡节点,也就是WorldContainer下第一个节点
	var current_level_node = world_container.get_child(0)
	if current_level_node and player:
		var spawn_point = current_level_node.find_child("PlayerSpawn") # 在当前地图里找出生点
		player.global_position = spawn_point.global_position # 搬运玩家
		player.revive() # 唤醒玩家

func _clear_world(): # 清空世界容器
	for child in world_container.get_children(): child.queue_free()

func _clear_hud(): # 清理hud
	for child in hud.get_children(): child.queue_free()
