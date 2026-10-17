extends RefCounted

var data:Dictionary={}
var clips:Dictionary={}
var pages:Dictionary={}
var page_lru:Array=[]

func _init():
	var path="res://assets/native_scene/scenes.json"
	if FileAccess.file_exists(path):data=JSON.parse_string(FileAccess.get_file_as_string(path))

func has_clip(name:String) -> bool:
	return data.get("clips",{}).has(name)

func clip(name:String) -> Dictionary:
	if not clips.has(name):
		if not has_clip(name):return {}
		clips[name]=JSON.parse_string(FileAccess.get_file_as_string("res://assets/native_scene/"+String(data.clips[name].file)))
	return clips[name]

func count(name:String) -> int:
	return int(data.get("clips",{}).get(name,{}).get("length",0))

func draw_clip(canvas:CanvasItem,name:String,frame:int,base:Transform2D,slots:Dictionary={}):
	var c=clip(name)
	if c.is_empty():return
	var seq:Array=c.sequence
	var commands:Array=c.frames[int(seq[posmod(frame,seq.size())])]
	for command in commands:
		var id=int(command[0])
		if id==-1:
			var m:Array=command[2]
			var tr=Transform2D(Vector2(m[0],m[1]),Vector2(m[2],m[3]),Vector2(m[4],m[5]))
			draw_clip(canvas,String(command[1]),int(slots.get(command[1],0)),base*tr)
		elif id==-2:
			canvas.draw_set_transform_matrix(base)
			var rr:Array=command[2]
			var col=Color(String(command[1]))
			col.a*=float(command[3][3])
			canvas.draw_rect(Rect2(rr[0],rr[1],rr[2],rr[3]),col)
		else:
			var a:Dictionary=data.assets[id]
			var ar:Array=a.atlas
			var p=int(ar[0])
			prepare_page(p)
			var m:Array=command[1]
			var tr=Transform2D(Vector2(m[0],m[1]),Vector2(m[2],m[3]),Vector2(m[4],m[5]))
			canvas.draw_set_transform_matrix(base*tr)
			var col:Array=command[2]
			canvas.draw_texture_rect_region(pages[p],Rect2(a.offset[0],a.offset[1],a.size[0],a.size[1]),Rect2(ar[1],ar[2],ar[3],ar[4]),Color(col[0],col[1],col[2],col[3]))
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)

func prepare_page(page: int):
	if not pages.has(page):
		pages[page]=load("res://assets/native_scene/atlas_%d.png"%page)
		if page_lru.size()>=12:pages.erase(page_lru.pop_front())
	page_lru.erase(page);page_lru.append(page)

func prepare_frames(name: String, frame_count: int=30):
	var c=clip(name)
	if c.is_empty():return
	var prepared:Dictionary={}
	for frame in range(mini(frame_count,c.sequence.size())):
		for command in c.frames[int(c.sequence[frame])]:
			var id=int(command[0])
			if id>=0:
				var page=int(data.assets[id].atlas[0])
				if not prepared.has(page):prepare_page(page);prepared[page]=true
			elif id==-1 and not prepared.has(command[1]):
				prepared[command[1]]=true
				prepare_frames(String(command[1]),1)
