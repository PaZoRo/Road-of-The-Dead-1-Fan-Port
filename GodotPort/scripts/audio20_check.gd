extends SceneTree

var audio_node:Node
var errors:Array[String]=[]
var capture:AudioEffectCapture

func _initialize():
	call_deferred("run")

func measure(seconds:float) -> Dictionary:
	capture.clear_buffer()
	await create_timer(seconds).timeout
	var frames=capture.get_buffer(capture.get_frames_available())
	var l=0.0;var r=0.0;var peak=0.0
	for frame in frames:
		l+=float(frame.x)*float(frame.x);r+=float(frame.y)*float(frame.y)
		peak=maxf(peak,maxf(absf(frame.x),absf(frame.y)))
	return {"frames":frames.size(),"left_rms":sqrt(l/maxi(1,frames.size())),"right_rms":sqrt(r/maxi(1,frames.size())),"peak":peak}

func run():
	var script=load("res://scripts/audio.gd")
	audio_node=Node.new();audio_node.set_script(script);root.add_child(audio_node)
	await process_frame
	AudioServer.set_bus_volume_db(0,-80)
	capture=AudioEffectCapture.new();capture.buffer_length=2.0
	AudioServer.add_bus_effect(0,capture)
	audio_node.begin_world_frame(0,0)
	audio_node.world_loop("left","CarHornSmall",true,-5,5,-26,"car")
	audio_node.flush_world_frame(1)
	var left=await measure(.8)
	audio_node.stop_action();audio_node.begin_world_frame(0,0)
	audio_node.world_loop("right","CarHornSmall",true,5,5,-26,"car")
	audio_node.flush_world_frame(1)
	var right=await measure(.8)
	audio_node.stop_action();audio_node.begin_world_frame(0,0)
	for i in range(40):audio_node.world_loop("alarm_"+str(i),"CarAlarmSmall",true,0,5+i,-14,"car",4,"alarm")
	audio_node.flush_world_frame(1)
	var crowd=await measure(1.0)
	if left.frames<=0 or right.frames<=0:errors.append("No actual audio samples captured")
	if left.left_rms<=left.right_rms*4 or left.left_rms<.0001:errors.append("Left panning failed")
	if right.right_rms<=right.left_rms*4 or right.right_rms<.0001:errors.append("Right panning failed")
	if audio_node.selected_alarm_channels.size()!=1:errors.append("Alarm overlap cap failed")
	if crowd.peak>.15 or crowd.peak<.0001:errors.append("Crowd alarm peak outside quiet band")
	var report={"left":left,"right":right,"crowd40":crowd,"selected_alarms":audio_node.selected_alarm_channels.size(),"errors":errors}
	var out=FileAccess.open("res://../analysis/release20_audio_capture.json",FileAccess.WRITE)
	out.store_string(JSON.stringify(report,"\t"));out.close()
	print("AUDIO20_CAPTURE: ","PASS" if errors.is_empty() else "FAIL"," ",JSON.stringify(report))
	audio_node.stop_action()
	AudioServer.remove_bus_effect(0,1)
	capture=null
	audio_node.free()
	quit(0 if errors.is_empty() else 1)
