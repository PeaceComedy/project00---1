extends Control

@export var stats: PlayerStats
@export var total_blocks: int = 20 # 设定视觉上的总格数

@onready var stamina_bar: TextureProgressBar = $StaminaBar

func _ready() -> void:
	stamina_bar.max_value = total_blocks # 初始化进度条设置为“格子模式”
	stamina_bar.step = 1 # 强制整数步进，确保不会显示半个格子
	
	update_stamina(stats.stamina) # 初始化显示
	
	stats.stamina_changed.connect(update_stamina) # 连接信号


func update_stamina(new_amount: float) -> void:
	# 核心算法：向上取整 (Ceil)，只有当这一个“块”内的耐力完全耗尽，格子才会消失
	var percentage = new_amount / stats.max_stamina
	var visible_blocks = ceil(percentage * total_blocks)
	
	stamina_bar.value = visible_blocks # 赋值
	
