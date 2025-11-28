class_name Inventory
extends Resource

signal inventory_changed # 定义信号：当背包内容改变时触发

@export var items: Array[Item] = [] # 作为数组，里面只能存 Item 类型的资源

func add_item(item: Item): # 增加物品
	items.append(item)
	inventory_changed.emit()
