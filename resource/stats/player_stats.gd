class_name PlayerStats
extends Stats

signal stamina_changed(new_stamina)

@export var max_stamina := 100.0 # 最大耐力值
var stamina := 100.0: # 当前耐力值
	set(value):
		stamina = clamp(value, 0, max_stamina) # “钳制”函数，确保值大于0小于最大值，防止负数或溢出
		stamina_changed.emit(stamina) # 修改完数值后，立刻发射信号，通知外部更新数值

@export var stamina_regen_rate := 10.0 # 耐力恢复率


func process_stamina_regen(delta: float): # 定义函数：只要每帧调用这个方法，角色就能自动回耐力，物理处理
	if stamina < max_stamina: # 如果当前耐力还没满，才进行恢复
		self.stamina += stamina_regen_rate * delta # 计算一帧恢复多少点，累加到当前耐力值上
		# 写self会强制触发上面定义的set(value)函数，不加则可能会绕过Setter，导致不钳制范围，也不发出信号通知外部更新
