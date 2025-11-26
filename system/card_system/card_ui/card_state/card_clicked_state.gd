extends CardState


func enter() -> void:
	# 为了便于调试，更改卡片的颜色和文本内容
	card_ui.color.color = Color.ORANGE
	card_ui.state.text = "CLICKED"
	# 在卡片UI的放置点检测器上，启用监控功能
	card_ui.drop_point_detector.monitoring = true
	# 因为在真正点击卡片时，也就是开始与卡片交互的时候
	# 因此，当开始与卡片互动时，需要确保放置点检测器正在监控状态，以便检查卡片与目标区域的碰撞情况

func on_input(event: InputEvent) -> void:
	# 如果该事件是鼠标运动类型
	if event is InputEventMouseMotion:
		# 那么可以请求从这个点击状态切换到拖拽状态
		transition_requested.emit(self, CardState.State.DRAGGING)
