extends Control

@export var stats : PlayerStats

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	health_bar.max_value = stats.max_health # 初始化最大值和当前值
	health_bar.value = stats.health

	stats.health_changed.connect(update_health)
	stats.max_health_changed.connect(update_max_health)


func update_health(new_value: float) -> void: # 更新当前血量
	health_bar.value = new_value
	var tween = create_tween() # 平滑扣血效果
	tween.tween_property(health_bar, "value", new_value, 0.2)

func update_max_health(new_max: float) -> void: # 更新血量上限
	health_bar.max_value = new_max
