pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


function pnearq(p,q)
 return abs(p[1]-q[1])<2 and
        abs(p[2]-q[2])<2
end

function drag_verts()
 if dragpt==nil then
  overpt=false
  for p in all(verts) do
   if pnearq(p,{mx,my}) then
	   if lmdown() then
	    dragpt=p
	    dragstrtx=mx-p[1]
	    dragstrty=my-p[2]
	   end
	   overpt=true
	  end
	 end
	 if overpt then
   mouse_cursor=2
  else
   mouse_cursor=1
	 end
	else
	 if lmup() then
	  dragpt=nil
	 else
	  dragpt[1]=mx-dragstrtx
	  dragpt[2]=my-dragstrty
	  mouse_cursor=3
	 end
	end
end


function init_default_data()
	verts={
	 {66,64}, 
	 {64,72}, 
	 {66,80},
	}
	lines={
	 {1,2}, 
	 {2,3},
	}
	vframes={verts}
	lframes={lines}
	frame=1
end


function _init()
 init_mouse()
 
 
 --set before calling dset/dget
 cartdata("pv_anim_tool")
 
 if dget2(0)==0 then
  init_default_data()
 else
  load_anim_data()
 end
 
end

function _update()
 
 -- keyboard input
 if stat(30)==true then
		c=stat(31)
		
		if c=="s" then
 		save_anim_data()
		end
		if c=="r" then
		 init_default_data()
		end
		
		if c=="a" then
			add(vframes,copy(vframes[frame]))
			add(lframes,copy(lframes[frame]))
		end
		if c=="d" then
			del(vframes,vframes[frame])
			del(lframes,lframes[frame])
		end
		
		if c=="z" then
			frame-=1
		end
		if c=="x" then
			frame+=1
		end
		
 end
 if (not frame) frame=1
	if (frame<=0) frame=#vframes
	if (frame>#vframes) frame=1
 
 --update vert/line lists
	verts=vframes[frame]
	lines=lframes[frame]
	
	
	-- drag current frame verts
 mx,my=get_mouse()
 drag_verts()
	
 
 cache_mouse_state()
end

function _draw()
 cls()
 
 
 for l in all(lines) do
  p1=verts[l[1]]
  p2=verts[l[2]]
  line(p1[1],p1[2],p2[1],p2[2],7)
 end
 for p in all(verts) do
  pset(p[1],p[2],9)
 end
 
 
 spr(mouse_cursor,mx-2,my)
 
 
 for i=1,#vframes do
  rectfill2(10+i*5,4, 4,4, 13)
  if i==frame then
   rectfill2(11+i*5,9, 2,2, 7)
  end
 end
 
 --view saved data
 for i=1,0x5eff-0x5e00 do
  d=dget2(i)
  if (d==0) d=15
  pset(i%64,90+i/64,d)
 end

end
-->8

--mouse down coords
mdx=0
mdy=0
mdrag = false

-- middle or even right mouse
-- clicks might be iffy on web?
lmwasdown=false
rmwasdown=false
mmwasdown=false

function init_mouse()
 poke(0x5f2d, 1) --enable mouse
end

function get_mouse()
 return stat(32)-1, stat(33)-1
end

--call this at end of update for mup/mdown to work
function cache_mouse_state()
 --for mouse edge triggers
 lmwasdown=lmouse()
	rmwasdown=rmouse()
	mmwasdown=mmouse()
end

function nmouse() return stat(34)==0 end
function lmouse() return stat(34)==1 end
function rmouse() return stat(34)==2 end
function mmouse() return stat(34)==4 end

function lmup() return not lmouse() and lmwasdown end
function rmup() return not rmouse() and rmwasdown end
function mmup() return not mmouse() and mmwasdown end

function lmdown() return lmouse() and not lmwasdown end
function rmdown() return rmouse() and not rmwasdown end
function mmdown() return mmouse() and not mmwasdown end

--can delete
function debug_print_mouse()
 print(mx)
 print(my)
 print("lmup"..tostr(lmup()))
 print("lmdown"..tostr(lmdown()))
 print("lmouse"..tostr(lmouse()))
end

--camera pan
function mouse_pan()
 mx,my=get_mouse()
 --mwheel drag
 if mmdown() then
  camdrag=true
  camclickworldx=mx+cx
  camclickworldy=my+cy
 end
 if mmouse() then
  if camdrag then
   cx=camclickworldx-mx
   cy=camclickworldy-my
  end
 end
 if mmup() then
  camdrag=false
 end
-- mx-=cx
-- my-=cy
 cache_mouse_state() --or call after this function
end

--drag object
function mouse_drag(obj)
 if (obj==nil or obj[1]==nil or obj[2]==nil) return
 mx,my=get_mouse()
 --left button
 if lmdown() then
  objdrag=true
  dragstartx=obj[1]-mx
  dragstarty=obj[2]-my
 end
 if lmouse() then
  if objdrag then
   obj[1]=dragstartx+mx
   obj[2]=dragstarty+my
  end
 end
 if lmup() then
  objdrag=false
 end
 cache_mouse_state() --or call after this function
end

-->8
--util


function line2(x,y,w,h,c)
 line(x,y,x+w,y+h,c)
end


function rectfill2(x,y,w,h,c)
 if w>0 and h>0 then
  rectfill(x,y,x+w-1,y+h-1,c)
 end
end


--recursive deep copy
--works on non-tables too
function copy(o)
 local c
 if type(o) == 'table' then
  c = {}
  for k, v in pairs(o) do
   c[k] = copy(v)
  end
  else
   c = o
 end
 return c
end
-->8
--save/load anim data



function dget2(index)
 return peek(0x5e00+index)
end
function dset2(index,val)
 poke(0x5e00+index,val)
end


function load_anim_data()
 
 framecount = dget2(0)
 vertcount = dget2(1)
 linecount = dget2(2)
 read=3
 
 vframes={}
 lframes={}
 for f=1,framecount do
 
  newverts={}
  for v=1,vertcount do
   x=dget2(read)
   read+=1
   y=dget2(read)
   read+=1
   add(newverts,{x,y})
  end
  add(vframes,newverts)
  
  newlines={}
  for l=1,linecount do
   x=dget2(read)
   read+=1
   y=dget2(read)
   read+=1
   add(newlines,{x,y})
  end
  add(lframes,newlines)
  
 end
 
end


function save_anim_data()
 
 framecount = dset2(0,#vframes)
 vertcount = dset2(1,#verts)
 linecount = dset2(2,#lines)
 write=3
 
 for f=1,#vframes do
  vframe=vframes[f]
  for v in all(vframe) do
   dset2(write,v[1])
   write+=1
   dset2(write,v[2])
   write+=1
  end
  lframe=lframes[f]
  for l in all(lframe) do
   dset2(write,l[1])
   write+=1
   dset2(write,l[2])
   write+=1
  end
 end
 
end
__gfx__
00000000007000000171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000011000001d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700001d100001d1111001111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000001dd10011dddd1111d1d1d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000001ddd10d1ddddd11dddddd1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700001dddd1ddddddd11dddddd1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001dd11011dddd1111dddd11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001110000111111001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
