extends SceneTree
func _initialize():
	var a=load("res://scripts/assets.gd").new()
	a.store_texture("anim",16,load("res://assets/flashanim/atlas_16.png"))
	for key in ["garage_bumper","garage_wheel"]:
		var wanted=a.anim_record(key,0)
		var actual=a.ready_anim_record(key,0)
		print("GARAGE25_BASELINE ",key," requested_frame=",wanted.source_frame," drawn_frame=",actual.get("source_frame",-1)," requested_page=",wanted.page," drawn_page=",actual.get("page",-1))
	quit()
