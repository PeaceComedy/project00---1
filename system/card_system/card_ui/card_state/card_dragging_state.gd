extends CardState

# 拖动状态中经过的最小时间间隔
const  DRAG_MINIMUM_THRESHOLD := 0.05
# 标志位用于判断是否超过最小拖拽时间
var minimum_drag_time_elapsed := false

# 进入dragging状态所需要做的全部工作
func enter() -> void:
	# 将该节点存储在一个变量中以确保我们可以检查是否存在这样一个节点
	var ui_layer := get_tree().get_first_node_in_group("ui_layer")
	# 如果找到了这样的节点，就可以将"card_ui”重新父化到ui_layer节点下
	if ui_layer:
		card_ui.reparent(ui_layer)
	
	# 为了便于调试，更改卡片的颜色和文本内容
	card_ui.color.color = Color.NAVY_BLUE
	card_ui.state.text = "DRAGGING"

	# 判断是否超过最小拖拽时间
	minimum_drag_time_elapsed = false
	# 定时器将持续我们指定的时间长度，要注意需要将第二个参数设置为false
	# 保证在默认情况下，createtimer创建的定时器，在SceneTree暂停时也会随之暂停
	var threshold_timer := get_tree().create_timer(DRAG_MINIMUM_THRESHOLD, false)
	# 对于这个定时器的超时信号，连接一个匿名函数，在其中将标志位改为true
	threshold_timer.timeout.connect(func():minimum_drag_time_elapsed = true)

# 根据发生的情况，转换至释放状态或返回基础状态，为此将使用on_input回调函数
func on_input(event: InputEvent) -> void:
	# 首先，设置一个名为mouse_motion的标志位，当发生的输入事件是InputEventMouseMotion时，其值为真
	var mouse_motion := event is InputEventMouseMotion
	# 然后，设置—个名为cancel的标志位，仅当通过按下右键取消拖动操作时，其值才为真
	var cancel = event.is_action_pressed("right_mouse")
	# 此外，还有一个用于在确认动作时设置的标志位，因为这时或是再次按下左键，或是释放左键，这意味着卡片应该进入释放状态
	var confirm = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
	
	# 若发生了鼠标移动，需要更新卡片的全局位置，使其跟随鼠标光标移动
	if mouse_motion:
		# 卡片全局位置 = 鼠标在当前窗口中的全局坐标 - 鼠标相对于卡片左上角的局部坐标
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.pivot_offset

	# 如果取消了拖拽操作，则请求从拖拽状态回到基础状态
	if cancel:
		transition_requested.emit(self, CardState.State.BASE)
	# 否则，如果确认拖拽操作，即释放了左键或再次按下左键
	elif minimum_drag_time_elapsed and confirm:
		# 先将输入标记为已处理，以免意外地立即拾取新的卡片
		get_viewport().set_input_as_handled()
		# 然后，请求从拖拽状态切换到释放状态
		transition_requested.emit(self, CardState.State.RELEASED)
