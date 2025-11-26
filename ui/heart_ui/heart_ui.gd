extends Control

@export var player_stats : Stats

@onready var empty_heart: TextureRect = $EmptyHeart
@onready var full_heart: TextureRect = $FullHeart

func _ready() -> void:
	player_stats.health_changed.connect(set_full_heart)
	set_empty_heart(player_stats.max_health)
	set_full_heart(player_stats.health)

func set_empty_heart(value:int)-> void:
	empty_heart.size.x = value * 15
	
func set_full_heart(value: int)-> void:
	full_heart.size.x = value * 15
