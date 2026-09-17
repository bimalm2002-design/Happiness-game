extends Camera3D

enum State { OVERVIEW, FOLLOW }
var current_state = State.OVERVIEW

var overview_pos = Vector3(0, 15, 0) # Scaled up top-down view (closer)
var overview_rot = Vector3(-90, 0, 0) # Straight down (reverted)

var follow_offset = Vector3(0, 6, 6) # Closer to avatar
var follow_rot = Vector3(-45, 0, 0) # Classic isometric-ish follow

@onready var avatar = get_node_or_null("../RatAvatar")
var tween: Tween

func _ready():
	position = overview_pos
	rotation_degrees = overview_rot

func set_state(new_state):
	if current_state == new_state:
		return
	current_state = new_state
	
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween().set_parallel(true)
	
	if current_state == State.OVERVIEW:
		tween.tween_property(self, "position", overview_pos, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation_degrees", overview_rot, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	elif current_state == State.FOLLOW:
		if avatar:
			var target_pos = avatar.position + follow_offset
			tween.tween_property(self, "position", target_pos, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rotation_degrees", follow_rot, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _process(delta):
	if current_state == State.FOLLOW and avatar:
		if tween == null or not tween.is_running():
			var target_pos = avatar.position + follow_offset
			position = position.lerp(target_pos, delta * 5.0)
