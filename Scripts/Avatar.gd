extends Node3D

signal move_finished()

var current_index = 0

@onready var rig = $Rig
@onready var l_leg = $Rig/LeftLegPivot
@onready var r_leg = $Rig/RightLegPivot
@onready var l_arm = $Rig/LeftArmPivot
@onready var r_arm = $Rig/RightArmPivot
@onready var tail = $Rig/TailPivot

func move_spaces(count: int, board_nodes: Array):
	for i in range(count):
		var next_index = (current_index + 1) % board_nodes.size()
		var target_pos = board_nodes[next_index].position
		target_pos.y = 0.05
		
		# Rotate avatar to face direction
		var dir = (target_pos - position).normalized()
		if dir.length() > 0.1:
			var target_rotation_y = atan2(dir.x, dir.z)
			var r_tw = create_tween()
			r_tw.tween_property(self, "rotation:y", target_rotation_y, 0.2)
		
		var tw = create_tween().set_parallel(true)
		var peak_pos = (position + target_pos) / 2.0
		peak_pos.y += 0.5 # Small hop while walking
		
		tw.tween_property(self, "position", peak_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(0.2)
		
		# Walk Animation (Swinging arms and legs)
		if l_leg and r_leg and l_arm and r_arm:
			var swing = deg_to_rad(30)
			# Step 1
			tw.tween_property(l_leg, "rotation:x", swing, 0.1)
			tw.tween_property(r_leg, "rotation:x", -swing, 0.1)
			tw.tween_property(l_arm, "rotation:x", -swing, 0.1)
			tw.tween_property(r_arm, "rotation:x", swing, 0.1)
			if tail:
				tw.tween_property(tail, "rotation:y", swing, 0.1)
				
			# Step 2
			tw.tween_property(l_leg, "rotation:x", -swing, 0.2).set_delay(0.1)
			tw.tween_property(r_leg, "rotation:x", swing, 0.2).set_delay(0.1)
			tw.tween_property(l_arm, "rotation:x", swing, 0.2).set_delay(0.1)
			tw.tween_property(r_arm, "rotation:x", -swing, 0.2).set_delay(0.1)
			if tail:
				tw.tween_property(tail, "rotation:y", -swing, 0.2).set_delay(0.1)
				
			# Reset
			tw.tween_property(l_leg, "rotation:x", 0.0, 0.1).set_delay(0.3)
			tw.tween_property(r_leg, "rotation:x", 0.0, 0.1).set_delay(0.3)
			tw.tween_property(l_arm, "rotation:x", 0.0, 0.1).set_delay(0.3)
			tw.tween_property(r_arm, "rotation:x", 0.0, 0.1).set_delay(0.3)
			if tail:
				tw.tween_property(tail, "rotation:y", 0.0, 0.1).set_delay(0.3)
		
		await get_tree().create_timer(0.4).timeout
		current_index = next_index
		
	emit_signal("move_finished")
