extends SceneTree
func _init():
	for name in ["AudioEffectLimiter","AudioEffectHardLimiter","AudioEffectCapture"]:
		if not ClassDB.class_exists(name):continue
		var x=ClassDB.instantiate(name)
		for p in x.get_property_list():
			if p.usage & PROPERTY_USAGE_EDITOR:print(name," ",p.name,"=",x.get(p.name))
	print("LATENCY ",ProjectSettings.get_setting("audio/driver/output_latency"))
	quit()
