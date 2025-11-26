extends Node

var player_scene: PackedScene = null # 这里是空的，等待Main场景在游戏启动时注入
# 当前活跃的玩家实例 (强类型)，由Player脚本自己赋值，或者由add_player_instance生成后赋值
var player: Player = null

# 生成玩家的函数，parent：玩家要生在哪个节点，spawn_pos：出生坐标
func add_player_instance(parent: Node, spawn_pos: Vector2) -> Player:
	var new_player = player_scene.instantiate() as Player # 实例化生成新玩家
	new_player.global_position = spawn_pos
	
	# 添加新玩家到场景，add_child会触发_enter_tree,从而自动执行player=self
	parent.add_child(new_player)
	return new_player
