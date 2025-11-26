extends Node

# 定义信号：请求切换关卡
# next_scene_path：下一个关卡的文件路径；target_point_name：玩家出生的节点名
signal level_change_requested(next_scene_path: String, target_point_name: String)

# 提供一个公共函数给LevelTransition调用
func request_level_change(scene_path: String, point_name: String) -> void:
	# 发射信号：Main场景会听到这个信号并处理
	level_change_requested.emit(scene_path, point_name)
