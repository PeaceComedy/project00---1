extends Panel


@onready var icon: TextureRect = $Icon

func display_item(item: Item): # 用于刷新这个格子显示的函数
	if item:
		icon.texture = item.icon
		icon.visible = true
	else:
		icon.texture = null
		icon.visible = false
