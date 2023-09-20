extends MarginContainer


var scroll_top = false
var scroll_bottom = false
var scroll_left = false
var scroll_right = false

var scroll_speed = 400
var size = Global.game_conf.WORLD_CONF.MAP_CONF.SIZE

var scroll_child = null


# Called when the node enters the scene tree for the first time.
func _ready():
	#scroll_child.position = rect_size * 0.5 - size * 0.5
	pass


func init(scroll_child_in):
	scroll_child = scroll_child_in
	scroll_child.position = rect_size * 0.5 - size * 0.5


func center_position(pos):
	scroll_child.position = - pos + rect_size * 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scroll_child==null:
		return
	
	if scroll_top:
		scroll_child.position.y = min(0, scroll_child.position.y + scroll_speed * delta)
	if scroll_bottom:
		scroll_child.position.y = max(-size.y + rect_size.y, scroll_child.position.y - scroll_speed * delta)
	if scroll_left:
		scroll_child.position.x = min(0, scroll_child.position.x + scroll_speed * delta)
	if scroll_right:
		scroll_child.position.x = max(-size.x + rect_size.x, scroll_child.position.x - scroll_speed * delta)


func _on_ButtonTop_mouse_entered():
	print("WorldScroller._on_ButtonTop_mouse_entered")
	scroll_top = true


func _on_ButtonTop_mouse_exited():
	#print("WorldScroller._on_ButtonTop_mouse_exited")
	scroll_top = false


func _on_ButtonBottom_mouse_entered():
	#print("WorldScroller._on_ButtonBottom_mouse_entered")
	scroll_bottom = true


func _on_ButtonBottom_mouse_exited():
	#print("WorldScroller._on_ButtonBottom_mouse_exited")
	scroll_bottom = false


func _on_ButtonLeft_mouse_entered():
	#print("WorldScroller._on_ButtonLeft_mouse_entered")
	scroll_left = true


func _on_ButtonLeft_mouse_exited():
	#print("WorldScroller._on_ButtonLeft_mouse_exited")
	scroll_left = false


func _on_ButtonRight_mouse_entered():
	#print("WorldScroller._on_ButtonRight_mouse_entered")
	scroll_right = true


func _on_ButtonRight_mouse_exited():
	#print("WorldScroller._on_ButtonRight_mouse_exited")
	scroll_right = false


func _on_ButtonTopLeft_mouse_entered():
	#print("WorldScroller._on_ButtonTopLeft_mouse_entered")
	scroll_left = true
	scroll_top = true


func _on_ButtonTopLeft_mouse_exited():
	#print("WorldScroller._on_ButtonTopLeft_mouse_exited")
	scroll_left = false
	scroll_top = false


func _on_ButtonTopRight_mouse_entered():
	#print("WorldScroller._on_ButtonTopRight_mouse_entered")
	scroll_right = true
	scroll_top = true


func _on_ButtonTopRight_mouse_exited():
	#print("WorldScroller._on_ButtonTopRight_mouse_exited")
	scroll_right = false
	scroll_top = false


func _on_ButtonBottomLeft_mouse_entered():
	#print("WorldScroller._on_ButtonBottomLeft_mouse_entered")
	scroll_left = true
	scroll_bottom = true


func _on_ButtonBottomLeft_mouse_exited():
	#print("WorldScroller._on_ButtonBottomLeft_mouse_exited")
	scroll_left = false
	scroll_bottom = false


func _on_ButtonBottomRight_mouse_entered():
	#print("WorldScroller._on_ButtonBottomRight_mouse_entered")
	scroll_right = true
	scroll_bottom = true


func _on_ButtonBottomRight_mouse_exited():
	#print("WorldScroller._on_ButtonBottomRight_mouse_exited")
	scroll_right = false
	scroll_bottom = false




























