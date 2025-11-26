# 创建CardState状态机本身
class_name CardStateMachine
extends Node

# 导出变量，用于存储状态机的初始或起始状态
@export var initial_state: CardState

# 存储当前所在状态
var current_state: CardState
# 字典用于存储状态机中所有可用的状态
var states := {}

# init函数将在CardUI中被调用
func init(card: CardUI) -> void:
	# 首先，遍历状态机的所有子节点
	for child in get_children():
		# 检查当前子节点是否为CardState类型
		# 如果是CardState类型
		if child is CardState:
			# 就将其添加到拥有的所有状态的字典中
			states[child.state] = child
			# 并连接到自己的函数来处理状态转换请求的信号
			child.transition_requested.connect(_on_transition_requested)
			# 同时，将CardUI引用传递给状态本身
			child.card_ui =card
	# 接着，如果有初始状态，就进入该状态，并将当前状态设置为起始或初始状态
	if initial_state:
		initial_state.enter()
		current_state = initial_state

# 两个用于输入事件和GUI输入事件的回调函数
# 检查是否有当前状态，如果有激活的当前状态，可以调用该状态对应的回调函数
func on_input(event:InputEvent)->void:
	if current_state:
		current_state.on_input(event)
		
func on_gui_input(event:InputEvent) ->void:
	if current_state:
		current_state.on_gui_input(event)

# 对于on_mouse_entered和exited回调，也做同样的处理
func on_mouse_entered() -> void:
	if current_state:
		current_state.on_mouse_entered()

func on_mouse_exited() -> void:
	if current_state:
		current_state.on_mouse_exited()

# 处理一个状态到另一个状态的转换
func _on_transition_requested(from:CardState,to:CardState.State)->void:
	# 首先，要检查的是from状态和当前状态是否相等
	# 因为如果两个状态不匹配，那么说明发生了严重错误，需要立即从这个函数中返回
	if from != current_state:
		return
	
	# 之后，从状态字典中获取新状态的引用
	var new_state: CardState = states[to]
	# 如果出于某种原因，在字典中没有找到这些状态，需要再次从函数中返回
	if not new_state:
		return
	
	# 但如果新状态确实存在，则需要先退出当前状态（如果先前正处于某个状态）
	if current_state:
		current_state.exit()
	
	# 最后，可以进入新状态，并将当前状态设置为这个新状态
	new_state.enter()
	current_state = new_state
