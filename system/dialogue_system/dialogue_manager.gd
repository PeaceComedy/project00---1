extends Control

@export_group("UI")
# 引用对话UI里的部分组件，对应控制对话角色的名称
@export var character_name_text : Label
# 对应对话内容的文本框
@export var text_box : Label
# 对应角色头像框
@export var left_avatar : TextureRect
@export var right_avatar : TextureRect

@export_group("Dialogue")
# 对应会在UI里显示的对话资源
@export var main_dialogue : DialogueGroup

# 定义对话计数器，用来显示当前是对话组内的第几条对话
var dialogue_index := 0 # 使用:=方便后续被其他方法赋值并返回
# 定义文本打字机的动画效果
var typing_tween : Tween


# 定义追加文本字符的方法
func append_character(character : String):
	text_box.text += character

# 定义执行对话主流程的方法
func display_next_dialogue():
	# 如果当前的对话计数器数字，大于对话组内总元素数，停止显示内容
	if dialogue_index >=len(main_dialogue.dialogue_list):
		visible = false
		return
	
	# 获取对话数据。如果[]内为n，就获取[]内第n+1条的数据
	# 加“:”表示，推断声明dialogue的变量类型为dialogue的同类型
	var dialogue := main_dialogue.dialogue_list[dialogue_index]
	
	# 如果当前打字机动画存在，并且正在运行
	if typing_tween and typing_tween.is_running():
		# 中止打字机动画运行，直接展示完整文本内容，并且对话索引加1，准备显示下一条对话
		typing_tween.kill()
		text_box.text = dialogue.content
		dialogue_index += 1
	
	# 否则，执行文本显示动画
	else:
		# 让character_name_text的角色名，显示为当前对应的对话数据里的角色名
		character_name_text.text = dialogue.character_name
		
		# 让text_box的文本内容，显示为当前对话数据里的文本内容
		# 创建tween，并保留在变量中
		typing_tween = get_tree().create_tween()
		# 先清空text_box内容
		text_box.text = ""
		# 循环对话内容中的每一个字符
		for character in dialogue.content:
			# 让tween执行append_character函数,并且将字符绑定到当前内容后面，字符之间延迟0.05秒
			typing_tween.tween_callback(append_character.bind(character)).set_delay(0.05)
		# 将对话索引加1，准备显示下一条对话
		typing_tween.tween_callback(func():dialogue_index +=1)
		
		# 头像显示位置左右判断
		if dialogue.show_on_left:
			left_avatar.texture = dialogue.avatar
			right_avatar.texture = null
		else:
			left_avatar.texture = null
			right_avatar.texture = dialogue.avatar

# 执行对话主流程
func _ready():
		display_next_dialogue()

# 鼠标点击控制对话推进
func _on_click(event: InputEvent) :
	# 如果鼠标单击按下左键时，触发执行对话的主流程
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		display_next_dialogue()
