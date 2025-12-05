extends Control

@export var stats : PlayerStats
@export var total_blocks: int = 20 # 设定视觉上的总格数

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	health_bar.max_value = total_blocks # 初始化进度条的最大值为“视觉格数”
	health_bar.step = 1 # 强制每次变化最小为 1 格
	
	stats.health_changed.connect(update_health) # 连接信号
	stats.max_health_changed.connect(update_max_health)
	
	update_health(stats.health) # 初始化显示


func update_health(new_value: float) -> void:
	var percentage = new_value / stats.max_health # 计算血量百分比
	# 核心算法：向上取整计算当前应该显示几格，只要该区间的血量>0，格子就应当显示
	var visible_blocks = ceil(percentage * total_blocks)
	
	if visible_blocks < health_bar.value: # 更新 UI，播放“格子崩解”的动画
		play_damage_effect()
	
	health_bar.value = visible_blocks

func update_max_health(_new_max: float) -> void:
	update_health(stats.health) # 当最大血量改变时，只需要根据当前血量重新计算百分比即可

func play_damage_effect(): # 简单的受击反馈，让进度条稍微变暗或抖动一下
	var tween = create_tween()
	tween.tween_property(health_bar, "modulate", Color.RED, 0.1)
	tween.tween_property(health_bar, "modulate", Color.WHITE, 0.1)
