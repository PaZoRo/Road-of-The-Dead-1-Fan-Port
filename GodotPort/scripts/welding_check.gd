extends SceneTree
var errors: Array=[]
func check(ok: bool,message: String):
	if not ok:errors.append(message);push_error(message)
func _initialize():
	call_deferred("verify")
func verify():
	root.size=Vector2i(1080,720)
	root.content_scale_size=Vector2i(1080,720)
	var renderer=load("res://scripts/native_scene.gd").new()
	var clip=renderer.clip("intro")
	var expected=JSON.parse_string(FileAccess.get_file_as_string("res://assets/native_scene/welding_reflection.json"))
	var aid=int(renderer.data.welding_reflection.asset)
	var alpha_values: Dictionary={}
	for row in expected:
		var found=false
		for command in clip.frames[int(clip.sequence[int(row.frame)])]:
			if int(command[0])!=aid:continue
			found=true
			check(is_equal_approx(command[2][3],row.alpha),"original reflection alpha at frame "+str(row.frame))
			alpha_values[row.alpha]=true
		check(found,"reflection exists at source frame "+str(row.source_frame))
	check(expected.size()==166 and alpha_values.size()==36,"complete original welding flicker timeline")
	for frame in [225,392,500,720]:
		for command in clip.frames[int(clip.sequence[frame])]:
			check(int(command[0])!=aid,"reflection absent outside welding shot")
	var atlas=renderer.data.assets[aid].atlas
	renderer.prepare_page(int(atlas[0]))
	var tex: Texture2D=renderer.pages[int(atlas[0])]
	var pixels=tex.get_image()
	check(pixels.get_size()==Vector2i(481,530),"unmodulated reflection texture is packaged")
	var canvas=Node2D.new()
	canvas.set_script(load("res://scripts/cinema_canvas.gd"))
	canvas.renderer=renderer
	root.add_child(canvas)
	var capture_dir=ProjectSettings.globalize_path("res://../analysis") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().path_join("../analysis")
	for frame in [226,240,246,251,280,302,360,391,392]:
		canvas.frame=frame;canvas.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(capture_dir.path_join("welding13_%04d.png"%frame))==OK,"capture welding frame")
	# Play the complete shot on its original 30 fps clock.
	var start=Time.get_ticks_msec()
	var previous=-1
	while Time.get_ticks_msec()-start<5700:
		var frame=226+int((Time.get_ticks_msec()-start)*30.0/1000)
		canvas.frame=frame
		if frame!=previous:canvas.queue_redraw();previous=frame
		await process_frame
	check(previous>=392,"playback advances beyond welding into next shot")
	print("WELDING_CHECK: ","PASS" if errors.is_empty() else "FAIL"," ",errors)
	quit(0 if errors.is_empty() else 1)
