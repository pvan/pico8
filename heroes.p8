pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--todo:
--walking thru open mob
--sorting castles/etc (move pos to lowest point, eg -x,-y col)
--dont spawn items on mobs?
--when selecting castle, popup text is for last cur pos
--add is_plr_ai list or something?
--make battle skip turn menu option
--cannot trade with adjacent hero
--replace hero selection with menu in battle
--remove cursor in battle during animation
--...and remove control instructions??


--token saving
--compress data
--make mob stack .name/.count insetad of [1],[2]
--switch x,y to pt (rects too?)
--improve state switching?
--consolidate hud rendering?
--eg 1 menu code for any menu?


--notes:
--
--being a little cavalier
--with x,ys being tile or screen
--note *8 and /8 to deduce
--
--objs,path x,y are tile
--cam is screen, cur is both
--tile i is used a bunch too
--for lookups from tile x,y
--
--music is faure
--see https://www.youtube.com/watch?v=pmdkpmtjms0

camx=0
camy=0

function set_sel()

 select(cp.heroes[1])
 if sel==nil then
  select(cp.castles[1])
 end
 if sel==nil then
  --todo: remove players until winner
  stop("player "..
   colorstrings[cp.color].. 
   " has no castles or heroes")
 end
end

function set_player(p)
 cp=p
 
 set_sel()
 
 --reset for this turn
 for h in all(cp.heroes) do
  h.move=100
 end
 
 hud_menu_open=false
 actl_menu_y=0
 
 blackout=true

 open_dialog({
   colorstrings[cp.color].." player's turn",
   "  ok"
  },{
   close_dialog
  })
  
end


function random_starting_army()
 return {
  {"peasants",rnd_bw(10,20)},
  {"elves",rnd_bw(5,10)},
 }
end


function _init()
-- music(0)

 init_data()
 init_cursor()

 
 blackout=true
 
 red_plr=create_player(8)
 green_plr=create_player(11)
 blue_plr=create_player(12)
 
 
 plrs={
  red_plr,
  green_plr,
  blue_plr
 }
 
 tc=spawn("castle",3,5)
 red_plr.castles[1]=tc
 tc.army=random_starting_army()
 red_plr.heroes[1]=
 	spawn("hero",tc.x+2,tc.y+3)
 red_plr.heroes[2]=
 	spawn("hero",tc.x-3,tc.y+6)
 	
 tc=spawn("castle",24,2)
 tc.army=random_starting_army()
 green_plr.castles[1]=tc
 green_plr.heroes[1]=
 	spawn("hero",tc.x+2,tc.y+3)
 	
 tc=spawn("castle",16,20)
 tc.army=random_starting_army()
 blue_plr.castles[1]=tc
 blue_plr.heroes[1]=
 	spawn("hero",tc.x+2,tc.y+3)
 	
 
 set_player(red_plr)
 
 	
	spawn("testhouse",10,10)
	spawn("mob",6,14)
	spawn("mob2",13,14)
	spawn("mob2",6,18)
	spawn("gold",2,1)
	spawn("gold",7,16)
	spawn("gold",8,16)
	spawn("gold",6,10)
	
	--block grove
	spawn("ore",22,20)

	--block hero in castle test
--	spawn("ore",5,9)
	
 
 --do once here so we don't
 --randomly spawn anything
 --over anything else
 create_i2tile()
-- build_i2zone()
 
	for x=0,tilesw do
 	for y=0,tilesh do
 	 if not tile_is_solid(pt(x,y)) then
 	  if rnd_bw(1,100)<4 then
 	   r=rnd_bw(1,#resources)
 	   spawn(resources[r],x,y)
 	  end
 	 end
 	end
	end
	
	
 --after populating map
 --(and whenever anything moves)
 create_i2tile()
-- build_i2zone()
	
end


function create_player(c)
 local res={}
 res["color"]=c
 res["gold"]=200
 res["wood"]=10
 res["ore"]=10
 res["gems"]=5
 res["sulfur"]=5
 res["mercury"]=5
 res["crystal"]=5
 
 res["heroes"]={}
 res["castles"]={}
 return res
end


function split_update()
		
	if btnp(⬅️) 
	and movingmob[2]>1
	then
	 movingmob[2]-=1
	 splitmob[2]+=1
	end
	if btnp(➡️)
	and splitmob[2]>1
	then
	 movingmob[2]+=1
	 splitmob[2]-=1
	end
	if btnp(❎) then
	 main_update=trade_update
	 main_draw=trade_draw
	end

end

function split_draw()

 --keep drawing trade window
 --while split window open
 trade_draw()

 --todo: consider moving
 --split window up, so we can
 --still see armies, hmm...
 --lose hierarchy that way tho

	draw_window(
	 43,--63-16-2-2,
	 54,--60-2-4,
	 40,--16*2+8,
	 36)--20+2+10+4)
	 
	print("split",53,57,1)
	 
	draw_big_mob(splitmob,
	 45,--63-16-2,
	 60)
	 
	draw_big_mob(movingmob,
	 65,--63+2,
	 60)			  

 //55=63-8
 spr(225,55,70,1,1,true)
 spr(225,63,70)
 print("❎",51,82+flashamt(),1)
 print("done",59,82,1)
end


--token:inline?
function hero_trade(a,b)
 trade_a=a
 trade_b=b
 tcur=pt(1,1)
 main_update=trade_update
 main_draw=trade_draw
end

function trade_update()

 --basically to hide 
 --cursor pop-up info
 cur_obj=nil
 
-- while true do
 
  --draw / update trade window
  
 bars={trade_a,trade_b}
 
 move_cursor(tcur, 1,5, 1,3)
 
 tcur.x=ceil(tcur.x)
 tcur.y=ceil(tcur.y)
 if tcur.y==3 then
  tcur.y=2.4
  tcur.x=2.65
 end
 
 if movingmob!=nil then
  if btnp(❎) then
   --place
	  bar=bars[tcur.y]
   mob=bar.army[tcur.x]
   if mob==nil then
		  bar.army[tcur.x]=movingmob
		  movingmob=nil
   elseif mob[1]==movingmob[1] then
    bar.army[tcur.x][2]+=movingmob[2]
    movingmob=nil
   else
    local temp=movingmob
    movingmob=mob
    bar.army[tcur.x]=temp
	  end
  end
 else
	 if tcur.y==2.4 then
	  if btnp(❎) then
			 main_update=nil
			 main_draw=nil
	  end
	 else
		 if btnp(❎) then
	   bar=bars[tcur.y]
	   mob=bar.army[tcur.x]
	   if mob!=nil then
		   movingmob=mob
		   bar.army[tcur.x]=nil
		  end
		 end
		 if btn(🅾️) then
	   bar=bars[tcur.y]
			 splitmob=bar.army[tcur.x]
	   if splitmob!=nil 
	   and splitmob[2]>1 then
			  splitval=1
			  splitmob[2]-=splitval
			  movingmob=copy(splitmob)
			  movingmob[2]=splitval
			  
			  main_update=split_update
			  main_draw=split_draw
			  
			 end
		 end
  end
 end
 
end

function trade_draw()
  
 draw_army_b(trade_a,60)
 
 draw_army_b(trade_b,85)
 
 
 text_box("done",58,110)
 
 
--  frame+=1
 
 if movingmob!=nil then
  draw_big_mob(movingmob,
   tcur.x*18+13,
   tcur.y*28+30+flashamt())
 end
 
 --draw cursor
 spr(208,
     tcur.x*18+22,
     tcur.y*28+46+flashamt())
 
 --draw instructions?
 
end


function pickup(obj)
 --should only get here 
 --with type==treasure
 sfx(57)
 if has(resources,obj.subtype) then
  cp[obj.subtype]+=obj.amount
 end
 del(things,obj)
end
    
    
movespeed=2
function move_hero()
 if sel.move>0 then
--  del(path,path[1]) --skip square we're on
  moving=true
  movingdelay=movespeed
 end
end

function update_camera()
 camgap = 32
 if curx>camx+64+camgap then camx+=2 end
 if curx<camx+64-camgap then camx-=2 end
 if cury>camy+64+camgap then camy+=2 end
 if cury<camy+64-camgap then camy-=2 end
-- camx=max(camx,-worldborder)
-- camy=max(camy,-worldborder)
-- camx=min(camx,(tilesw-1)*8-128+worldborder*2) --minus size of camera
-- camy=min(camy,(tilesh-1)*8-128+worldborder*2)
end




function update_map()

 if moving then
  movingdelay-=1
  if (movingdelay>0) then 
   return
  else
   movingdelay=movespeed
  end
  local p=path[1]
  local obj=g(mapobj,p)
  if sel.move>0 then
	  del(path,p)
	  if obj!=nil and
		  (obj.type=="hero" or
		   obj.type=="mob" or
		   obj.type=="treasure")
	  then
	   if obj.type=="hero" then
	    if obj_owner(obj)==cp then
 	    hero_trade(sel,obj)
 	   else
	     start_battle(sel,obj)
	    end
	   end
	   if obj.type=="mob" then
	    start_battle(sel,obj)
	   end
	   if obj.type=="treasure" then
	    pickup(obj)
	   end
	  else
 	  sfx(58,-1,1,1)
 	  --token:ptset()?
	   sel.x=p.x
	   sel.y=p.y
	   sel.move-=5
	   if (sel.move<0) sel.move=0
	   --lock cam to hero?
	   camx=sel.x*8-64
	   camy=sel.y*8-64
	   update_camera()
	  end
	  if #path==0 then
	   moving=false
	   --rebuild zones after move!
			 create_i2tile()
--			 build_i2zone()
	  end
	 else
   moving=false
   --rebuild zones after move!
		 create_i2tile()
--		 build_i2zone()
	 end
 end



 if (btnp(🅾️)) then
  hud_menu_open=not hud_menu_open
  if (hud_menu_open) then 
   sfx(63)
  else 
   sfx(61) 
  end
 end
 
 
 update_hud()
 if hud_menu_open then
  return
 end 
 
 
 update_cursor()
 ctx=flr(curx/8)
 cty=flr(cury/8)
 
 update_camera()
 
 if sel!=nil and
    sel.type=="hero" 
 then
  if btnp(❎) 
     and path!=nil 
     and #path>0 
     and (path[#path].x==ctx and
          path[#path].y==cty)
  then
   move_hero()
  else
   update_move_cursor()
  end
 else
  update_sel_cursor()
 end
 
 --clear path if sel change
 if (lsel2==nil) lsel2="no object" --not nil b/c sel could be nil and we want to detect changes
 if (lsel2!=sel and sel!=nil) then
  path={}
 end
 lsel2=sel

 --needed?
-- if lselmvx==nil and lselmvy==nil then
--  lselmvx="no move"
--  lselmvy="no move"
-- end
 if sel!=nil then
  if sel.movex!=nil and sel.movey!=nil then
   if sel.movex!=lselmvx or
      sel.movey!=lselmvy then
	   x1,y1=sel.x,sel.y
	   x2,y2=sel.movex,sel.movey
--	   targ=i2obj[xy2i(x2,y2)]
	   targ=g(mapobj,pt(x2,y2))
	   ignore=nil
	   if targ!=nil and
	      (targ.type=="mob" or
 	      targ.type=="hero" or
 	      targ.type=="treasure")
	   then
	    ignore=targ
	   end
	   path=pathfind(
	    pt(x1,y1),
	    pt(x2,y2),
	    ignore,
	    map_neighbors,
	    map_dist)
	   del(path,path[1])
   end
  end
	 lselmvx=sel.movex
	 lselmvy=sel.movey
 end
end



frame=0
function _update()

 frame+=1
 
 --true if open
 if update_dialog() then
  return
 end
 
 if in_battle then
  update_battle()
  return
 end




 if main_update!=nil then
  main_update()
 else
  update_map()
 end
 
 
-- cache_btns()
 
end


function map_draw()

 	camera(camx,camy)
	
	 draw_overworld()
	 
	 
	 --draw path
	 if path!=nil and #path>1 then
	  lx,ly=sel.x,sel.y
		 for i=1,#path do
		  nx,ny=path[i].x,path[i].y
		  dx,dy=nx-lx,ny-ly
		  if dx==0 then
		   if (dy<0) sprt=144 yflip=false
		   if (dy>0) sprt=144 yflip=true
		  else
		   if (dx<0) sprt=160 xflip=false
		   if (dx>0) sprt=160 xflip=true
		  end
		  if (i==#path) sprt=128
	 	 spr(sprt,nx*8,ny*8,1,1,xflip,yflip)
		  lx,ly=nx,ny
		 end
	 end
	 
	 
	 draw_cursor()
	 
	 
--	 drawdebug_zones()
--	 drawdebug_layer(i2danger,8)
--	 drawdebug_layer(i2hot,11)
--	 drawdebug_layer(i2col,10)
	 
	 
	 --hud elements
	 color()
	 cursor()
	 camera()
	 
	 
 	draw_hud()
 	
 	
	 if blackout then
 	 
 	 for x=0,15 do
 	  for y=0,15 do
 	   spr(121,x*8,y*8) 
 	  end 
 	 end
 	 
	 end
	 
	 draw_dialog()
	 
end


function _draw()
 
	if in_battle then
  draw_battle()
 else
 
  map_draw()
  
  if main_draw!=nil then
   main_draw()
  else
  end

 end 
 
end




function end_turn()
 menudown=false
 path=nil
 i=1
 for p in all(plrs) do
  if (p==cp) then
   nextpi=i+1
   if nextpi>#plrs then
    nextpi=1
   end
   set_player(plrs[nextpi]) 
   break
  end
  i+=1
 end
end

-->8
--util 



function ptequ(a,b)
 return a.x==b.x and a.y==b.y
end

function ptadd(a,b)
 return pt(a.x+b.x, a.y+b.y)
end

function ptinc(p,amt)
 p.x+=amt.x
 p.y+=amt.y
end

function pt(x,y)
 local res={}
 res.x=x
 res.y=y
 return res
end



--hash pt for use as keys
--assumes x,y are <255 (1 byte)
--packs y into the higher bits
--could also use the 16 bits decimal
--recall pico numbers are stored
--like so: 1:15:16 sign:whole:decimal
function pt2i(p)
 return bor(p.x,shl(p.y,8))
end
function i2pt(i)
 local x=band(i,0b11111111)
 local y=band(i,0b1111111100000000)
 y=shr(y,8)
 return pt(x,y)
end



function wait(ticks)
 while ticks>0 do
  ticks-=1
  draw_battle()
  flip()
 end
end



function indexof(t,n)
 for k,v in pairs(t) do
  if (v==n) return k
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



--inclusive (low<=result<=high)
--remove +1 for low<=result<high
function rnd_bw(low,high)
 return flr(rnd(high-low+1))+low
end



function rect2(r,c) 
 if (c==nil) c=10
 if (r[3]==0 or r[4]==0) return
 rect(r[1],r[2],
      r[1]+r[3]-1,
      r[2]+r[4]-1,c)
end


function rectfill2(x,y,w,h,c)
 if w>0 and h>0 then
  rectfill(x,y,x+w-1,y+h-1,c)
 end
end



--drop shadow print
function print2(str,col)
 local cursor_x=peek(0x5f26)
 local cursor_y=peek(0x5f27)
 if (col==nil) col=7
 print(str,cursor_x+1,cursor_y+1,0)
 print(str,cursor_x,cursor_y+1,0)
 print(str,cursor_x,cursor_y,col)
 poke(0x5f27,cursor_y+6)
end


----print and bounce any ❎, etc
----center on screen
--function print_bounce(str,y)
-- local w=#str*4
-- local sx=63-w/2
-- for i=1,#str do
--  local bounce=0
--  if str[i]>z then
--   bounce=flashamt()
--  end
--  print(str[i],sx,y+bounce)
-- end
--end



--check if array contains
function has(array, value)
 if type(array)=='table' then
  for i=1,#array do
   if array[i]==value then return true end
  end
 end
 return false
end


--simple expansion over has()
--that allows for pts
function has2(arr, val)
 if type(arr)=='table' then
  for i=1,#arr do
   if (arr[i]==val) return true
   
   --check pts
   if ptequ(arr[i],val) then
    return true
   end
   
  end
 end
 return false
end

-->8
--overworld/pathfinding/cursor



--size of world
tilesw=32
tilesh=32
worldw=(tilesw-1)*8
worldh=(tilesh-1)*8

worldborder=8


--returns if tile p
--is adjacent to any zone in zones
function pnearzones(p,zones)
 for z in all(zones) do
  for d in all(cardinal) do
   if g(i2zone,ptadd(p,d))==z
   then return true end
  end
 end
 return false 
end

--returns if any part of obj col
--is adjacent to any zone in zones
function objnearzones(obj,zones)
 local ozones=objzones(obj)
 for z in all(zones) do
  if (has(ozones,z)) return true
 end
 
 local c=obj.col
 for cx=0,c[3]-1 do
  for cy=0,c[4]-1 do
   local x=obj.x+c[1]+cx
   local y=obj.y+c[2]+cy
   local p=pt(x,y)
   if not tile_is_solid(p) then
    if pnearzones(p,zones) then
     return true
    end
   end
  end
 end
 return false
end

function ok_to_zone(res,p)
 local i=pt2i(p)
 return res[i]==nil and
        not tile_is_solid(p) and
        not i2danger[i]
end
function floodfill(res,p,v)
 if (not ok_to_zone(res,p)) return
 s(res,p,v)
 for d in all(cardinal) do
  floodfill(res,ptadd(p,d),v)
 end
end


--return all zones adjacent 
--to obj base x,y position
--(basically just for heroes atm)
function objzones(obj)
 if (obj==nil) return {}
 
 local res={}
 for d in all(cardinal) do
  local z=g(i2zone,ptadd(obj,d))
  if z!=nil and not has(res,z)
   then add(res,z) end
 end
  
 --add zone of hero too
 local z=g(i2zone,obj)
 if z!=nil and not has(res,z)
  then add(res,z) end
 
 return res
end





--reverse lookups
--maps tile xy to obj,col,hot,etc
function create_i2tile()

 mapobj={}
--	i2obj={}
	i2col={}    --all collisions
	i2hot={}    --building activation points
	i2danger={} --mob attack squares

 for i=1,#things do
  it=things[i]
  c=it.col
  for cx=0,c[3]-1 do
   for cy=0,c[4]-1 do
    x=it.x+c[1]+cx
    y=it.y+c[2]+cy
    p=pt(x,y)
    i=pt2i(p)
    
    is_hotspot=
      x==it.x+it.hot[1] and 
      y==it.y+it.hot[2] 
      
    --map of objects
    s(mapobj,p,it)
      
    --map of hot spots
    if is_hotspot then
     i2hot[i]=true
    end
    
    --set all as solid col
    --except hot spot and mobs
    if not is_hotspot and
       it.type!="mob"
    then
     i2col[i]=true
    end
    
    --treasure is solid 
    --even on hotspot
    --(todo: cleaner way?)
    if it.type=="treasure" then
     i2col[i]=true
    end
    
    --special case for castle wings
    if it.type=="castle" and 
      ((cx==0 and cy==0) or
       (cx==4 and cy==0))
    then
     i2col[i]=nil
     s(mapobj,p,nil)
    end
    
    if it.type=="mob" then
     i2danger[i]=true
    end
    
   end
  end
 end
 
 
 --create i2zone
 
 i2zone={}
 zonecount=10
 for x=0,tilesw-1 do
  for y=0,tilesh-1 do
   local p=pt(x,y)
   if ok_to_zone(i2zone,p) then
    --start new region (floodfill it)
    floodfill(i2zone,p,zonecount)
    zonecount+=1
   end
  end
 end
 
 --make each hero their own zone too
 for plr in all(plrs) do
  for h in all(plr.heroes) do
		 s(i2zone,h,zonecount)
   zonecount+=1
  end
 end
 
end



--basically just for debug
--wrong, also for tile_is_solid
function tmap_solid(p)
 local x,y=p.x,p.y
 if x<0 or x>tilesw-1 or
    y<0 or y>tilesh-1 
 then
  return true
 end
 if fget(mget(x,y),0) then
  return true
 end
 return false
end


function tile_is_solid(p)
 if (tmap_solid(p)) return true
 if (g(i2col,p)) return true
 return false
end





function itrect(it)
 r={}
 for i=1,#it.col do 
  r[i]=it.col[i]*8
 end
 r[1]+=it.x*8
 r[2]+=it.y*8
 return r
end

things={}

function spawn(name,tx,ty)
 local res={}
 at=archetypes[name]
 for k,v in pairs(at) do
  res[k]=v
 end
 res.x=tx
 res.y=ty
 add(things,res)
 
 --set hero info
 if res.type=="hero" then
  local id=ceil(rnd(#hero_port_sprs))
  res.id=id
  res.port=hero_port_sprs[id]
  res.spr=hero_map_sprs[id]
 end
 
 --add random army
 if res.type=="hero" then
  res.army=random_starting_army()
 end
 
 if res.type=="mob" then
  res.group[2]=rnd_bw(5,9)
 end
 
 if res.type=="treasure" then
  res.amount=rnd_bw(1,4)
  if res.subtype=="gold" then
   res.amount*=50
  end
 end
 
 return res
end

function del_obj(obj)
 del(things,obj)
 
 --mob group doesn't need this 
 if obj.type=="hero" then
  del(obj_owner(obj).heroes,
     obj)
  set_sel()
 end
 
 create_i2tile()
 
end

function obj_owner(obj)
 if obj.type=="hero" then
	 for plr in all(plrs) do
	  if has(plr.heroes,obj) then
	   return plr
	  end
	 end
 end
 if obj.type=="castle" then
	 for plr in all(plrs) do
	  if has(plr.castles,obj) then
	   return plr
	  end
	 end
 end
 return nil
end



--sort table list by k element of table
function sort_by_y(t)
 for n=2,#t do
  local i=n
  while i>1 and
   t[i].y<t[i-1].y
  do
   t[i],t[i-1]=t[i-1],t[i]
   i-=1
  end
 end
end
function draw_things()
 sort_by_y(things)
 for i in all(things) do
 
  sprt=i.spr
  if i.type=="treasure" then
   sprt=res_spr(i.subtype)
  end
  
  spr(sprt,
      i.x*8+i.sprx,
      i.y*8+i.spry,
      i.sprw,i.sprh)
      
  --flash border of selected
  if ptequ(sel,i) then
   flashcols={1,1,1,13,12,13}
   pal(1,flashcols[flash(#flashcols)])
  end
      
  if i.type=="hero" then
  
   local c=obj_owner(i).color
   pal(8,c)
   spr(228,
      i.x*8+i.sprx+5,
      i.y*8+i.spry-4,
      1,1,true)
   pal(8,8)
   
   --if we don't want hero hl
--   pal(1,1)
   
   --draw hero over flag
	  spr(i.spr,
	      i.x*8+i.sprx,
	      i.y*8+i.spry,
	      i.sprw,i.sprh)
   
  end
  
  if i.type=="castle" then
   local c=obj_owner(i).color
   pal(8,c)
   spr(228,
      i.x*8+i.sprx+7,
      i.y*8+i.spry+18,
      1,1,true)
   spr(228,
      i.x*8+i.sprx+26,
      i.y*8+i.spry+18)
   pal(8,8)
  end
  
  --reset border hl
  pal()
   
 end
end



function draw_overworld()

 cls(13)
 rect(-1,-1,tilesw*8,tilesh*8,1)
 rect(-2,-2,tilesw*8+1,tilesh*8+1,1)
-- for x=camx,camx+128,8 do
--  for y=camy,camy+128,8 do
--   if x<0 or x>128 or
--      y<0 or y>128 
--   then
--    spr(112,x,y)
--   end
--  end
-- end
 
-- --border around world
-- --(see worldborder)
-- for x=0,tilesw-1 do
--  spr(97, x*8, -8)
--  spr(97, x*8, worldh+8)
-- end
-- for y=0,tilesh-1 do
--  spr(96, -8, y*8)
--  spr(96, worldw+8, y*8)
-- end
-- spr(64, -8,-8)
-- spr(65, worldw+8,-8)
-- spr(80, -8,worldh+8)
-- spr(81, worldw+8,worldh+8)


 
 map(0,0, 0,0 ,32,32)
 
 draw_things()

end




-- some debug functions

--function drawdebug_zones()
-- for i,z in pairs(i2zone) do
--  p=i2pt(i)
--  local x,y=p.x,p.y
--  rectfill2(x*8+2,y*8+2,4,4,0)
--  rectfill2(x*8+3,y*8+3,2,2,z)
-- end
--end
----for i2xxx arrays
--function drawdebug_layer(lyr,c)
-- for k,v in pairs(lyr) do
--  p=i2pt(k)
--  local x,y=p.x,p.y
--  rect2({x*8+1,y*8+1,6,6},c)
-- end
--end
--function drawdebug_tilecol()
-- for x=0,tilesw-1 do
--  for y=0,tilesh-1 do
--   if tmap_solid(pt(x,y)) then
--    rect2({x*8+2,y*8+2,4,4},6)
--   end
--  end
-- end
--end
--
--function drawdebug_things()
-- for it in all(things) do
--  
--  local r=itrect(it)
--  local bx,by=it.x*8,it.y*8
--  
--  --not-walkable space
--  rect2(itrect(it),10)
--  
--  --activation space
--  local x=bx+it.hot[1]*8
--  local y=by+it.hot[2]*8
--  rect2({x,y,8,8},8)
--  
--  --tl (reminder all rel from this)
--  rect2({bx+2,by+2,4,4},2)
--  
-- end
--end





--a* pathfinding

function map_iswall(p)
 if has2(global_walkable,p) then
  return false
 end
 if (tile_is_solid(p)) return true
 if (g(i2danger,p)) return true
end
function clear(p)
 return not map_iswall(p)
end


--manhattan distance
function map_dist(a,b)
 return abs(a.x-b.x)+abs(a.y-b.y)
end



--find all non-wall neighbours
--now returning table with 
--cost included {i,cost}
function map_neighbors(p)
 local res={}
 
 for step in all(cardinal) do
  local newp=ptadd(p,step)
  if clear(newp) then
   add(res,{newp,1})
  end
 end
 
 for step in all(diagonal) do
  --token potential
  local newp=ptadd(p,step)
  if clear(newp) 
  --prevent sneaking thru:
  and clear(ptadd(p,pt(0,step.y)))
  and clear(ptadd(p,pt(step.x,0)))
  then
   add(res,{newp,1.4})
  end
 end
 
 return res
end



--token: inline 
function pop(t)
 local v=t[#t]
 del(t,t[#t])
 return v
end


--get/set from arr using pt key
--just hashing p to i
--by limiting x,y to <255
function g(arr,p)
 return arr[pt2i(p)]
end
function s(arr,p,val)
 arr[pt2i(p)]=val
end


--input: pt(x,y) tile indices
--returns: path as list of pts
--caller should check for failure
--by checking if path=={}
--also can pass in obj to ignore
function pathfind(start,goal,obj,
 func_nei,
 func_dist)
 
 if (ptequ(start,goal)) return {}
 
 --make a kind of ok-list
 --from optional passed in obj
 --(so we can walk over our)
 --(goal collider if needed)
 global_walkable={}
 
 if obj!=nil then
  --token: func that generates
  --list of points from rect
  --and and offset point?
  c=obj.col
	 for cx=0,c[3]-1 do
	  for cy=0,c[4]-1 do
	   x=obj.x+c[1]+cx
	   y=obj.y+c[2]+cy
	   p=pt(x,y)
    add(global_walkable,p)
   end
  end
 end
 

 --list of tuples of 
 --{position,priority}
 --kept in order of priority
 frontier = {{start,0}}

 --hashtables that take pts
 --set/get with s( g(
 prev_pos = {}
 cost_so_far = {}
 s(cost_so_far,start,0)

 found_goal = false
 
 while #frontier>0 do
  if (#frontier>100) stop("a* frontier explosion")

  --[1] drops the priority
  local c=pop(frontier)[1]

----visualize search
--if in_battle then
-- x,y=gxy2sxy(c.x,c.y)
-- circfill(x+5,y+5,1,12)
-- x,y=gxy2sxy(goal.x,goal.y)
-- circfill(x+5,y+5,1,8)
-- flip()
--end

  if ptequ(c,goal) then
   found_goal=true
   break
  end

  local nearby=func_nei(c)
  for neighbor in all(nearby) do
 
   n=neighbor[1]
   ncost=neighbor[2]
 
   local proposed_cost=
    g(cost_so_far,c) +
    ncost

   existing_cost=g(cost_so_far,n)
   
   if existing_cost==nil
   or proposed_cost < existing_cost
   then
    s(cost_so_far,n,proposed_cost)
    local priority= 
     proposed_cost + 
     func_dist(n,goal)
    queue(frontier,n,priority)
    
    s(prev_pos,n,c)

   end 
  end
 end

 --caller check for empty to 
 --see if successful path found
 path={} 
 if found_goal then
  c=g(prev_pos,goal)
  while not ptequ(c,start) do
   add(path,c)
   c=g(prev_pos,c)
  end
  add(path,start)
  reverse(path)
  add(path,goal)
 end
 
 return path

end


-- add to queue in order of p
function queue(t,v,p)
 if #t>=1 then
  add(t,{})
  for i=#t,2,-1 do
   local n=t[i-1]
   if p<n[2] then --n.p
    t[i]={v,p}
    return
   else
    t[i]=n
   end
  end
  t[1]={v,p}
 else
  add(t,{v,p}) 
 end
end


function reverse(t)
 for i=1,(#t/2) do
  local temp = t[i]
  local oppindex = #t-(i-1)
  t[i] = t[oppindex]
  t[oppindex] = temp
 end
end



--cursor


function init_cursor()
	curx=64
	cury=64
	curanim=0
	cur_spr=cur_sprs.arrow --updated each frame
end

function update_move_cursor()
 local tx,ty=flr(curx/8),flr(cury/8)
 local p=pt(tx,ty)
 local i=pt2i(p)
 local obj=g(mapobj,p)
 local selzones=objzones(sel)
 
 --note the fall-thru effect here
 --later things are higher priority
 
 --first reject any out of zone
 if not has(selzones,i2zone[i]) then
  style="arrow"
  --except allow mobs/heros
  --if adjacent to zone
  if obj!=nil then
  
	  if obj.type=="mob" then
    if objnearzones(obj,selzones) then
     if pnearzones(p,selzones)
     or obj.x==tx and obj.y==ty
     then
   	  style="attack"
  	  end
	   end
	  end
	  
	  if obj.type=="hero" 
	  and objnearzones(obj,selzones)
	  and obj!=sel
	  then
 	  if obj_owner(obj)==cp then
	    style="trade"
	   else
	    style="attack"
 	  end
 	 end
	  
	  if obj.type=="treasure" 
	  and objnearzones(obj,selzones)
	  then
	   style="hot"
	  end
	  
  end
 else
  --handle in-zone things
  
  --default to walkable
  style="horse"
  
  if tile_is_solid(p) then
   style="arrow"
  end
  
  --object, but what kind?
  if obj!=nil then
	  if i2hot[i] then
	   style="hot"
	  end

  end

 end
 
 --select castles anywhere (in or out of zone)
 if obj!=nil then
  if obj.type=="castle" then
   if not i2hot[i] then --but still not this
    style="castle"
    if btnp(❎)
 	  and obj_owner(obj)==cp
 	  then
     sel=obj
    end
   end
  end
 end

 --remember obj for hud description
 if obj!=nil then
  cur_obj=obj
 else
  cur_obj=nil
 end
 
 if btnp(❎) then
  if style=="horse" 
  or style=="hot"
  or style=="attack"
  or style=="trade"
  then
   sel["movex"]=tx
   sel["movey"]=ty
  end
 end
 
 cur_spr=cur_sprs[style]
 
end

function update_sel_cursor()
 local tx,ty=flr(curx/8),flr(cury/8)
 local obj=g(mapobj,pt(tx,ty))
 if obj!=nil and obj.select then
  style=obj.type
	 if (btnp(❎)) then
	  if obj_owner(obj)==cp then
 	  sel=obj
 	 end
	 end
 else
  style="arrow"
 end
 cur_spr=cur_sprs[style]
end


function move_cursor(
 p, minx,maxx, miny,maxy)
 
 for i=0,3 do
  if btnp(i) then
   ptinc(p,cardinal[i+1])
   sfx(58,-1,1,2)
  end
 end
 p.x=mid(p.x,minx,maxx)
 p.y=mid(p.y,miny,maxy)
end

--something like this?
-- clamp(p,minx,maxx,"x")
-- clamp(p,miny,maxy,"y")
--function clamp(p,mn,mx,comp)
-- p[comp]=mid(p[comp],mn,mx)
--end

function update_cursor()

 tempp=pt(flr(curx/8),flr(cury/8))
 move_cursor(
  tempp,
  0,tilesw-1,
  0,tilesh-1)
  
 curx,cury=tempp.x*8,tempp.y*8

end

function draw_cursor()
 bb=flashamt()
 if (hud_menu_open) bb=0
 spr(cur_spr, curx,cury+bb)
end




-->8
--battle

--token potential:
--replace mob stacks
--with .name .count
--instead of [1] and [2]

function army_is_empty(army)
 for m in all(army) do
  if (m[2]>0) return false
 end
 return true
end

function cas_from_army(army)
 local res={}
 for m in all(army) do
  if m.casualties>0 then
   local c=copy(m)
   c[2]=c.casualties
   add(res,c)
  end
 end
 return res
end

function battle_end_screen(attack_won)
 
	l_cas=cas_from_army(l_cas)
	r_cas=cas_from_army(r_cas)
 
 
 diag_open=true
 diag_txt={
  "battle end",
  "",
  "casualties",
  "",
  "done"}
 while true do
  draw_dialog()
  draw_army_s(l_cas,70)
  draw_army_s(r_cas,90)
  flip()
  if btn(❎) then
   break
  end
 end
 
 diag_open=false
 
 in_battle=false
 if attack_won then
  del_obj(defenders)
 else
  del_obj(attackers)
 end
 
 --adjust mob numbers down
 --if they are still alive
 --todo: reduce tokens here
 --(and in battle start)
 --by treating mobs/armies
 --more of the same maybe??
 if defenders.type=="mob" then
  mobsleft=0
  for m in all(r_mobs) do
   mobsleft+=m[2]
  end
  defenders.group[2]=mobsleft
 end
 
end



--token: combine with other sorts?
function sort_by_speed(t)
 for n=2,#t do
  local i=n
  while i>1 and
   mob_speeds[t[i][1]]>
   mob_speeds[t[i-1][1]]
  do
   t[i],t[i-1]=t[i-1],t[i]
   i-=1
  end
 end
end

function grid_dist(c,t)

 --saves tokens
 --(though it's pretty close
 --(could save here if we can
 --(simplify the code below)
 local cx,cy=c.x,c.y
 local tx,ty=t.x,t.y
 
 count=0
 while cx!=tx do
  count+=1
  if cx<tx then
   cx+=1
  else
   cx-=1
  end
  --moving down
  if cy<ty and not evencol(cx) then
   cy+=1
  end
  --moving up
  if cy>ty and evencol(cx) then
   cy-=1
  end
 end
 return count+abs(ty-cy)
end



function valid_moves(mob)
 result={}
 speed=mob_speeds[mob[1]]
 for spot in all(grid) do
  if grid_dist(spot,mob)<speed then
   if spot_empty(spot) then   
    add(result,spot)
   end
  end
 end
 return result
end

function from_army(x,army)
 local mobs={}
 for i=1,5 do
  if army[i]!=nil then
   army[i].x=x
   army[i].y=i*2-2
   add(mobs,army[i])
  end
 end
 return mobs
end

--start/init rolled into one
function start_battle(l,r)
 in_battle=true

 --l is always hero
 --r could be hero or mob
 
 --remember so we can del loser
 attackers=l
 defenders=r


 --2-part turns: move, attack
 attack_portion=false

 
 corpses={}
 
 
 --setup armies
 
 l_mobs=from_army(0,l.army)

 
 if r.type=="hero" then
  r_hero_present=true
  r_mobs=from_army(8,r.army)
 elseif r.type=="mob" then
  r_hero_present=false
  
  mobname=r.group[1]
  mobcount=r.group[2]
	 
  split=flr(mobcount/5)
  leftover=mobcount%5
  starty=0
  count=5
  --force 3 split if group small
  --also allow small chance of
  --3 split if group not too big
  if split<2 or 
     (split<20 and rnd_bw(1,100)<20)
  then 
   split=flr(mobcount/3)
	  leftover=mobcount%3
	  starty=1
	  count=3
	 end
	 
  r_mobs={}
	 for i=0,count-1 do
 	 thisamt=split
 	 if (leftover>i) thisamt+=1
	  mobstack={mobname,thisamt}
	  mobstack.x=8
	  mobstack.y=(starty+i)*2
   add(r_mobs,mobstack)
	 end
 end
 

 --token: bake these
 --grid tile w/h (global)
 gw=10
 gh=10
 --grid start x/y (margins)
 gstart=pt(19,19)
-- gsx=(128-10*9)/2
-- gsy=(128-10*9)/2
 
 --sort mobs for turn order
 moblist={}
 l_cas={}
 r_cas={}
 for m in all(l_mobs) do
  add(moblist,m)
  add(l_cas,m)
  m.casualties=0
 end
 for m in all(r_mobs) do
  add(moblist,m)
  add(r_cas,m)
  m.casualties=0
 end
 
 --todo: make second list
 --for display, sorted by y ?
 sort_by_speed(moblist)
 
 activemob=moblist[1]
 
 
 
 --battle cursor
 --we really only want x/y 
 --from mob but it's less tokens 
 --to just copy the whole thing
 bcur=copy(activemob)
-- bcur=pt(activemob.x,activemob.y)
 
end


function get_enemies(mob)
 if (has(l_mobs,mob)) return r_mobs
 return l_mobs 
end

 
function get_neighbors(p)
 local neighbors=grid_neighbors_o
 if evencol(p.x) then
  neighbors=grid_neighbors_e
 end
 local res=copy(neighbors)
 for n in all(res) do
  ptinc(n,p)
 end
 return res
end

function adjacent_enemies(mob)
 local res={}
 
 enemy_list=get_enemies(mob)
 
 neighbors=get_neighbors(mob)
 for n in all(neighbors) do
  for m in all(enemy_list) do
   if ptequ(m,n) then
    add(res,m)
    break
   end    
  end
 end
 return res
end


--token: inline (only called once?)
function open_neighbors(p)
 local res={}
 
 neighbors=get_neighbors(p) 
 for n in all(neighbors) do
 
  --check point is on grid
  if has2(grid,n) then
   --check for obj in spot
   if not has2(moblist,n) then
 	  add(res,n)
   end
  end
  
 end
 return res
end

function evencol(x)
 return x%2==0
end
--doesn't save until we use
--"not evencol(x)" like 9 times?
--function oddcol(x)
-- return not evencol(x)
--end

function mob_move(p)

 local m=activemob
 dist=grid_dist(m,p)
 while dist>0 do
 
  path=pathfind(m,p,nil,
   b_neighbors,
   grid_dist)
  for step in all(path) do
   --token: ptset
   m.x,m.y=step.x,step.y
   wait(3)
  end
  
  dist=grid_dist(m,p)
 end
 
 attack_portion=true
 
 --skip attack portion if impossible    
 attacks=adjacent_enemies(activemob)
 if #attacks==0 then
  next_mob_turn()
 end
 
end

function mob_die(mob)

 for i=1,30 do
  local m=mob
  local sx,sy=bgrid2screen(m)
  pal(8,0)
  spr(11,sx,sy)
  pal()
  flip()
 end
 
 add(corpses,mob)
 
 if mob==activemob then
  --set activemob back one
  --so when we delete it and
  --call next_mob later, it
  --correctly goes to next mob
  --(feels like a kludge)
--	 previ=indexof(moblist,activemob)-1
--	 if (previ<1) previ=#moblist
--	 activemob=moblist[previ]
  inc_mob_turn(-1)
 end
 
 del(l_mobs,mob)
 del(r_mobs,mob)
 del(moblist,mob)
 
 --resort needed? 
 --i dont think so, del should
 --preserve order right?
-- sort_by_speed(moblist)
end

function mob_attack(pos)

 --token: potential here
 local mob=activemob
 local enemy=mob_at_pos(pos)
 
-- if enemy==nil then
--  x,y=gxy2sxy(mob.x,mob.y)
--  circfill(x+5,y+5,1,1)
--  x,y=gxy2sxy(pos.x,pos.y)
--  circfill(x+5,y+5,1,8)
--  flip()
--  stop("no enemy")
-- end
 
 
 for i=1,30 do
  local a=mob
  local sx,sy=bgrid2screen(a)
  spr(43,sx,sy)
  
  local d=enemy
  local sx,sy=bgrid2screen(d)
  spr(11,sx,sy)
  flip()
 end
 
 
 if enemy.damage==nil then
  --token: init this in init
  enemy.damage=0
 end
 enemy.damage+=mob_attacks[mob[1]]*mob[2]
 
 enemy_hp=mob_hps[enemy[1]]
 while enemy.damage>enemy_hp do
  enemy.damage-=enemy_hp
  if enemy[2]>0 then
   enemy[2]-=1
   enemy["casualties"]+=1
  end
 end
 
 if enemy[2]<=0 then
  mob_die(enemy)
 end
 
 next_mob_turn()
 
end


--right now l_mobs is assumed player
--hotseat battle support tbd
function is_player_mob_turn()
 return has(l_mobs,activemob)
end

function mob_at_pos(pos)
-- if (pos==nil) return nil --tood: could move this to ptequ?
 for m in all(moblist) do
  if ptequ(m,pos) then
   return m
  end
 end
end


--token: 
-- for all these funcs that take
-- points, check if called more
-- as x,y or as pt.. 
-- and change func to that
function spot_empty(p)
 --token: inline this?
 return not has2(moblist,p)
end


--7757
function inc_mob_turn(amt)
 local newi=
  indexof(moblist,activemob)+amt

 --token: wrapclamp( ?
 if (newi>#moblist) newi=1
 if (newi<1) newi=#moblist
 
 activemob=moblist[newi]
end

function next_mob_turn()

 --token: put this in func
 --that takes +1 or -1 as arg
-- nexti=indexof(moblist,activemob)+1
-- if (nexti>#moblist) nexti=1
-- activemob=moblist[nexti]
 inc_mob_turn(1)
 
 attack_portion=false
 
end

function update_battle()
 
 --todo: add check if
 --player won or lost?
 --(map color to player/cpu)
 if army_is_empty(l_mobs) then
  battle_end_screen(false)
  return
 end
 if army_is_empty(r_mobs) then
  battle_end_screen(true)
  return
 end
   
 attacks=adjacent_enemies(activemob)
 moves=valid_moves(activemob) 

 options=copy(moves)
 --if move mode, still allow 
 --attacks if there are any
 for a in all(attacks) do
  add(options,a)
 end
 if (attack_portion) options=attacks

 if is_player_mob_turn() then
  
  if btnp(❎) then
   if has2(options,bcur) then
    if has2(moves,bcur) then
	    mob_move(bcur)
    else
     mob_attack(bcur)
	   end
   end
   
  elseif btnp(🅾️) then
   if spot_empty(bcur) then
 	  next_mob_turn()
	  end
	 end
	 
--	 if spot_empty(bcur) then
--   display_skip_turn_msg=true
--	 else
--	  display_skip_turn_msg=false
--	 end
	 display_skip_turn_msg=
	  spot_empty(bcur)
  
 else
 
  --npc controlled mob
  
  if attack_portion
  or #attacks>0 then
   for p in all(attacks) do
    mob_attack(p)
   end
  else
	  --replace with general 
	  --prioratizing function
	  --that can be used on map too?  
	  closest_dist=1000
	  closest_spot=nil
	  enemies=get_enemies(activemob)
	  for p in all(options) do
	   for en in all(enemies) do
	   
--			  x,y=gxy2sxy(p.x,p.y)
--			  circfill(x+5,y+5,1,11)
--			  x,y=gxy2sxy(en.x,en.y)
--			  circfill(x+5,y+5,1,14)
--	    flip()
	    
	    dist=grid_dist(p,en)
	    if dist<closest_dist then
	     closest_dist=dist
	     closest_spot=p
	    end
	   end
	  end
--	  if (closest_spot==nil) stop("no closest") --todo: remove
	  mob_move(closest_spot)
  end
  
 end
 
 
-- bcur=pt(bcurx,bcury)
 
 move_cursor(bcur, 0,8, 0,9)
 if evencol(bcur.x) 
 and bcur.y>8
 then
  bcur.y=8
 end

end



function draw_battle()

	cls(3)
	
	--todo: token:
	--consider a spr2() that takes
	--a pt instead of x,y?


 --draw grid
 
 for spot in all(grid) do
  x,y=bgrid2screen(spot)
  rect2({x,y,gw+1,gh+1},11)
 end
 
 
 --todo:draw based on portrait
 --heros
 spr(hero_battle_sprs
  [attackers.id],
  2,30,2,2)
 
 if r_hero_present then 
  spr(hero_battle_sprs
   [defenders.id],
   111,30,2,2,true)
 end
 
 
 --draw corpses
 for c in all(corpses) do
  local sx,sy=bgrid2screen(c)
  pal(8,0)
  spr(11,sx+1,sy+1)
  pal(8,8)
 end
 
 
 --draw armies
 
 for m in all(moblist) do
  sx,sy=bgrid2screen(m)
  sx+=2
  sy-=gh-2
  
  
  --highlight active mob
  if m==activemob then
   flashcols={7,6,10,13,1}
   pal(1,flashcols[
    flash(#flashcols,3)])
  end   
  
  --draw mob
  spr(big_mob_sprs[m[1]],sx,sy,1,2)
  pal(1,1)
 	  
  
  
  --mob number
  ofx=0
  str=tostr(m[2])
  if (#str<2) ofx=2
  if (#str>2) ofx=1-#str
  rectfill2(sx+ofx,sy+13,4*#str,6,1)
  print(str,sx+ofx,sy+13,7)
 end
 
 
 
 --cursor
 sx,sy=bgrid2screen(bcur)
 rect2({sx,sy,gw+1,gh+1},10)
 --bounce?
-- cw,ch=gw+1,gh+1
-- ex=0
-- if (frame%10<5) c=10 ex=1 cw+=2 ch+=2
-- rect2({sx-ex,sy-ex,cw,ch},10)
 
 --draw cursor symbol
 if has2(options,bcur) then
  if has2(attacks,bcur) then
   spr(43,sx+2,sy+1+flashamt())
  else
   spr(27,sx+2,sy+1+flashamt())
  end
 end
 


 --instructions
 print("🅾️",10,121-flash(2,10),6)
 if display_skip_turn_msg then
  print("skip unit",21,120,6)
 else
  print("view unit",21,120,6)
 end
 
 print("❎",70,121-flash(2,10),6)
 print("move here",81,120,6)
 
 
 if attack_portion then
  print("attack",30,0,6)
 end


 --draw debug valid move spots
 if is_player_mob_turn() then
	 if activemob!=nil then
		 for spot in all(options) do
		  x,y=bgrid2screen(spot)
		  circfill(x+5,y+5,1,6)
		 end
	 end
 end
 
-- if path then
--  for p in all(path) do
--		  x,y=gxy2sxy(p.x,p.y)
--		  circfill(x+5,y+5,1,10)
--  end
-- end
-- print(dist,64,64,0)
 
-- if activemob!=nil then
--  eny=adjacent_enemies(activemob)
--  print(#eny,64,64)
--  i=0
--  for en in all(eny) do
--   i+=1
--   print(en[1],64,64+8*i)
--  end
-- end
 
-- --debug draw cursor coords
-- if activemob!=nil then
--  val=grid_dist(activemob,bcur)
--  cursor()
--  color()
--  print(bcurx..","..bcury)
--  print(val)
-- end
 
-- --debug display mob + turn
-- i=0
-- for m in all(moblist) do
--  print(m[1],4,60+i*8,1)
--  if m==activemob then
--   print("-",0,60+i*8,10)
--  end
--  i+=1
-- end
 	
end

function bgrid2screen(p)
 local res=pt(p.x*gw,p.y*gh)
 ptinc(res,gstart)
-- local res=pt(gsx+p.x*gw,
--              gsy+p.y*gh)
 if not evencol(p.x) then
  res.y-=gh/2
 end
 return res.x,res.y
end

----grid to screen
--function gxy2sxy(x,y)
-- if (evencol(x)) return gsx+x*gw,gsy+y*gh
-- return gsx+x*gw,gsy+y*gh-gh/2
--end



--find all non-wall neighbours
--now returning table with 
--cost included {p,cost}
function b_neighbors(p)
 local ns=open_neighbors(p)
 local res={}
 for n in all(ns) do
  add(res,{n,1})
 end
 return res
end

-->8
--dialog / hud


--dialog

function open_dialog(txt,opts)
 diag_open=true
 diag_txt=txt
 diag_opts=opts
 diag_sel=1
end
function close_dialog()
 blackout=false
 diag_open=false
end

function update_dialog()
 if diag_open then
  if (btnp(⬆️)) diag_sel-=1
  if (btnp(⬇️)) diag_sel+=1
  diag_sel=mid(diag_sel,1,#diag_opts)
 
  if btnp(❎) then
   sfx(59)
   event=diag_opts[diag_sel]
   close_dialog()
   event() --have to do this dance in case our function opens another dialog
  end
  return true
 end
 return false
end

function draw_dialog()
 if diag_open then
  maxw=0
  for l in all(diag_txt) do
   if (#l>maxw) maxw=#l
  end
  w=maxw*4+2+6
  h=#diag_txt*7+6
  x=63-w/2-3
  y=63-h/2-3
  rectfill2(x,y,w,h,6)
  rect2({x-1,y-1,w+2,h+2},0)
  x+=1+3
  y+=1+3
  for l in all(diag_txt) do
   print(l,x,y,1)
   y+=7
  end
  y-=7*(#diag_opts+1)
  spr(225,x+1+sin(t()),y+diag_sel*7-1)
 end
end




--hud



lsel="no obj"
function select(obj)
 sel=obj
 if (obj==nil) return
 if sel!=lsel then
	 curx,cury=sel.x*8,sel.y*8
	 if sel.type=="castle" then
	  curx+=2*8
	  cury+=3*8
	 end
	 camx,camy=curx-64,cury-64
	 --update_camera()
	 --update_move_cursor()
 end
 lsel=sel
end


menuselx=0
menusely=0
targ_menu_y=0
actl_menu_y=0
ports={}
function update_hud()

 if hud_menu_open then
  actl_menu_y+=flr(16-actl_menu_y)/3
 else 
  actl_menu_y+=flr(0-actl_menu_y)/3
 end
 

 ports={}
 i=1
 for c in all(cp.castles) do
  add(ports,c)
  if (sel==h) selport=i
  i+=1
 end
 for h in all(cp.heroes) do
  add(ports,h)
  if (sel==h) selport=i
  i+=1
 end

 if hud_menu_open then
	 if (btnp(⬇️)) menudown=true sfx(60)
	 if (btnp(⬆️)) menudown=false sfx(60)
	 if menudown then
	  if (btnp(⬅️)) menusel-=1 sfx(60)
	  if (btnp(➡️)) menusel+=1 sfx(60)
	  menusel=mid(menusel,1,#buttons)
	 else
	  if (btnp(⬅️)) selport-=1 sfx(60)
	  if (btnp(➡️)) selport+=1 sfx(60)
	  selport=mid(selport,1,#ports)
	 end
	 
  select(ports[selport])
 
  if btnp(❎) then
   if menusel==4 and menudown then
    sfx(59)
    local askturn=false
    for h in all(cp.heroes) do
     if h.move>0 then
      askturn=true
      break
     end
    end
    if askturn then
     open_dialog({
      "one of your heroes",
      "can still move.",
      "are you sure you",
      "want to end your turn?",
      "   yes",
      "   no"},{
      end_turn,
      close_dialog})
    else
     end_turn()
    end
   end
  end
 
 end --end menu open chek
 
end


function draw_hud()

 --top bar
 
 --color banner
 pal(8,cp.color)
 spr(244,0,9)
 pal(8,8)
 
 
 d_res_bar()
 
 
 --map item description
 if cur_obj then
 
  --text descrip
  
  if cur_obj.type=="hero"
  or cur_obj.type=="castle"
  then
   map_desc=
    colorstrings[obj_owner(cur_obj).color]
    .." "..cur_obj.type
    
  elseif cur_obj.type=="mob" 
  then
   stack=cur_obj.group
   map_desc=vague_number(stack[2])
    .." "..stack[1]
    .." ["..stack[2].."]"
    
  elseif cur_obj.type=="treasure" 
  then
   map_desc=cur_obj.subtype
    
  else
   map_desc=cur_obj.type
  end
  
  local x=63-#map_desc*2
  local y=118
  local w=#map_desc*4+1
  
  if cur_obj.army then
   draw_army_s(cur_obj.army,y-5)
   y-=14 --move text up
  end
  rect2({x-1,y-1,w+2,9},1)
  rectfill2(x,y,w,7,6)
  print(map_desc,x+1,y+1,1)
 end
 
 
 --portrait bar
 
-- drawlist=compile_to_list(ports)
-- auto_draw(drawlist)
 
-- for p in all(ports) do
--  p.w=8
-- end
-- draw_big_list(ports,9)
 
 local w=#ports*10
 local x,y=63-w/2,9
 rectfill2(x,y,w,10,6)
 for i=1,8 do
  p=ports[i]
  if p!=nil then
   d_port(p,x,y)
   
   --flashing selection box
			if p==sel then
			 rect2({x,y,10,10},12)
			 if hud_menu_open and 
			    not menudown then
			  bb=flashamt()
			  rect2({x-bb,y-bb,10+bb*2,10+bb*2},10)
			 end
			end
		
   x+=10
  end
 end
 
 
 --menu
 
 clip(0,0,128,18+actl_menu_y)
 mw=0
 for b in all(buttons) do 
  mw+=#b*4+4
 end
 mh=9
 mx=63-mw/2
 my=19--actl_menu_y
-- rectfill2(mx,my,mw,mh,6)

 --bottom buttons
 local x,y=mx+1,my+1
 local count=1
 
 draw_btn_list(buttons,y)
 
 clip()
 
 
 --right sidebar: army
 
 if actl_menu_y>0 then
  d_army(sel,130-actl_menu_y,21)
 end
-- d_army(sel,128-10,21)
 

end




function draw_btn_list(list,y)

-- dlist=compile_to_list(list)
-- auto_draw(dlist)

-- draw_big_list(list,y)

 local w=0
 for text in all(list) do
	 w+=text_box(text,200,0)
	end
	x=63-w/2
 for text in all(list) do
	 x+=text_box(text,x,y)
	end
end

function text_box(text,x,y)
 local w=#text*4+3
 rect2({x-1,y-1,w,9},1)
 rectfill2(x,y,w-2,7,6)
 print(text,x+1,y+1,1)
 return w
end



function flashamt()
-- if (frame%10<5) return 0
 return flash(2,5)-1
end

--counts from 1 to amt, change every f frames
function flash(amt,f)
 f = f or 5 --default value
 for i=1,amt do
  if (frame%(amt*f)<i*f) return i
 end
end


function res_spr(n)
 return res_sprs[
  indexof(res_names,n)]
end
function d_res_bar()

 rectfill2(0,0, 128,9, 6)
 
 for i=1,#res_names do
  local name=res_names[i]
  res_spr(name)
	 local x = 17*i-9
	 if (name=="gold") x=0
	 spr(res_spr(name),x,0)
	 print(cp[name],x+9,2,0)
	end
end



function vague_number(amt)
 --7936 (inc data)
 for i=1,8 do
  if amt<group_numbers[i] then
   return group_names[i]
  end
 end
 return "a legion of"

 --7953
-- if (amt<5) return "a few"
-- if (amt<10) return "several"
-- if (amt<20) return "a pack of"
-- if (amt<50) return "lots of"
-- if (amt<100) return "a horde of"
-- if (amt<250) return "a throng of"
-- if (amt<500) return "a swarm of"
-- if (amt<1000) return "zounds... "
-- return "a legion of"
end


function d_port(p,x,y)
 
	palt(0,false)
	spr(p.port,x+1,y+1)
	palt(0,true)
	
	--move bar
	if p.type=="hero" then
	 local lx=x+1
	 local ly=y+8
	 line(lx,ly,x+8,ly,6)
	 if p.move>0 then
	  line(lx,ly,lx+p.move/100*7,ly,11)
	 end
	end
	
	--blue border
	if p==sel then
	 rect2({x,y,10,10},12)
	end
   
end

--token: remove and just
--draw all armies horizontal
function d_army(obj,x,y)

 local arm=obj.army
 
 rectfill2(x,y,10,14*6,6)
 
 d_port(sel,x,y)

 --army  
 x+=1
 y+=10
 for mob in all(arm) do
  spr(mob_sprs[mob[1]],x,y)
  
  local str=tostr(mob[2])
  local ofx=0
  if (#str>2) ofx=-3*(#str-2)
  print(str,x+ofx,y+8,0)
  y+=14
 end

end



function draw_window(x,y,w,h)
 rectfill2(x+1,y+1,w-2,h-2,6)
 rect2({x,y,w,h},1)
end


function draw_big_mob(m,x,y)
-- rectfill2(x,y,16,20,14)
 spr(big_mob_sprs[m[1]],
     x+4,y+2,1,2)
     
 str=tostr(m[2])
 ofx=0
 if (#str<2) ofx=2
 if (#str>2) ofx=1-#str
 rectfill2(x+4+ofx,y+2+13,4*#str,6,1)
 print(str,x+4+ofx,y+2+13,7)
end





function draw_army_b(hero,y)

 draw_window(9,y,110,24)
 
 sx=11
 sy=y+2
 
 draw_window(sx,sy,16,20)
 spr(hero_bport_sprs
  [hero.id],
  sx+4,sy+5,1,1)
 sx+=18
 
 for i=1,5 do
 
  draw_window(sx,sy,16,20)
  
  m=hero.army[i]
	 if m!=nil then
	  draw_big_mob(m,sx,sy)
  end
  sx+=18
 end

end




function draw_army_s(arm,y)

 local w=52
 local x=39
 draw_window(x-2,y-2,w,16)
 for i=1,5 do
  local mob=arm[i]
  if mob!=nil then
	  spr(mob_sprs[mob[1]],x,y)
	  local str=tostr(mob[2])
	  local ofx=0
	  if (#str<2) ofx=2
	  if (#str>2) ofx=-3*(#str-2)
	  print(str,x+ofx,y+8,0)
  end
  x+=10
 end

-- --7980 (orig)
-- local w=10*5
-- x=63-w/2
-- rect2({x-1,y-1,w+2,16},1)
-- rectfill2(x,y,w,14,6)
-- x+=1
-- y+=1
-- for mob in all(arm) do
--  spr(mob_sprs[mob[1]],x,y)
--  local str=tostr(mob[2])
--  local ofx=0
--  if (#str<2) ofx=2
--  if (#str>2) ofx=-3*(#str-2)
--  print(str,x+ofx,y+8,0)
--  x+=10
-- end

 if #arm==0 or arm==nil then
  print("none",57,y+4,1)
 end

end

-->8
--data


function init_data()


 --pretty much just for
 --checking if p is on grid?
	grid={}
	for x=0,8 do 
	 for y=0,8 do
	  add(grid,pt(x,y))
	  if not evencol(x) then
	   add(grid,pt(x,y+1))
	  end
	 end
	end

 
	cardinal={
		pt(-1,0),
		pt( 1,0),
		pt(0,-1),
		pt(0, 1),
	}
	
	diagonal={
		pt(-1,-1),
		pt( 1,-1),
		pt(-1, 1),
		pt( 1, 1),
	}
	
	
	group_numbers={
	 5,10,20,50,100,250,500,1000
	}
	group_names={
		"a few",
		"several",
		"a pack of",
		"lots of",
		"a horde of",
		"a throng of",
		"a swarm of",
		"zounds... ",
	}

	mob_sprs={
	 ["goblins"]=194,
	 ["skeletons"]=210,
	 ["calavry"]=197,
	 ["elves"]=213,
	 ["peasants"]=229,
	}

 --menu
 
	--menu buttons 
	buttons={
	 "map",
	 "dig",
	 "spell",
	 "end turn",
	}
	menusel=4
	
	
	res_names={
	 "gold",
	 "wood",
	 "ore",
	 "sulfur",
	 "crystal",
	 "gems",
	 "mercury",
	}
	res_sprs={
	 242,
	 195,
	 211,
	 227,
	 243,
	 196,
	 212,
	}

	--token: probably a better way
	-- to generate these
	grid_neighbors_e={
	 pt(-1,0),
	 pt(-1,1),
	 pt(0,-1),
	 pt(0,1),
	 pt(1,0),
	 pt(1,1),
	}
	grid_neighbors_o={
	 pt(-1,-1),
	 pt(-1,0),
	 pt(0,-1),
	 pt(0,1),
	 pt(1,-1),
	 pt(1,0),
	}



	--cursor sprites
	cur_sprs={
	 ["castle"]=145,
	 ["hero"]=161,
	 ["arrow"]=208,
	 ["horse"]=177,
	 ["hot"]=192,
	 ["trade"]=224,
	 ["attack"]=240,
	}
	
	--mob stats
	
	big_mob_sprs={
	 ["goblins"]=34,
	 ["skeletons"]=1,
	 ["peasants"]=33,
	 ["elves"]=2,
	}
	
	mob_speeds={
	 ["goblins"]=4,
	 ["skeletons"]=4,
	 ["peasants"]=2,
	 ["elves"]=5,
	}
	
	mob_attacks={
	 ["goblins"]=4,
	 ["skeletons"]=4,
	 ["peasants"]=2,
	 ["elves"]=5,
	}
	
	mob_hps={
	 ["goblins"]=4,
	 ["skeletons"]=6,
	 ["peasants"]=1,
	 ["elves"]=7,
	}


 --other
	
	resources={
	 "gold",
	 "wood",
	 "ore",
	 "gems",
	 "sulfur",
	 "mercury",
	 "crystal",
	}
	
	
	colorstrings={
	 [8]="red",
	 [10]="yellow",
	 [11]="green",
	 [12]="blue",
	}
	
	
	--hero info
	--hero type/person is id'd
	--by the index into these
	--eg heroid=3 is index 3 in all
	
	hero_port_sprs={
	 201,217,233
	}
	hero_bport_sprs={
	 201,217,233
	}
	hero_map_sprs={
	 66,25,14
	}
	hero_battle_sprs={
	 44,12,46
	}
	
	
	
	// note activation spot (hot)
	// is relative to the x,y pos
	// not the collider (col) pos
	archetypes={
	 ["castle"]={
	  ["type"]="castle",
	  ["select"]=true,
	  ["port"]=202,
	  ["spr"]=137,
	  ["sprx"]=0,
	  ["spry"]=0,
	  ["sprw"]=5,
	  ["sprh"]=4,
	  ["col"]={0,1,5,3},
	  ["hot"]={2,3},
	 },
	 ["hero"]={
	  ["type"]="hero",
	  ["select"]=true,
	  ["id"]=1,
--	  ["port"]=201,
--	  ["spr"]=66,
	  ["sprx"]=-4,
	  ["spry"]=-4,
	  ["sprw"]=2,
	  ["sprh"]=2,
	  ["col"]={0,0,1,1},
	  ["hot"]={-100,-100},
	  ["move"]=100,
	  ["army"]={
	   {"calavry",20},
	   {"elves",40},
	   {"peasants",250}
	  },
	 },
	 ["testhouse"]={
	  ["type"]="testhouse",
	  ["spr"]=142,
	  ["sprx"]=0,
	  ["spry"]=0,
	  ["sprw"]=2,
	  ["sprh"]=2,
	  ["col"]={0,0,2,2},
	  ["hot"]={1,1},
	 },
	 ["mob"]={
	  ["type"]="mob",
	  ["spr"]=194,
	  ["sprx"]=0,
	  ["spry"]=0,
	  ["sprw"]=1,
	  ["sprh"]=1,
	  ["col"]={-1,-1,3,3},
	  ["hot"]={0,0},
	  ["group"]={"goblins",40}
	 },
	 ["mob2"]={
	  ["type"]="mob",
	  ["spr"]=210,
	  ["sprx"]=0,
	  ["spry"]=0,
	  ["sprw"]=1,
	  ["sprh"]=1,
	  ["col"]={-1,-1,3,3},
	  ["hot"]={0,0},
	  ["group"]={"skeletons",15}
	 },
	 ["gold"]={
	  ["type"]="treasure",
	  ["subtype"]="gold",
	  ["amount"]=rnd_bw(1,4)*50,
	  ["spr"]=242,
	  ["sprx"]=0,
	  ["spry"]=0,
	  ["sprw"]=1,
	  ["sprh"]=1,
	  ["col"]={0,0,1,1},
	  ["hot"]={0,0},
	 },
	}
	
	--dup some similar archetypes
	for r in all(resources) do
	 if r!="gold" then
	  archetypes[r]=copy(archetypes.gold)
	  archetypes[r].subtype=r
	 end
	end
	
	

end
__gfx__
00000000000000001111000000000000001d11110011110000000000000000000000000000000000000000008800008800000011110000000000001111000000
0000000011111000133111000000000000199121011bb10000000000000000000000000000000000000000000880088000000117711111100000011771000000
007007001777110013333110000000001119922211bbb11100000000000000000000000000000000000000000088880000000175511444110000017170000000
00077000170701001333331000000000526d62121bb111710000000000000000000000000000000000000000000880000000017dd14455410000017771111000
000770001777110015ff111000000000526662111bbbb61100000000000000000000000000000000000000000088880000000177714511510000011111171100
007007001111100011ff651100000000122222101bbb6110000000000000000000000000000000000000000008800880000001cc665555550000012271775110
00000000177710001333615100000000121112101b161100000000000000000000000000000000000000000088000088011111cc66555d55000111227d777710
00000000176610001333615100000000111111101b1b100000000000000000000000000000000000000000000000000011551ccc665ddd11001172227d7d1710
00000000167710001333615100000000013311000011110000000000000000000000000000000011110000000011110014551ccccddd5110001672222ddd1110
0000000017661000133365110000000001333111001761110000000000000000000000000000015551000000001ff100145511ccc555d1000016772227511000
00000000167711001333111000000000015f1751011661710000000000000000000000000000022991000000001ff100141551ccc551d1000016750227511000
000000001611610015115100000000000133171511161171000000000000000000000000000001d991111000111f11111415511cc151d1000011755117551000
0000000017117100151151000000000001331715167766d10000000000000000000000000000019dd11711001f1f11f111151d111151d1100001771117711000
0000000017117110151151100000000001331751117661110000000000000000000000000000015541755110111ff11100151dd10151dd100000111011110000
00000000167167101551551000000000015151110161610000000000000000000000000000011155447777101ff1f11000155111015511100000000000000000
00000000111111101111111000000000015151000161610000000000000000000000000000117555467667101f11ff1000111100011110000000000000000000
00000000000000000000000000000000001111000000000000000000000000000000000000167555566611100000111100000011110000000000001111000000
00000000000000000000000000000000001ff100000000000000000000000000000000000016775557d1100000011ff100000117711111100000011771000000
00000000000000000000000000000000011ff1000000000000000000000000000000000000167d0557d110001111fff100000175511666110000017551011110
00000000001111100000000000000000014111000000000000000000000000000000000000117dd117dd10001f1fff110000017dd16677610000017dd1117711
00000000001fff1000111110000000000144100000000000000000000000000000000000000177111771100011fff110000001777167dd71000001777117dd71
00000000011fff11001bbb11000000000144110000000000000000000000000000000000000011101111000011ff1100000001cc667777710000012241771761
00000000114fff66011b3b310000000001f1f1000000000000000000000000000000000000000000000000001f11f100011111cc66777d710111112244771171
000000001444115111bbbb110000000001f1f1000000000000000000000000000000000000000000000000001111110011771ccc667ddd1111771222447ddd11
0000000014f411511bbb111600000000000000000000000000000000000000000000000000111100001111000011110016771ccccddd71101677122224dd7110
00000000144fff511b3bb161000000000000000000000000000000000000000000000000001ff100111ff111001ff100167711ccc777d100167711222777d100
00000000144441511bb33611000000000000000000000000000000000000000000000000001f111111fff1f1001f1100161771ccc771d100161771222771d100
00000000144441511bbb6110000000000000000000000000000000000000000000000000111ff1f11f1fff11111ff1111617711cc171d100161771122171d100
000000001f111f111b11b1000000000000000000000000000000000000000000000000001f1ff111111f11101f1ff1f111171d111171d11011171d111171d110
000000001f111f111b11b110000000000000000000000000000000000000000000000000111f1110111ff110111ff11100171dd10171dd1000171dd10171dd10
000000001ff11ff11bb1bb100000000000000000000000000000000000000000000000001ff11f111ff11f111ff1f11000177111017711100017711101771110
0000000011111111111111100000000000000000000000000000000000000000000000001f1111f11f1111f11f11ff1000111100011110000011110001111000
66666666666666660000001111000000000000000000000000030000300003301111111111111111000000003399993300000111100000000000001111000000
66666666666666660000011771000000000011110000000000330003330003301dddddddddddddd1000000003399999300001177100000000000011771000000
66666666666666660000017551000000000117710000000003303303030033301df66ff66ff66fd1000000003999999300001755100111100000017551011110
66666666666666660000017dd1111000000175511110000033000b30003b30031dff66ff66ff66d10000000039999993000017dd101177110000017dd1117711
6666666666666666000001777117110000017dd1171100000000bbb000b3b0031d6ff66ff66ff6d100000000339993330000177711177771000001777117dd71
66666dddddd66666000001cc617551100001777175511000000bb0bb0bb00b001d66ff66ff66ffd1000000003335533300001cc611771771000001cc61771761
66666d1111d66666000111cc667777100111cc67777710000003003b333003001df66fddddf66fd1000000003315513311111cc661771171011111cc66771171
66666d1111d6666600117ccc66766710117ccc667667100000330303330003301dff66d11dff66d100000001331111331771ccc66176661111771ccc66766611
66666d1111d6666600167cccc6661110167cccc66611100003333333303033331d6ff6d11d6ff6d1000000000000d0007771cccc1667111016771cccc6667110
66666d1111d66666001677ccc7d110001677ccc7d110000003333330033b30031d66ffdddd66ffd1000000000209900077711ccc17711000167711ccc777d100
66666dddddd6666600167d0cc7d11000167d0cc7d11000000033bb0003bbb0001df66ff66ff66fd1000000002229900071771ccc11710000161771ccc771d100
666666666666666600117dd117dd1000117dd117dd100000000bbbb00bbbbb001dff66ff66ff66d1000000002126d625717711cc117100001617711cc171d100
66666666666666660001771117711000017711177110000000bbbbbbbbbbbb001d6ff66ff66ff6d10000000000266625117111111171000011171d111171d110
66666666666666660000111011110000001110111100000000bbbbbbbbbbbb001d66ff66ff66ffd10000000000222220017110000171100000171dd10171dd10
66666666666666660000000000000000000000000000000000000000000000001dddddddddddddd1000000000121112101771000017710000017711101771110
66666666666666660000000000000000000000000000000000000000000000001111111111111111000000000111111101111000011110000011110001111000
66666d11666666660000001111000000000000000000c00033999933333333331d6ff6d1111111110000000033b333b33b3b3b3bb333b3333b333b3377cccc77
66666d11666666660000011771000000000077000000c00033999993333333331d66ffd1dddddddd000000003b3b3b3bbbbb3bbb3b333b33b3b3b3b37cc7777c
66666d11666666660000017551011110000755000000c00039999993333999931df66fd16ff66ff600000000b333b3b33b3b3b3b33b333b33b3b3b3b7777cc77
66666d11666666660000017dd11177110007dd000700c00039999993333999931dff66d166ff66ff000000003b3b3b3bbbbbbbbb333b333b33b333b3ccc77ccc
66666d1166666666000001777117dd71000777007550c00033999333bb3999931d6ff6d1f66ff66f0000000033b333b33b3b3b3bb333b3333b333b3377cccc77
66666d11dddddddd000001cc61771761000cc6677777c00033354444bbb399931d66ffd1ff66ff66000000003b3b3b3b3bbbbbbb3b333b33b3b3b3b37cc7777c
66666d1111111111011111cc6677117167ccc6677667c00033154444bbb444431df66fd1dddddddd00000000b3b3b3333b3b3b3b33b333b33b3b3b3b7777cc77
66666d111111111111771ccc6676661167cccc766600c00033114444bbb444431dff66d111111111000000003b3b3b3bbbbbbbbb333b333b33b333b3ccc77ccc
ddddd61ddddddddd16771cccc6667110677ccc77d000c000333339999b344443f66ff6661111111100000000b3b3b3b3b3b3b3b3b333b333b333b333cccccccc
dd66d11ddddddddd167711ccc777d10067d0cc07d000c00c3333999999224233ff66ff661d111111000000003b3b3b3b3333b3333b333b3333b333b377cc77cc
d611ddddddd66ddd161771ccc771d10007dd0c07dd00c0c033229999992222336ff66ff6111111d100000000b3b3b3b3b3b3b3b3333b333b33333333cc77cc77
d1dddddddddd11dd1617711cc171d100077000077000cc003222229b3322223366ff66ff11111111000000003b3b3b3b3333333333b333b333333333cccccccc
ddddd1dddddddddd11171d111171d110ccccccccccccc000322223bbb3322333f66ff66f1111d11100000000b3b3b3b3b3b3b3b3b333b333b333b333cccccccc
ddd661ddd666dddd00171dd10171dd100c00000000000000322233bbbb353333ff66ff661d111111000000003b3b3b3bb33333333b333b3333b333b377cc77cc
dd111dddd111dddd001771110177111000c00000000000003355333bb33533336ff66ff61111111100000000b3b3b3b3b3b3b3b3333b333b33333333cc77cc77
dddddddddddddddd0011110001111000000c000000000000335533353333333366ff66f6111111d1000000003b3b3b3b3333333333b333b333333333cccccccc
00000000b333b333b333b3333333bbb334debbb3333a9a9333bbbb33b333b3333333333300000000000000000000110000000000000000000000000000000000
0111111033b333b333b333b33ddbbb6bddedd3bb339999a93b3b3bb3333333b33333333300000000000000000001111000000000000000000000000000000000
01f11f103333333333333333ddbbbbb64dddeb3b3399a9993b3b3b3b336333333333333300000000000000000011111100000000000000000000009999000000
011ff1103333333333333333ddbbbbbb4ddedbbb33999a9a3b3b3b3b3111333333333333000000000000000000dddddd00000000000000000000999994990000
011ff110b333b333b333b333dd33bbb344dddbb3111999933b3b3b3bb33336333333333300000000000000000007777000000000000000000099999114999900
01f11f1033b333b333333333dddbbbb3145d151331115533311b3b1133b3111333333333000000001d10000000067070000000000000000000ee99999999ff00
011111103333333333bbbb331513151311511113331155133111511133333d63333333330000000011101dd10007776000001dd10000000000eeee9999ffff00
00000000333333333b3b3bb31113111331113333333111133311111333331111333333330000000006701111000667701d1011110000000000eeeeeeffffff00
00000000000000003b3b3b3b3333a9a9333336333333363333399333b333b333b333b333000000000760077000076660111007700000000000e1deeeffffff00
00011100111111113b3b3b3b3339999a93333d6333333d6333999a333333336333b333b3000000000770066000077770077006700000000000e1deeeffffff00
0011f1101f1ff1f1bb3b3b3b33349a99aa9a3dd3aa9a3dd333b99933336363333333333300000001dd111771101dddd1067007600000000000e11eeefffd1f00
001fff101ffffff1b3bb3b3b333499a9aa9a3dd3aa9a3dd33bbb9aa3363333633333d633000000011110766777111111176117700000000000eeeeeeffdd1f00
001111101ffffff1b3b3bb3b31114999aa993533aa99353313bb9aa333363633333dd66300000007dd37766777777777777777700000000000eeeeeeffdd1f00
0001f1001ff11ff13113b31133111553a999a533a999a533133b99a3b3333363311d66630000007553333b1111777666677777700000000001eeeeeeffdd1f00
0001f10011111111311151133331bb511539aa331539aa3311511513336363333311111300000655533b3b5551166771177111d7700000001111eeeeff110000
000111000000000033111113333bbb1115199a3315199a33311115133333333333333333000006555b33b377666661666776113377000000011111eeff000000
00000000111001113333333333bbbbb31111bbb3111469d333333333b333b33333333333000006bb5333dd3dddd161ddddd61333370000000000000000000000
001110001f1111f13333333311b3bb9aa33bbbbb333dd36d3333333333333363333333330000067bbb3ddd1d1d11611d1d13b775570000000000000000000000
011f11111f1ff1f133333333311b3b99a9a3bbbba9add1d633333333336363b33d663333000006677bbd2d1d1d1ddd1d1d1b3555770000000000000000000000
01ff1ff111ffff11333333333311539aa9aa3bbba9a6d3dd33333333363b3b63111113330000067667777711111d661111133777770000000000000000000000
011f11111ffffff13333333333315399a99a333b999ad3dd3333333333b63633333dd33300000666777766677766dd6777677777660000000000000000000000
001110001ffffff13333333333311139399915339999135333333333b333b36333111133000016776666776777ddd6d777676666770000000000000000000000
00000000111111113333333333333115399915131995115333333333336363b3333333330001366677776667176d6dd71767777777b000000000000000000000
0000000000000000333333333333333311531113151333333333333333333333333333330013b677667777676766d6d76767666777b000000000000000000000
1111100001110000333333333333a9a9111d63d3111333d3333333333333333333333333013b3b667776666777d6dd67776777777bbb00000000000000000000
1fff100011f10000333333333339999a3336d36da331d36d33333333333333333333366301b3b3bbbb777767776d66d7776667bbbbbbb0000000000000000000
1f1110001ff111103333333333349a99a9ad61d6a9add1d633333333333333333333dd661b3b3bbbbbbb333777d67667776bbbbbbbbbb0000000000000000000
1f1000001f1fff1133333333333499a9a9ad63dda9aad3dd33333333333333333311d66613b3b3bbbbbbb333bb667773bbbbbbbbbbbbb0000000000000000000
11100000111ffff13333333331114999999ad3dda99ad3dd333333333333333333d66111013b3bbbb3bbbbbbbb766763bbbbbbbbbbbb00000000000000000000
0000000001f11ff133333333331115539999135339991353333333333333333333dd6333001bbbbbbb33bbbbb76677673bbbbbbbbb0000000000000000000000
0000000001f11f11333333333331bb5119951153399511513333333333333333111111330000000bbbbbbbbbb667767673bbbbbb000000000000000000000000
000000000111111033333333333bbb111513333311533333333333333333333333333333000000000000bbbb6666666663bbb000000000000000000000000000
0111100001111000001111000001111100000000001d11110000000000000000000000000dddddd0eeeeeeee0000000000000000000000000000000000011100
11ff100011ff1000011bb100011155510111111000199121000000000000000000000000dddffdddeee11eee000000000000000000000000000000000011f110
1fff11001fff111111bbb1110144551101681a1011199222000000000000000000000000dfffffdde1e661ee00000000000000000000000000000000001fff10
111ff110111ffff11bb111711144115101881111526d6212000000000000000000000000d1f11fdde61617110000000000000000000000000000000001111110
11ffff11001ffff11bbbb61114115551111111c1526662110000000000000000000000000fffffd0116676670000000000000000000000000000000001fff100
1f11fff1001111111bbb6110144455111c16b11112222210000000000000000000000000ddddff00676116670000000000000000000000000000000001111100
11111f11001f11f11b16110011441110111bb181121112100000000000000000000000000ffff000676116670000000000000000000000000000000000000000
00001110001111111b1b100001111000001111111111111000000000000000000000000000000000333333330000000000000000000000000000000000000000
0000000011f110000011110000000000000000000133110000000000000000000000000002222280000000000000000000000000ffffffff0000000000111111
011111001fff10000017611100111000001110000133311100000000000000000000000022111288000000000000000000000000fbbffbbf00011100001ffff1
01fff100111f110001166171016d111000151000015f175100000000000000000000000029999128000000000000000000000000fbbbbbbf0001f11000111ff1
01ff1100111ff1101116117101dd1d10011d11000133171500000000000000000000000009191928000000000000000000000000ffbbbbff1111ff110011f1f1
01f1f11001ffff10167766d11111111111ddd1100133171500000000000000000000000009999912000000000000000000000000ffbbbbff1ffffff1011ff1f1
01111f1001f1ff101176611116d16dd117766610013317510000000000000000000000000dddd912000000000000000000000000fbbbbbbf1ff1ff1111ff1111
0000111001111110016161001dd1dd1116666610015151110000000000000000000000000d11d812000000000000000000000000fbbffbbf1111f1101ff11000
0000000000001f10016161001111111011111110015151000000000000000000000000000dddd822000000000000000000000000ffffffff0001110011110000
011100000111000000000000000000000011110000111100000000000000000000000000111111100000000000000000ffffff0000fff0001111100011111111
11f1111001f11000111111100011110000188111001ff100000000000000000000000000166666110000000000000000fbbbbf000ffbffff1fff10001ff11ff1
1ff1ff1001ff11001aba2c110116a11000188881011ff100000000000000000000000000116116610000000000000000fbbbff00ffbbbbbf1f11100011ffff11
11f1111101fff100118cb8a1116aa9110018811101411100000000000000000000000000116116610000000000000000fbbbbff0fbbbbbbf1f100000011ff110
01111f1101ff11004111111119aaa9910011110001441000000000000000000000000000161666610000000000000000fbfbbbffffbbbbbf11100000011ff110
01ff1ff101f1100044994491199999410011000001441100000000000000000000000000166666110000000000000000ffffbbbf0ffbffff0000000011ffff11
01111f110111000014999991114444110011000001f1f100000000000000000000000000116161100000000000000000000ffbff00fff000000000001ff11ff1
000011100000000011111111011111100011000001f1f1000000000000000000000000000111110000000000000000000000fff0000000000000000011111111
00000111000000000000000000010000188888100000000000000000000000000000000000000000000000000000000000fff000000fff001111001111100111
000011f100000000000111000017100018888810000000000000000000000000000000000000000000000000000111110ffbf00000ffbff01ff111ff1f1111f1
11111ff1000000000111a1100017e100188888100000000000000000000000000000000000000000000000000111c7c1ffbbffff0ffbbbff11ff1ff111f11f11
1f11ff110000000001a19a111017e1101888881000000000000000000000000000000000000000000000000001b17cc1fbbbbbbf0fbbbbbf0111ff11011f1110
11fff110000000001179a9a1111ee1e1188188100000000000000000000000000000000000000000000000001111ccc1fbbbbbbf0ffbbbff011ff1110111f110
11ff11000000000019aa9a9117e117e11810181000000000000000000000000000000000000000000000000017811111ffbbffff00fbbbf011ff1ff111f11f11
1f11f10000000000119aa11111ee171111000110000000000000000000000000000000000000000000000000188179100ffbf00000fbbbf01ff111ff1f1111f1
11111100000000000111110001111110100000100000000000000000000000000000000000000000000000001111111000fff00000fffff01111011111100111
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000101010100000000000000000000000101010101000000000000000000000000010101000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7e7e7e7e847e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e83857e877e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
858483977e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e858485837e7e877e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e827e7d7d7e84837e837e7e7d7d7e7e7d7e7e7e7d7e7e7d7e7e7e7e7d7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e927e7e7e7e7e8485847e7e7e7e7e7e7d7e7e7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e867e7e7e7e7e7e7e7ea77e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7d7e7e7e7e7e7e7e7e987e7d7e7e7e7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7ea77e7e7eb87e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7d7e7e7e7e7e7e7d7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7d7e7d7d7e7e7e7ea87e7e7e7e977e7e6e7e7e7e6e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7d7e7e7e7e977e7e7e7e7e7ea87e7e7e7d7e6e6e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7d7d877e7e7e7e7d6e6e6e6e7e7e7e6f6f7f7f7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7d7e7d7d7e7e7e7d7e7e7e6e6e6e6e7d7e7e6f6f6f7f7f7f7f7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e6e6e6e6e6e6e7e7e6f6f6f7f7f7f7f7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7d847e7e7e7e857e7e7e7e7e7e7e7d6e7e6e7d7e6f6f6f7f7f7f7f7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e83857e7e7e83847e7e7e7e7e7e7e7e7e7d7d7d7e7e6f6f7f7f7f7e7e7e7e7e7e7e7e7e7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7d7e84837e7e7e7e867e7d7e7e7e7e7e7e7e7e7e7e867e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7d7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e8586847e7e847e7e7e7e7e7e7e7e7d7e7e7e7e7e7e868686868686867e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7d7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e867e857e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e867e7e7e7e7e867e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e837e7e867e7e7e7e7e7e7e7e7e7e7e86868686867e7e7d7e7e867e7e7e7e7e7e7e7d7e7d7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7d7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e857e7e7e7e837e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e867e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e84867d857e7e7e7e7d7e7e7e7e7e7e86868686867e7e7e7e7e867e7d7e7d7e7e7e7e7e7e7e7e7e7e7e7d7e7e7d7e7e7e7e7e7e7e7e7e7e7d7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7d7e7e7e837e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e867e7d7e7e7e867e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e867e7e7e7e7e867e7e7e7e7e7d7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7d7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e867e7e7e7e7e867e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e868686868686867e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7d7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7d7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7d7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01120000135501355516555165051a5551a505165550f500135501355516555165051a5551a505165550f500135501355516555165051a5551a505165550f5000f5500f55513555135001a5551a5001355513500
01120000165501655518555185051d5551d50518555185050e5500e555135551350518555185051355513505125501255516555165051b5551b50516555165050c5500c555125551250516555165051255512505
011200000e5500e5551255512500155551550012555125000c5500c555125551250015555155001255512500165551750013555005000e55500500135550050007555005000e555005000b555005000e55500500
011200000c5550000016555000001355500000165550000011555000001855500000145550000018555000000b555000000e5550000014555000000e555000000f55500000135550000017555000001355500000
011200000e55500000155550000018555000001a55500000155550000016555000001355500000115550000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0112000000000000000000000000000000000000000000001f0001f0001f00021000220002200022000240001f0501f0501f0501f0501f0501f0501f050210502205022050220502205022050220502205024050
011200002205022050210502105022050220501f0501f050210502105021050210502105021050210502205021050210501f0501f05021050210501d0501d0501f0501f0501f0501f0501f0501f0501f0501e050
011200001a0401a0401a0401a0401a0401a0401a0401a0401a0401a0401a0401a0401a0401a0401a0401a04022040220402204022040220402204022040240402604026040260402604026040260402604027040
011200002604026040240402404026040260402204022040240402404024040240402404024040240402604024040240402204022040240402404020040200401f0401f0401f0401f0401f0401f0401f0401f040
011200001e0401e0401e0401e0401e0401e0401e0401e0401e0401e0401e0401e0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200001a7001a7001a7001a7001a7001a7001a7001a7001a7001a7001a7001a7001a7001a7001a7001a7002673026730267302673026730267302673027730297302973029730297302973029730297302b730
011200002973029730277302773029730297302673026730277302773027730277302773027730277302973027730277302673026730277302773024730247302673026730267302673026730267302673025730
011200001a7301a7301a7301a7301a7301a7301a7301a7301a7301a7301a7301a7300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001e51023520285502853026500285002a5002c5002f5003250036500005000050000500005002150022500235002550026500285002a5002c5002f5003250036500005000050000500005000050000500
00020000095200d550115500050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100000b5500d5500e5500e55012500135001c500245000c5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100001e5400050031500235000f5001150015500155001b5001c5001d500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000130601206011050100400f0300d0200b0200901008010070100601006000060000c0000b0000a00008000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000075500f550165501e55024540305303a5503e55022500275002950029500275002750024500225001f5001b5001b5001850016500165001f500005000050000500005000050000500005000050000500
0002000009030090300a0400b0400c0500e0500f06010000130001500000000100000f0000c0000b0000a00008000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 010b4344
00 020c4344
00 030d1744
00 040e1844
00 050f1944

