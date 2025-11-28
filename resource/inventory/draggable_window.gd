extends Panel

var dragging = false
var drag_start_position = Vector2.ZERO

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP # 确保鼠标能检测到这个窗口

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: # 鼠标按下，开始拖拽
				dragging = true
				drag_start_position = get_global_mouse_position() - global_position
			else: # 鼠标松开，停止拖拽
				dragging = false
		
	elif event is InputEventMouseMotion and dragging: # 鼠标移动且处于拖拽状态，更新窗口位置
		global_position = get_global_mouse_position() - drag_start_position
