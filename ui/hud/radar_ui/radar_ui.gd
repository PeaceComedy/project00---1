@tool
extends Control

@export var world_detection_range: float = 300.0
@export var scan_speed: float = 180.0 # 扫描速度 (度/秒)

# --- 颜色配置 ---
var bg_color: Color = Color("3c4029", 0.5)
var line_color: Color = Color("367336")
var scan_line_color: Color = Color("6ecd69", 0.8) # 扫描线高亮色
var enemy_core_color: Color = Color("ff3333") # 敌人核心颜色
var enemy_glow_color: Color = Color("ff0000", 0.3) # 敌人辉光颜色 (半透明)

# --- 内部变量 ---
@onready var player_blip: ColorRect = $PlayerBlip

var player_node: Node2D
var enemy_blip_pool: Array[Control] = [] # 改为 Control 类型以包含子节点
var scan_angle: float = 0.0 # 当前扫描角度

func _ready() -> void:
	# 监听窗口尺寸变化
	resized.connect(_on_resized)
	
	# 初始化更复杂的敌人显示对象池
	for i in range(20):
		# 1. 创建一个容器节点作为"敌人整体"
		var blip_container = Control.new()
		blip_container.visible = false
		add_child(blip_container)
		
		# 2. 创建辉光背景 (大且淡)
		var glow = ColorRect.new()
		glow.color = enemy_glow_color
		glow.size = Vector2(6, 6)
		glow.position = Vector2(-3, -3) # 居中偏移
		glow.name = "Glow"
		blip_container.add_child(glow)
		
		# 3. 创建核心点 (小且亮)
		var core = ColorRect.new()
		core.color = enemy_core_color
		core.size = Vector2(2, 2)
		core.position = Vector2(-1, -1) # 居中偏移
		core.name = "Core"
		blip_container.add_child(core)
		
		# 4. 创建故障噪点 (随机跳动的像素)
		var noise = ColorRect.new()
		noise.color = Color(1, 0.5, 0.5, 0.8)
		noise.size = Vector2(1, 1)
		noise.name = "Noise"
		blip_container.add_child(noise)
		
		enemy_blip_pool.append(blip_container)
	
	queue_redraw()

func _on_resized() -> void:
	if player_blip:
		player_blip.position = (size / 2.0) - (player_blip.size / 2.0)
	queue_redraw()

func _draw() -> void:
	var current_radius = size.x / 2.0
	var center = size / 2.0
	
	# 1. 背景
	draw_circle(center, current_radius, bg_color)
	
	# --- 2. 像素化扫描线效果 ---
	
	# 拖尾残影
	var trail_count = 10 # 可以稍微减少数量，像素风不需要太密
	for i in range(trail_count):
		var trail_angle = scan_angle - i * 3 # 加大间隔让像素间隙更明显
		var trail_alpha = 0.3 - (float(i) / trail_count) * 0.3
		if trail_alpha <= 0: continue
		
		var trail_end = center + Vector2.UP.rotated(deg_to_rad(trail_angle)) * (current_radius - 2)
		
		# 使用像素画线函数
		draw_pixel_line(center, trail_end, Color("6ecd69", trail_alpha))

	# 主扫描线 (高亮)
	var scan_end = center + Vector2.UP.rotated(deg_to_rad(scan_angle)) * (current_radius - 2)
	draw_pixel_line(center, scan_end, scan_line_color)

func _process(delta: float) -> void:
	# 更新扫描线角度
	scan_angle += scan_speed * delta
	if scan_angle >= 360.0:
		scan_angle -= 360.0
	
	# 每一帧都触发重绘来实现扫描线动画
	queue_redraw()

	# 玩家检测逻辑 (带重试)
	if not is_instance_valid(player_node):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_node = players[0]
		else:
			_reset_all_blips()
			return
			
	update_radar_blips()

func update_radar_blips():
	# 1. 隐藏所有点
	for blip in enemy_blip_pool:
		blip.visible = false

	var enemies = get_tree().get_nodes_in_group("enemies")
	var current_radius = size.x / 2.0
	var center = size / 2.0
	var active_blip_index = 0
	
	for enemy in enemies:
		if not is_instance_valid(enemy): continue
		
		var dir_to_enemy = enemy.global_position - player_node.global_position
		var distance = dir_to_enemy.length()
		
		if distance <= world_detection_range:
			if active_blip_index >= enemy_blip_pool.size(): break
			
			var blip_container = enemy_blip_pool[active_blip_index]
			blip_container.visible = true
			
			# 计算基础位置
			var scaled_distance = (distance / world_detection_range) * (current_radius - 4)
			var normalized_dir = dir_to_enemy.normalized()
			var target_pos = center + (normalized_dir * scaled_distance)
			
			# --- 故障艺术效果 (Glitch Effect) ---
			
			# 1. 位置抖动 (Jitter): 每一帧都在基础位置上随机偏移 0.5 到 1 个像素
			# 这会让点看起来不稳定，像信号干扰
			var jitter = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
			blip_container.position = target_pos + jitter
			
			# 2. 辉光闪烁 (Glow Flicker)
			var glow_node = blip_container.get_node("Glow")
			# 随机改变透明度，模拟电压不稳
			glow_node.color.a = randf_range(0.15, 0.35) 
			
			# 3. 噪点跳动 (Pixel Noise)
			var noise_node = blip_container.get_node("Noise")
			# 随机决定噪点是否显示
			if randf() > 0.7:
				noise_node.visible = true
				# 噪点出现在核心周围随机位置
				noise_node.position = Vector2(randf_range(-4, 4), randf_range(-4, 4))
			else:
				noise_node.visible = false
			
			active_blip_index += 1

func _reset_all_blips():
	for blip in enemy_blip_pool:
		blip.visible = false

# --- 新增：Bresenham 像素直线算法 ---
# 这个函数会用 1x1 的小方块一个个“堆”出一条线
func draw_pixel_line(start: Vector2, end: Vector2, color: Color):
	var x0 = int(start.x)
	var y0 = int(start.y)
	var x1 = int(end.x)
	var y1 = int(end.y)
	
	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx - dy
	
	while true:
		# 绘制 1x1 的像素点
		draw_rect(Rect2(x0, y0, 2, 2), color)
		
		if x0 == x1 and y0 == y1: break
		
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x0 += sx
		if e2 < dx:
			err += dx
			y0 += sy
