extends Node2D

@onready var player_spawn: Node2D = $PlayerSpawn

func _ready():
	var spawn_pos = player_spawn.global_position # 在重生点位置生成玩家实例
	GlobalPlayerManager.add_player_instance(self, spawn_pos) 
