class_name Hand
extends HBoxContainer


func _ready() -> void:
	# 历遍所有的子节点
	for child in get_children():
		var card_ui := child as CardUI
		card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
		
# 将CardUI重新父化到自身
func _on_card_ui_reparent_requested(child: CardUI) -> void:
		child.reparent(self)
