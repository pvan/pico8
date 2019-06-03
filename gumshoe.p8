pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


--sprite flags
--1 - on if walkable
--2 - 
--3 - 
--6 - has frosted (pink) pixels
--7 - draw over player (dep?)


function palreset()
 pal()
 palt(0,false)
 palt(3,true)
end


function _init()

 init_player()
 palreset()
 
 spawn_obj_on_maptiles()
 
 cx,cy=0,0

end



function _update()
 gtime={}
 
 --debug menu
 if btn(❎) and btn(🅾️) then
  pause_menu=true
  
  --pm=0
  if (btnp(⬆️)) then
   if (pm==3) pm=0 else pm=1
  end
  if (btnp(⬅️)) then
   if (pm==4) pm=0 else pm=2
  end
  if (btnp(⬇️)) then
   if (pm==1) pm=0 else pm=3
  end
  if (btnp(➡️)) then
   if (pm==2) pm=0 else pm=4
  end
  return --dont update the rest
 else
  pause_menu=false
  if (pm==1) debugcols=not debugcols
  if (pm==2) debugtrigs=not debugtrigs
  if (pm==4) debuginvobj=not debuginvobj
  if (pm==3) debugcpu=not debugcpu
  pm=0
 end
 
 
 
 
 add(gtime,{"pre",stat(1)})
 update_inv_icons()
 add(gtime,{"inv",stat(1)})
 
 if not inventory_open then
  player_update(dx,dy)
 end
 add(gtime,{"plr",stat(1)})


 --camera follow
 pwx,pwy=px,py
 pwx-=64 pwy-=64 //to cam coords
 cgap=24
 if (pwx>cx+cgap) cx=pwx-cgap
 if (pwx<cx-cgap) cx=pwx+cgap
 if (pwy>cy+cgap) cy=pwy-cgap
 if (pwy<cy-cgap) cy=pwy+cgap
 
end


function draw_player_behind_glass()

 --make list of all pixels on
 --screen that are frosted glass
 glasspix={}
 for obj in all(things) do
	 if ybase(obj)>pybase() then
	  if fget(obj.spr,6) then
	   spx=(obj.spr%16)*8
	   spy=flr(obj.spr/16)*8
	   for x=0,obj.sprw*8-1 do
	    for y=0,obj.sprh*8-1 do
	     if sget(spx+x,spy+y)==14 then
	      screenx=obj.x+x
	      screeny=obj.y+y
	      add(glasspix,{screenx,screeny})
	     end
	    end
	   end
	  end
  end
 end
 
 --red bg
 for p in all(glasspix) do
  pset(p[1],p[2],8)
 end
 
 --drawing player here will
 --potentially overdraw the red
 player_draw()
 
 --check what isn't red any more
 for p in all(glasspix) do
  if pget(p[1],p[2])!=8 then
   pset(p[1],p[2],13)
  else
   pset(p[1],p[2],6)
  end
 end

end

function _draw()
 cls()
 
 camera(cx,cy)
 
 map()

 --sort objects + player
 ypos={}
 for i=1,#things do
  local obj=things[i]
  local ybase=ybase(obj)
  add(ypos,{ybase,i})
 end
 add(ypos,{pybase(),0})
 sort_objs(ypos)
 
 add(gtime,{"sort",stat(1)})
 
 --ok this is pretty simple
 --except for the special glass
 --basically draw everything
 --in order of y (sorted above)
 --a "things" index of i=0
 --is code for the player
 --for glass...
 --(pink, only closed doors)
 --if behind player, just 
 --change pink to gray
 --when we draw the player,
 --run our special code to 
 --render the glass on all doors
 --in front of the player
 --and later, when those 
 --door sprites are drawn,
 --change pink to transparent
 --to save the special glass
 --pixels we already rendered
 drewplayer=false
 for i=1,#ypos do
  if ypos[i][2]==0 then
   add(gtime,{"drawobjb4plyr",stat(1)})
   draw_player_behind_glass()
   add(gtime,{"drawglass/plyer",stat(1)})
   drewplayer=true
  else
   local obj=things[ypos[i][2]]
   if fget(obj.spr,6) then --has transparent pixels
    if drewplayer then  
	    palt(14,true) --transparent
  	 else
 	   pal(14,6) --grey
	   end
   end
   if not debuginvobj then
    draw_obj(obj)
   end
   palreset()
  end
 end
 
 add(gtime,{"drawobjafterplr",stat(1)})
 
 draw_inventory()
 add(gtime,{"drawinv",stat(1)})
 
 
 camera()
 cursor()
 
 if pause_menu then
  spr(15,64-4,64-4)
  spr(15+16,64-4,64-4-10)
  spr(15+16*2,64-4-10,64-4)
  spr(15+16*3,64-4,64-4+10)
  spr(62,64-4+10,64-4)
  
  local rx,ry=64-4,64-4
  if (pm==1) rx=64-4 ry=64-4-10
  if (pm==2) rx=64-4-10 ry=64-4
  if (pm==3) rx=64-4 ry=64-4+10
  if (pm==4) rx=64-4+10 ry=64-4
  rect(rx-1,ry-1,rx+8,ry+8)
 end
	 
 
 if (debugtrigs) then
  for obj in all(things) do
   rect2(obj_trig(obj),7)
  end
 end
 
 if (debugcols) then
  for obj in all(things) do
   c=9
   if (obj.solid) c=10
   rect2(obj_col(obj),c)
  end
 end

 print2("cpu"..stat(1))

 if debugcpu then
		print(" ")
		lastt = 0
		for i=1,#gtime do
		 delta = gtime[i][2]-lastt
		 print2(gtime[i][1].." "..delta)
		 lastt = gtime[i][2]
		end
	end

end


-->8
--player


--psprs={236,237,238,239}
psprs={128,129,130,131}


--for sorting
function pybase()
 return py+16 --(bottom of sprite)
end


function init_player()
	px,py=60,60
	pd=2
	
	pt=0
	
	pclothes=true
	
--	-4,0,3
-- hoty={-2,0,2}
 
 hotx={0,3,7}
 hoty={12,14,17}
 
 edgex={hotx[1],hotx[3]}
 edgey={hoty[1],hoty[3]}
 centerx=hotx[2]
 centery=hoty[2]
 
	
end


function player_update()

 
 local dx,dy=0,0
 if (btn(⬅️)) dx-=1 
 if (btn(➡️)) dx+=1 
 if (btn(⬆️)) dy-=1 
 if (btn(⬇️)) dy+=1
 
 if dx!=0 or dy!=0 then
	 usebox={px+dx*4, py+11+dy*4,
	         8,8}
 end
 
 if pstate=="use" then
	 dx,dy=0,0
  pstatetimeleft-=1
  if pstatetimeleft==0 then
   pstate="stand"
  end
 end
 
 if pstate!="use" then
	 if btnp(❎) and p_use_released then
	  dx,dy=0,0
	  pstate="use"
	  pstatetimeleft=10
	  p_use_ready=true
	  p_use_released=false
	 else
		 if dx!=0 or dy!=0 then
		  pstate="walk"
		 else
		  pstate="stand"
		  pt=1
		 end
	 end
 end
 
 if (not btn(❎)) p_use_released=true
 
 if (dx>0) pflip=false 
 if (dx<0) pflip=true
 
 
 --collision / movement
 if dx!=0 or dy!=0 then
  local allowx,allowy=true,true 
  
  if dx==0 and dy==-1 then
	  ny=py+dy+edgey[1]
	  nx1=px+dx+edgex[1]
	  nx2=px+dx+edgex[2]
	  s1=solidtile(nx1,ny)
	  s2=solidtile(nx2,ny)
	  if s1 or s2 then
	   dy=0
	   if (not s1) dx=-1 
	   if (not s2) dx=1
	  end
	 elseif dx==0 and dy==1 then
	  ny=py+dy+edgey[2]
	  nx1=px+dx+edgex[1]
	  nx2=px+dx+edgex[2]
	  s1=solidtile(nx1,ny)
	  s2=solidtile(nx2,ny)
	  if s1 or s2 then
	   dy=0
	   if (not s1) dx=-1 
	   if (not s2) dx=1
	  end
	 elseif dx==-1 and dy==0 then
	  nx=px+dx+edgex[1]
	  ny1=py+dy+edgey[1]
	  ny2=py+dy+edgey[2]
	  s1=solidtile(nx,ny1)
	  s2=solidtile(nx,ny2)
	  if s1 or s2 then
	   dx=0
	   if (not s1) dy=-1 
	   if (not s2) dy=1
	  end
	 elseif dx==1 and dy==0 then
	  nx=px+dx+edgex[2]
	  ny1=py+dy+edgey[1]
	  ny2=py+dy+edgey[2]
	  s1=solidtile(nx,ny1)
	  s2=solidtile(nx,ny2)
	  if s1 or s2 then
	   dx=0
	   if (not s1) dy=-1 
	   if (not s2) dy=1
	  end
	  
	 else
	 
	  --diagonal movement
	  for x in all(edgex) do
	   for y in all(edgey) do
	    local hx,hy=px+x,py+y
	    if (solidtile(hx+dx,hy)) allowx=false
	    if (solidtile(hx,hy+dy)) allowy=false
	    
--	    --check objs here sep from walls so we can ignore them easier    
--				 if (newobjcol(hx,hy,dx,0)) allowx=false
--				 if (newobjcol(hx,hy,0,dy)) allowy=false
	
	   end
	  end
	  
	  
	 end
	 

  if (allowx) px+=dx
  if (allowy) py+=dy
 end
 
 if p_use_ready and
    usebox!=nil and
    pstate=="use" 
 then
  for obj in all(things) do
   if obj.usefunc then
    if usetrig(usebox,obj) then
     p_use_ready=false
    end
   end
	 end
 end
 
 --anim
 pt+=0.2
 if (pt>#psprs) pt=0
 pa=flr(pt)
 
end


function player_draw()
  
 local psprx=px
 local pspry=py
 
 --do fake project shadow?
 spr(64,psprx,pspry+12)
 
 if pstate=="walk" then
  pspr=psprs[pa+1]
 end
 if pstate=="stand" then
  pspr=psprs[1]
 end
 if pstate=="use" then
  pspr=psprs[4]+1
 end
 if (pclothes) pspr+=(160-128)
 spr(pspr,psprx,pspry,1,2,pflip)

 if debugcols then
  pset(px,py,11)
  
  pset(px+centerx,py+centery,10)
  
  for x in all(hotx) do
  for y in all(hoty) do
  pset(px+x,py+y,10)
  end end
 pset(q1x,q1y,10)
 pset(q2x,q2y,10)

 end
 if debugtrigs then
  if usebox!=nil then
   rect2(usebox,7) end
 end

end



-->8
--util


--ease into t from v at rate
function easeto(v,t,rate)
 return (t-v)/rate
end


--print text centered on x
function printcenter(s,x,y)
 print(s,x-#s*2,y)
end
--print text centered on x
function print2center(s,x,y,c)
 x=x-#s*2
 if (c==nil) c=7
 print(s,x+1,y+1,0)
 print(s,x,y+1,0)
 print(s,x,y,c)
end

--sprite sheet x,y from sprite index
function sspos(i)
 return i%16*8,flr(i/16)*8
end

--scale v from range x,y to a,b
function remap(v,x,y,a,b)
 p=(v-x)/(y-x)
 return (b-a)*p+a
end

function rectfill2(x,y,w,h,c)
 rectfill(x,y,x+w-1,y+h-1,c)
end

function sign_or_zero(v)
 if (v>0) return 1
 if (v<0) return -1
 return 0
end


--sort list of pairs {y,i}
--by the 1st val (y in this case)
function sort_objs(t) 
	for n=2,#t do
		local i=n
		while i>1 and 
		 t[i][1] < t[i-1][1] --[1]=metric
		do
			t[i],t[i-1]=t[i-1],t[i]
			i-=1
		end
	end
end

--sort list of pairs {y,i}
--by the 1st val (y in this case)
function sort_objs(t) 
	for n=2,#t do
		local i=n
		while i>1 and 
		 t[i][1] < t[i-1][1] --[1]=metric
		do
			t[i],t[i-1]=t[i-1],t[i]
			i-=1
		end
	end
end


--sort table list by k element of table
function sort_by_i(t,k) 
 for n=2,#t do
  local i=n
  while i>1 and 
   t[i][k] < t[i-1][k] --[k]=metric
  do
   t[i],t[i-1]=t[i-1],t[i]
   i-=1
  end
 end
end



--rects collide
--using x,y,w,h style rects
function rectcol(a,b)
 return a[1]+a[3]>b[1] and 
								a[1]<b[1]+b[3] and
								a[2]+a[4]>b[2] and
								a[2]<b[2]+b[4] 
end



--drop shadow
function print2(str,col)
 local cursor_x=peek(0x5f26)
 local cursor_y=peek(0x5f27)
 if (col==nil) col=7
 print(str,cursor_x+1,cursor_y+1,0)
 print(str,cursor_x,cursor_y+1,0)
 print(str,cursor_x,cursor_y,col)
 poke(0x5f27,cursor_y+6)
end



function pinrect(px,py,r)
 local rx,ry,rw,rh=r[1],r[2],r[3],r[4]
 return px>=rx and px<rx+rw
    and py>=ry and py<ry+rh
end



--function rect2(x,y,w,h,c)
-- rect(x,y,x+w-1,y+h-1,c)
--end
function rect2(r,c)
 if (c==nil) c=10
 rect(r[1],r[2],r[1]+r[3]-1,r[2]+r[4]-1,c)
end

-->8
--objects


function draw_obj(obj)
 spr(obj.spr,obj.x,obj.y,
     obj.sprw,obj.sprh)
end



function userack(rack)
 pclothes=not pclothes
 rack.spr=34
 if (pclothes) rack.spr=32
end

function usedoor(door)
 door.spr+=1
 if (door.spr==15) door.spr=13
 if door.spr==13 then
  door.solid=true
 else
  door.solid=false
 end
end



function named_mold(m)
 nm={}
 nm.name=m[1]
 
 nm.spr=m[2]
 nm.sprw=m[3]
 nm.sprh=m[4]
 
 nm.solid=m[5]
 nm.relcol={}
 nm.relcol.x=m[6]
 nm.relcol.y=m[7]
 nm.relcol.w=m[8]
 nm.relcol.h=m[9]
 
 nm.reltrig={}
 nm.reltrig.x=m[10]
 nm.reltrig.y=m[11]
 nm.reltrig.w=m[12]
 nm.reltrig.h=m[13]

 nm.usefunc=m[14]
 return nm
end


function obj_col(obj)
 return {
  obj.x+obj.relcol.x,
  obj.y+obj.relcol.y,
  obj.relcol.w,
  obj.relcol.h
  }
end

function obj_trig(obj)
 return {
  obj.x+obj.reltrig.x,
  obj.y+obj.reltrig.y,
  obj.reltrig.w,
  obj.reltrig.h
  }
end

--for sorting
function ybase(obj)
 return obj.y+obj.sprh*8
end


function spawn(x,y,mold)
 obj={}
 
 obj.x=x
 obj.y=y
 
 local nm=named_mold(mold)
 for k,v in pairs(nm) do
  obj[k]=v
 end
 
 add(things,obj)
end



function usetrig(r,obj)
 if rectcol(r,obj_trig(obj))
 then
  obj.usefunc(obj)
  return true
 end 
 return false
end





mold_rack={
 "rack",
 32,  --sprite
 2,2, --tilesize
 true, --is solid
 4,10,7,6,  --col rel to sprite
 4,10,7,6, --trig rel to sprite
 userack, --trigger handler
-- 0, --sort offset?
}
mold_door={
 "door",
 13,  --sprite
 1,2, --tilesize
 true, --is solid
 0,12,8,4,  --col rel to sprite
 0,8,8,8, --trig rel to sprite
 usedoor, --trigger handler
-- 0, --sort offset?
}
mold_window={
 "window",
 40,  --sprite
 2,2, --tilesize
 true, --is solid
 0,12,16,4,  --col rel to sprite
 0,0,0,0, --trig rel to sprite
 nil, --trigger handler
-- 0, --sort offset?
}
mold_wall1={
 "wall1",
 9,  --sprite
 1,2, --tilesize
 true, --is solid
 0,12,8,4,  --col rel to sprite
 0,0,0,0, --trig rel to sprite
 nil, --trigger handler
-- 0, --sort offset?
}
mold_wall2={
 "wall2",
 10,  --sprite
 1,2, --tilesize
 true, --is solid
 0,12,8,4,  --col rel to sprite
 0,0,0,0, --trig rel to sprite
 nil, --trigger handler
-- 0, --sort offset?
}

molds={
 mold_door,
 mold_rack,
 mold_window,
 mold_wall1,
 mold_wall2,
}

things={}

--spawn(5*8,14*8,mold_door)
--spawn(3*8,2*8,mold_rack)
--spawn(9*8,14*8,mold_window)

function spawn_obj_on_maptiles()
	for x=0,127 do
	 for y=0,63 do
	  for m in all(molds) do
		  if mget(x,y)==m[2] then --spr
		   for xx=0,m[3]-1 do --sprw
		    for yy=0,m[4]-1 do --sprh
		     if x+xx%2==0 then
		 		   mset(x+xx,y+yy,22)
		 		  else
		 		   mset(x+xx,y+yy,22)
		 		  end
		    end
		   end
		   spawn(x*8,y*8,m)
		  end
		 end
	 end
	end
end


-->8


function solidtile(x,y)

 local tile=mget(x/8,y/8)
 if (fget(tile,0)==false) return true
 
 for obj in all(things) do
		if obj.solid then
			if pinrect(x,y,obj_col(obj)) then
 			return true
			end
		end
	end
	
 return false

end


function newobjcol(x,y,dx,dy)
 for obj in all(things) do
		if obj.solid then
		 --ignore obj if we are
		 --already on top of it
			if not pinrect(x,y,obj_col(obj)) and
			   pinrect(x+dx,y+dy,obj_col(obj)) then
 			return true
			end
		end
	end
	return false
end
-->8
--inventory


inventory={96,98,100,102,104,106,108,110}
itemnames={
 "inspect",
 "use",
 "use2",
 "key",
 "paper",
 "letter",
 "wallet",
 "money"
 
}
selitem=1


function init_inv_icons()
 inv_icons={}
 
 for i=selitem,#inventory do
  add(inv_icons,{0,0,0,i})
 end
 for i=selitem,1,-1 do
  if i!=selitem then
   add(inv_icons,{0,0,0,i})
  end
 end
end

function shrink_targ_icons()
 targ_icons={}
 
 for i=selitem,#inventory do
  add(targ_icons,{0,0,0})
 end
 for i=selitem,1,-1 do
  if i!=selitem then
   add(targ_icons,{0,0,0})
  end
 end
end

function set_targ_icons()
 targ_icons={}
 
 startxstep=12
 startystep=3
 startsize=16
 startx=-6
 starty=-18
 
 xstep=startxstep
 ystep=startystep
 size=startsize
 x=startx
 y=starty
 for i=selitem,#inventory do
  add(targ_icons,{x,y,size})
  x+=xstep
  y+=ystep
  xstep-=1
  ystep*=0.8
  size-=1
 end
 xstep=startxstep
 ystep=startystep
 size=startsize
 x=startx
 y=starty
 for i=selitem,1,-1 do
  if i!=selitem then --don't dup this icon
   add(targ_icons,{x,y,size})
  end
  x-=xstep
  y+=ystep
  xstep-=1
  ystep*=0.8
  size-=1
 end
 sort_by_i(targ_icons,1)
end

function step_inv_to_targ_icons()
 for i=1,#inv_icons do
  tweenease=2
  --x
  inv_icons[i][1]=
   inv_icons[i][1]+
   ceil(targ_icons[i][1]-
    inv_icons[i][1])/tweenease
  --y
  inv_icons[i][2]=
   inv_icons[i][2]+
   ceil(targ_icons[i][2]-
    inv_icons[i][2])/tweenease
  --size
  inv_icons[i][3]=
   inv_icons[i][3]+
   ceil(targ_icons[i][3]-
    inv_icons[i][3])/tweenease
 end
end

inventory_open=false
inv_icons={}
targ_icons={}
function update_inv_icons()
 
 if btn(🅾️) then
  if not inventory_open then
   init_inv_icons()
  end
 else
  if inventory_open then
   shrink_targ_icons()
  end
 end
 inventory_open=btn(🅾️)
 
 if inventory_open then
  if (btnp(⬅️)) selitem-=1
  if (btnp(➡️)) selitem+=1
  selitem=mid(1,selitem,#inventory)
  
  set_targ_icons()
 end

 step_inv_to_targ_icons()

end


function draw_icon_i(icons,i)

 icon=icons[i]
 sprt=inventory[i]
 x=icon[1]+px
 y=icon[2]+py
 size=icon[3]
 w,h=size,size
   
 rectfill2(x,y,w+2,h+2,0)
 rectfill2(x+1,y+1,w,h,7)
 palt(0,true)
 ssx,ssy=sspos(sprt)
 sspr(ssx,ssy,16,16,
  x+1,y+1,w,h)
 palt(0,false)
end
function draw_inv_icons(icons)

 for i=#icons,selitem+1,-1 do
  draw_icon_i(icons,i)
 end
 for i=1,selitem do
  draw_icon_i(icons,i)
 end

 if inventory_open then
 print2center(
  itemnames[selitem],px+4,py-25)
 end
end


function draw_inventory()
 if #inv_icons>0 then
  if inv_icons[1][3]>1 then --size
   draw_inv_icons(inv_icons)
  end
 end
end
__gfx__
00000000dddddddd66666666dddddddddddddddd0000000016666666000000001666666666666666666666666666666116666661666666666666666611111111
00000000ddddddddd666666ddddddddddddddddd0000000016666666000000001666666666666666666666666666666116666661666666666666666617777771
00700700dddddddddd666d6ddddddddddddddddd0000000016666666000000001111111111111111111111111111111116666661111111111111111117555771
00077000ddddddddddd66d6ddddddddddddddddd0000000016ddddd6000000001dddddddddddddddddddddddddddddd116666661dddddddddddddddd17575d71
00077000ddddddddddd6dddddddddddddddddddd0000000016d666d6000000001dddddddddddddddddddddddddddddd116666661111111111111111117555d71
00700700dddd6dddddd6dddddddddddddddddddd0000000016ddddd6000000001dddddddddddddddddddddddddddddd1166666611eeeeee115133333177ddd71
00000000dddd6ddddddddddddddddddddddddddd0000000016666666000000001dddddddddddddddddddddddddddddd1166666611e00e0e1d513333317777771
00000000ddd666dddddddddddddddddddddddddd0000000011111111000000001dddddddddddddddddddddddddddddd1166666611e0ee0e1d513333311111111
00000000d666666ddddddddddddddddddddddddd0000000015555555555555551dddddddddddddddddddddddddddddd1000000001eeeeee11513333311111111
0000000066666666dddddddddddddddddddddddd0000000015555555555555551dddddddddddddddddddddddddddddd100000000155555511513333314444441
0000000011111111111111111111111111111111000000001555555555555555111111111111111111111111111111110000000015555551151333331444a4a1
0000000044444444444414444444444444444444000000001111111111111111144444444444144444444444444444410000000015111151d513333314444441
0000000022222222222414222222222222222222000000005555555551555555142222222224142222222222222222410000000015144451d51333331444a4a1
0000000022222222222414222222222222222222000000005555555551555555142222222224142222222222222222410000000015555551151333331aaa4441
000000002222222222241422222222222222222200000000555555555155555514222222222414222222222222222241000000001111111111133333144a4441
00000000111111111111111111111111111111110000000011111111111111111111111111111111111111111111111100000000333333333333333311111111
33333333333333333333333333333333444444444444444444444444555555556666666666666666666666666666666600000000000000000000000011111111
333337333733333333333733373333334444444444444444444444445dddddd56666666666666666666666666666666600000000000000000000000014441111
333333767333333333333376733333334444444444444444eeee4444511111151111111111111111111111111111111100000000000000000000000014477711
33333336333333333333333633333333444444666444444ffffe444411111111eeeeeeeeeeeeeeeedddddddddddddddd00000000000000000000000014471711
33333736373333333333443634443333444477766774444ffffe444451111115e0000e000e00000edd66666dd66666dd00000000000000000000000017777711
33333376733333333334447674663333444477766774446ffffe44445dddddd5e0eeee0e0e0e0e0edd66666dd66666dd00000000000000000000000017447111
33333336333333333334443634643333444477766774446ffffe44445dddddd5e0000e000e0e0e0edd66666dd66666dd00000000000000000000000017777441
33333336333333333334443634643333444477747774444ffff444441dddddd1eeee0e0e0e0eee0edd66666dd66666dd00000000000000000000000011111111
3333333633333333333444363444333344444444444444444444444454444445e0000e0e0e0eee0edd66666dd66666dd00000000000000001111111111111111
3333333633333333333444363333333311111111111111111111111151111115eeeeeeeeeeeeeeeedd66666dd66666dd00000000000000001444444111117771
3333333633333333333444363333333311111111111111111111111151111115e00e00e00e0ee00e1d66666dd66666d100000000000000001404040117777771
3333333633333333333443363333333311100000000000000000011151111115e0ee00e00e00e0ee1d66666dd66666d100000000000000001444444111111171
33333dd6dd33333333333dd6dd33333311100000000000000000011154444445ee0e0ee00e00e00e1d66666dd66666d100000000000000001400400117777771
3333ddddddd333333333ddddddd3333311100000000000000000011154444445e00e0ee00e0ee00e1d66666dd66666d100000000000000001400400111117771
33333ddddd33333333333ddddd33333311100000000000000000011154444445eeeeeeeeeeeeeeee1dddddddddddddd100000000000000001444444117777771
33333333333333333333333333333333111000000000000000000111511111151111111111111111111111111111111100000000000000001111111111111111
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000
000002222220000000000000000000000001111000000000000000000000000000001111111111000000000000000000000000000000000000000000033bbb00
000022666622000000011111111000000001ff1001111100000000000000000000011777777771000000011111111110000001111111111000000111133bbb10
00022667666220000001ff11ff1111000001ff1111fff10000000000000000000011777777777100001111666666661000111155555555100011115533bbb510
00026676666620000001ff11ff1ff1000011fffffffff1000011111100000000001776666667710001166677777766100115554444445510011555433bbb5510
00026766766620000001fff1ff1ff100001fffffffff110000166661111110000017777777777100016777777776761001544444444555100154443bbbb55510
00026667666620000001fff1fffff100001fffffff1111000016dd6666661000001766666777710001677777766776100154444445555510015443bbb5555510
000226666662200001111ffffffff100001ffffffffff1000016dd6dddd110000017777777771100016666666777761001555555555555100155555555555510
000022666622000001fff1fffffff100001ffffffffff10000166661111100000017766667771100016777777777761001555555555555100155555555555510
000002222220000001ffff1fffff1100001fffffff11110000111111000000000017777777777100016777777766661001555555555555100155555555555510
00000002200000000111ffffffff10000011ffffffff100000000000000000000011776666667100016777776611111001555555551111100155555555111110
000000022000000000011fffffff1000000111111fff100000000000000000000001777777777100016666661111000001555555111100000155555511110000
0000000220000000000011fffff11000000000001111100000000000000000000001777777777100011111111000000001111111100000000111111110000000
00000002200000000000011111110000000000000000000000000000000000000001111111111100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333331111100000000000000000000000000000000000000000000000000000004000000000000000000000000000
33333333333333333333333333333333333333331777100000000000000000000000000000000000000000000000400000444600000044000000400000000000
3333333333ddd3333333d33333333333333333331766100000000000000000000000000000000000000000000044460000666600006666000044460000000000
33ddd3333dffff3333ddd33333ddd33333ddd3331766100000000000000000000000000000000000000000000466664004444440044444400466664000000000
3dffff333df1f1333dffff333dffff333dffff331121100000000000000000000000000000000000000000000444444000f1f10000ffff000444444000000000
3df1f13333ffff333df1f1333df1f1333df1f13301210000000000000000000000000000000000000000000000f1f10000ffff0000f1f10000f1f10000000000
33ffff333666163333ffff3333ffff3333ffff3301110000000000000000000000000000000000000000000000ffff000466160000ffff0000ffff0000000000
33661633377717333666163336661633336661330000000000000000000000000000000000000000000000000466160044771740046616000466610000000000
377717733777173377771733777717733777777f0000000000000000000000000000000000000000000000004447174044771740044717400444710000000000
7777177337771733777177f37777177f3777777f0000000000000000000000000000000000000000000000004447174044717740044717400444f10000000000
7777177337ff7731777177f37771777f3777713300000000000000000000000000000000000000000000000044471740f4777740044717404444f70000000000
ff7777733666ddd1ff777733f777777337777733000000000000000000000000000000000000000000000000ff47774044666d40044777404447770000000000
36666dd3d666ddd1d666ddd33366dd3336666d3300000000000000000000000000000000000000000000000004466d4046666d4004666d0044d6660000000000
36666dd3d6633333d666ddd33366d33336666d3300000000000000000000000000000000000000000000000004466d404660011044666d0044dd660000000000
3ddd1111dd333333d333311133d111333ddd11130000000000000000000000000000000000000000000000000ddd11110dd000000ddd110001110dd000000000
33333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333343333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33334333334446333333443333334333333343330000000000000000000000000000000000000000000000000000000000000000000044000000400000000000
33444633336666333366663333444633334446330000000000000000000000000000000000000000000000000000000000000000006666000044460000000000
34666643344444433444444334666643346666430000000000000000000000000000000000000000000000000000000000000000044444400466664000000000
3444444333f1f13333ffff333444444334444443000000000000000000000000000000000000000000000000000000000000000000ffff000444444000000000
33f1f13333ffff3333f1f13333f1f13333f1f133000000000000000000000000000000000000000000000000000000000000000000f1f10000df1f0000000000
33ffff333466163333ffff3333ffff3333ffff33000000000000000000000000000000000000000000000000000000000000000000ffff00000fff0000000000
34661633344717333446163334661633334661330000000000000000000000000000000000000000000000000000000000000000044461000446610000000000
444717433447173344471733447717433444444f0000000000000000000000000000000000000000000000000000000000000000044471400447710000000000
4447174334471733444177f34477174f3444444f0000000000000000000000000000000000000000000000000000000000000000444771404447710000000000
444717433ff77731444177f34471774f3444713300000000000000000000000000000000000000000000000000000000000000004f4717404447770000000000
ff4777434446ddd1ff477733f47777433447773300000000000000000000000000000000000000000000000000000000000000004f477740ff47770000000000
34466d434466ddd14446ddd34466dd4334466d3300000000000000000000000000000000000000000000000000000000000000000466dd0044666d0000000000
34466d43d66333334466ddd34466d33334466d330000000000000000000000000000000000000000000000000000000000000000446ddd004466dd0000000000
3ddd1111dd333333d333311133d111333ddd111300000000000000000000000000000000000000000000000000000000000000000dd001100d01100000000000
00000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000050000000000000000000000000000055505000000000000000000000000000000000000000000000000000000000000040000000000000000000
00000000005550500000000000000000000000000000005000000000000000000000000000000000000040000000400000000000004446000000400000000000
00000000000000500000000000000000000000000500005000000000000000000000000000000000004446000044400000000000046666400044460000000000
00ddd0000500005000ddd00000ddd00000000000055555500000000000ddd00000ddd00000ddd000046666400400004000000000044444400466664000000000
0dffff00055555500dffff000d9999000000000000000000000000000dffff000dffff000dffff0004444440044444400000000000f1f1000444444000000000
0df1f100000000000df1f1000d9191000000000000000000000000000df1f1000df1f1000df1f10000f1f100000000000000000000ffff0000f1f10000000000
00ffff0000ffff0000ffff000099990000000000000000000000000000ffff0000ffff0000ffff0000ffff0000000000000000000066610000ffff0000000000
066616600500000006d717d004561650000000000500000000000000066616600d66160004661600046616000400000000000000004471000066610000000000
7777177055500040666d77d04445165000000000055000000000000077771770ddd717d044471740444717404440004000000000044471000444710000000000
77771770555504406666d7d04444565000000000055500000000000077771770ddd717d0444717404447174044400040000000000ff471000444710000000000
777717700055544066666dd04444455000000000000550000000000077771770ddd717d0444717404447174044400040000000000ff47100f444710000000000
ff777770ff555440ff666dd099444550000000000055500000000000ff777770ffd777d0ff477740ff477740004000400000000004477700f447770100000000
06666dd00555544006666d000444455000000000005550000000000006666dd00dd66dd004466d4004466d4004400040000000000466660004666dd100000000
06666dd00555540006666d000444455000000000005550000000000006666dd006666dd004466d4004466d400440004000000000046666000466ddd100000000
0ddd11110ddd11110ddd11100ddd11110000000000000000000000000ddd11110ddd11110ddd11110ddd1111000000000000000000dd11000dd0000000000000
000000000000000000000000000000000000000000000000000000000666f6600466160022222222000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777777704447174022222222000000000000000000000000000040000000000000000000
00000000000000000000000000000000000000000000000000000000777777704447174022220222000000000000000000004000004446000000440000004000
00000000000000000000000000000000000000000000000000000000777777704447174022000622000000000000000000444600006666000066660000444600
00ddd0000000000000000000000000000000000000ddd00000000000ff777770ff47774020666602000000000000000004666640044444400444444004666640
0dffff00000000000000000000000000000000000d4444000000000006666dd004466d402000000200000000000000000444444000f1f10000ffff0004444440
0df1f100000000000000000000000000000000000d4141000000000006666dd006666dd022f1f122000000000000000000f1f10000ffff0000f1f10000f1f100
00ffff000000000000000000000000000000000000444400000000000ddd11110ddd111122ffff22000000000000000000ffff000466160000ffff0000ffff00
0d6616000d6616000466160004661600046616000664446000000000000000000000000020660622000000000000000004661600447717400446160004461600
6dd717605dd717d04447174044471740444717407774477000000000000000000000000000070702000000000000000044471740447717404447174004471700
66d7176055d717d04447174044471740444717407777477000000000000000000000000000070702000000000000000044471740444f77404447174044471700
66671760555717504447174044471740444717407777677000000000000000000000000000070702000000000000000044471740444f774044471740444f1700
ff677760ff577750ff477740ff477740ff47774044776770000000000000000000000000ff0777020000000000000000ff4777404666dd404ff77740444f7700
066dd66005566d5004466d4004466d4044466d40066767d000000000000000000000000020055112000000000000000004466d404666dd404466dd0044666d00
0555111006666dd006666dd004466d4044466d4006666dd000000000000000000000000025555112000000000000000004466d40466001104d66dd004466dd00
0666dddd0ddd11110ddd11110ddd11110ddd11110ddd11110000000000000000000000002666dddd00000000000000000ddd11110dd000000d00011000001100
__gff__
0100000000000000000000000040000000000000000001010000000001400000000000000000000040400000000000000000000000000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000c03020103030303020303010303030302010303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c13121112131213121312111213121312111213121300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c17162716171617161716202117161716271617161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c17242526171716161716303117161724252617171600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c17343536171617161616161717161734353617161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c17161716171617161716161716171716171617161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c171617161716171617161617160c1716171617161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c171617161716171617161716170c1716171617161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c171617161717171617161716170c1716171617171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a092a2b0a090a090a090a090a090a090d090a0b1716171616171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a193a3b1a191a191a191a191a191a191d191a1b1716161617161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1616161716161617161716171717161616171616161716171617171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171617161716171617161716171617161716171617161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171617161716171617161716171617161716171617161700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a090a090a0d0a090a2829090a090a090a090a0d0a090a2829090a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a191a191a1d1a191a3839191a191a191a191a1d1a191a3839191a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
