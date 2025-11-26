class_name CardUI
extends Control

# 在开始拖拽卡片时，需要将卡片从HBox容器中重新父化，否则它会受限于其边界框内
signal reparent_requested(which_card_ui: CardUI) 

# 初始化变量
@onready var color: ColorRect = $Color
@onready var state: Label = $State
# 
@onready var drop_point_detector: Area2D = $DropPointDetector
# 在卡片UI中引用到卡片状态机自身，使用as关键字将onready变量转换为CardStateMachine类型
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
# 定义一个节点数组，用于存储卡片的所有当前目标
@onready var targets: Array[Node] = []

# 将卡片UI自身作为参数传递过去
func _ready()-> void:
	card_state_machine.init(self)

func _input(event:InputEvent) ->void:
	card_state_machine.on_input(event)

# 下面三个回调函数继承自CardStateMachine
func _on_gui_input(event:InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func _on_mouse_entered()-> void:
	card_state_machine.on_mouse_entered()

func _on_mouse_exited()->void:
	card_state_machine.on_mouse_exited()

# 当我们某个区域，即悬停在卡片投放区域时
func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	# 检查目标数组是否已经包含这个区域。如果没有，就将基添加到当前目标列表中
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	targets.erase(area)
