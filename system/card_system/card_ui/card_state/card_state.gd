# 所有其他的特定状态都从此脚本继承而来
class_name CardState
extends Node

# 该枚举将包含卡片可能处于的所有状态
enum State {BASE, CLICKED, DRAGGING, AIMING, RELEASED}

#带有两个参数，即从哪个状态转换以及转换到哪个状态
signal transition_requested(from: CardState, to: State)

# 提供一个导出变量，以便在编辑器中为节点分配状态
@export var state: State

# 引用CardUI节点，以便在状态脚本内部执行诸如移动卡片，改变颜色或ColorRect、更新标签等各种操作
var card_ui: CardUI


# enter和exit函数，会在进入新状态或退出状态时调用
func enter() -> void:
	pass

func exit() -> void:
	pass

# 两个可供状态使用的回调函数input和guiinput，分别传入相应的输入事件作为参数
func on_input(_event: InputEvent) -> void:
	pass

func on_gui_input(_event: InputEvent) -> void:
	pass

# on_mouse_entered和exited回调，同上
func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass
