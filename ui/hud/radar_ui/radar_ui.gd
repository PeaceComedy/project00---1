extends Control

@export var world_detection_range: float = 300.0 # 雷达在游戏世界中探测的半径范围
var ui_radius: float = 50.0 # 雷达UI的半径 (设置大小为100x100，所以半径是50)

var bg_color: Color = Color("0d2b0d", 0.8) # 深墨绿色背景
var line_color: Color = Color("367336") # 浅绿色线条
var enemy_blip_color: Color = Color("ff0000") # 红色敌方点

# --- 内部变量 ---
@onready var player_blip: ColorRect = $PlayerBlip

var player_node: Node2D
var enemy_blip_pool: Array[ColorRect] = [] # 用于对象池的敌人点列表
var radar_center: Vector2


func _ready() -> void:
	# 设置雷达中心点和半径
	ui_radius = size.x / 2.0
	radar_center = size / 2.0
	
	# 确保玩家点居中
	if player_blip:
		player_blip.position = radar_center - player_blip.size / 2.0

	# 尝试获取玩家节点
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_node = players[0]
	
	# 初始化一个敌人点的对象池 (比如预先创建20个点)
	# 这样可以避免在游戏中频繁创建和销毁节点，提高性能
	for i in range(20):
		var blip = ColorRect.new()
		blip.color = enemy_blip_color
		blip.size = Vector2(2, 2) # 2x2像素的红点
		blip.visible = false
		add_child(blip)
		enemy_blip_pool.append(blip)
	
	# 触发一次背景绘制
	queue_redraw()

# 使用 Godot 的绘图函数来画像素雷达背景
func _draw() -> void:
	# 1. 绘制圆形背景底色
	draw_circle(radar_center, ui_radius, bg_color)
	# 2. 绘制外圈边框 (未填充)
	draw_arc(radar_center, ui_radius - 1, 0, TAU, 32, line_color, 1.0)
	# 3. 绘制内圈距离参考线
	draw_arc(radar_center, ui_radius * 0.5, 0, TAU, 24, line_color, 1.0)
	# 4. 绘制十字交叉线
	draw_line(Vector2(radar_center.x, 0), Vector2(radar_center.x, size.y), line_color)
	draw_line(Vector2(0, radar_center.y), Vector2(size.x, radar_center.y), line_color)

func _process(delta: float) -> void:
	# 如果找不到玩家，就什么都不做
	if not is_instance_valid(player_node):
		_reset_all_blips()
		return
		
	update_radar_blips()

func update_radar_blips():
	# 1. 先隐藏所有对象池里的敌人点
	var active_blip_index = 0
	for blip in enemy_blip_pool:
		blip.visible = false

	# 2. 获取所有敌人
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	# 3. 遍历敌人并计算位置
	for enemy in enemies:
		if not is_instance_valid(enemy): continue
		
		# 计算敌人相对于玩家的向量
		var dir_to_enemy = enemy.global_position - player_node.global_position
		var distance = dir_to_enemy.length()
		
		# 如果敌人在侦测范围内
		if distance <= world_detection_range:
			# 获取一个可用的 UI 点
			if active_blip_index >= enemy_blip_pool.size():
				break # 对象池用完了，不再显示更多敌人
				
			var blip = enemy_blip_pool[active_blip_index]
			blip.visible = true
			
			# 核心数学计算：
			# 将世界距离映射到 UI 半径比例
			var scaled_distance = (distance / world_detection_range) * (ui_radius - 2) # -2 是为了留点边距
			
			# 计算 UI 上的方向向量 (归一化)
			var normalized_dir = dir_to_enemy.normalized()
			
			# 计算最终 UI 位置：中心点 + 方向 * 缩放后的距离 - 点自身大小的一半(为了居中)
			blip.position = radar_center + (normalized_dir * scaled_distance) - (blip.size / 2.0)
			
			active_blip_index += 1

func _reset_all_blips():
	if player_blip: player_blip.visible = false
	for blip in enemy_blip_pool:
		blip.visible = false
