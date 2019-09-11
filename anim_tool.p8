pico-8 cartridge // http://www.pico-8.com
version 18
__lua__




parts={
 {66,64, -2,8},
 {64,72, 2,8},
}


function _init()
 init_mouse()
end

function _update()
 
 
 
end

drag=0
function _draw()
 cls()

 --pre-draw for picking
 
 for i=1,#parts do
  p=parts[i]
  line2(p[1],p[2],p[3],p[4],i)
 end
 
 mx,my=get_mouse()
 if not objdrag then
  col=pget(mx,my)
 end
 
 
 -- update
 
 mouse_drag(parts[col])
 
 

 
 -- real draw
 
 print(col)
 print(objdrag)
 spr(1,mx,my)

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
__gfx__
00000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007001d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770001dd100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770001ddd10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007001dddd1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001dd110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
