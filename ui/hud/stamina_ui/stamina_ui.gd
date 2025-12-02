extends Control

@export var stats: PlayerStats # UI直接和数据连接，不需要知道Player在哪里

@onready var stamina_bar: TextureProgressBar = $StaminaBar

func _ready() -> void:
	stamina_bar.max_value = stats.max_stamina # 初始化最大值和当前值
	stamina_bar.value = stats.stamina 
	
	stats.stamina_changed.connect(update_stamina) # 连接信号：当stats的stamina变了，更新数值

func update_stamina(new_amount: float) -> void: # 更新当前耐力值
	stamina_bar.value = new_amount
	var tween = create_tween() # 创建一个动画补间，做平滑过渡
	tween.tween_property(stamina_bar, "value", new_amount, 0.1) # 在0.1秒内将value属性变为new_amount
