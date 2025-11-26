extends CardState
# 作为一个标志位，用于记录是否已经打出这张牌
var played: bool

func enter() -> void:
	# 为了便于调试，更改卡片的颜色和文本内容
	card_ui.color.color = Color.DARK_VIOLET
	card_ui.state.text = "RELEASED"
	# 进入”已释放”状态时，还没有打出这张牌
	played = false
	# 检查在card_UI中，定义的目标数组是否为空
	if not card_ui.targets.is_empty():
		# 如果不为空，说明有一个有效目标，意味着当前该例，正将鼠标悬停在牌的放置区域上
		# 改变标志位状态，并打印调试信息
		played = true
		print("play card for target(s)", card_ui.targets)

# 在输入回调函数中检查我们是否已经打出过这张牌
func on_input(_event: InputEvent) -> void:
	# 如果已经打出了牌，就直接返回
	if played:
		return
	# 如果还没有打出牌，并且接收到输入，这意味着当前没有有效目标，应该立即回到基础状态
	transition_requested.emit(self, CardState.State.BASE)
