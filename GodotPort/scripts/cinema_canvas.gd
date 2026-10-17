extends Node2D
var renderer
var clip_name="intro"
var frame=0
func _draw():
	if renderer!=null:renderer.draw_clip(self,clip_name,frame,Transform2D(Vector2(1.8,0),Vector2(0,1.8),Vector2.ZERO))
