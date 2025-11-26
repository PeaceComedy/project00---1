extends CardState

# 首先，由于这是初始状态，所以需要检查CardUI节点是否已经在场景树中准备完毕
func enter() -> void:
	# 如果没有准备好，需要等待CardUI节点准备好
	if not card_ui.is_node_ready():
		await card_ui.ready
	# 因为根据节点层级结构，会发现基础状态节点远在CardUI节点之下
	# Godot引擎的工作方式是：子节点首先完成准备，只有当所有子节点都准备好了，父节点才能完成准备
	# 理论上讲，可能会在CardUI节点还没准备好时，就进入了基础状态

	# 重新父化
	# 如果取消移动操作，可以从拖拽状态回到基础状态，如果取消了移动，需要将卡片迅速放回到HBox容器中
	card_ui.reparent_requested.emit(card_ui)
	# 为了调试目的，更改卡片的颜色和文本内容
	card_ui.color.color = Color.WEB_GREEN
	card_ui.state.text = "BASE"
	# 重置卡片的旋转中心偏移量，旋转中心偏移量会在拖动卡片时发挥作用，进入基础状态时其重置为0
	card_ui.pivot_offset = Vector2.ZERO
	# 不希望在拖动卡片时，其左上角紧贴鼠标光标，而是在点击的位置跟随鼠标移动，为此需要设置旋转中心偏移量

# 处理GUI输入事件
func on_gui_input(event:InputEvent)-> void:
	# 在基础状态下按下左鼠标按钮时，才能从基础状态过渡到点击状态
	if event.is_action_pressed("left_mouse"):
		# 计算旋转中心偏移量，鼠标相对于卡片左上角的局部坐标 = 鼠标在当前窗口中的全局坐标 - 卡片在窗口中的全局坐标
		card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		# 发出一个状态转换请求信号给状态机，以便从当前状态过渡到点击状态
		transition_requested.emit(self, CardState.State.CLICKED)
