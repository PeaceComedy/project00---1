class_name Inventory
extends Resource

@export var items: Array[Item] = [] # 作为数组，里面只能存 Item 类型的资源

func add_item(item: Item): # 增加物品
	items.append(item)
	print("获得了物品: " + item.name)
