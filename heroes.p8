pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


--player ai todos:
---improve fog-reveal ai:
--  -maybe ai (harder difficulty?) can see whole map? 
--  -balance multiple heroes (partially done, any special handling needed?)
--  -when revealing fog, only move as close as needed to reveal it
---only battle if ai thinks it can win
---evaluate when to pickup units and how to distribute them

--todo:


--big todos:
--player select/multiplayer support
--castles
--main menu/level select
--hero experience
--spells
--battle debris / scenery
--search for todo keyword


--token saving:
--append lists function?
--compress data
--switch x,y to pt (rects too?) partially done
--improve state switching? partially done
--consolidate hud rendering? tried and failed
--areas marked "token"
--spr functions, eg spr_mirx(id,x,y), spr_pal(spr,x,y,c1,c2)?
--tile spr func? (with mirror?)
--would making col into obj save? (we removed col all together)
--and make hot into pt? (other similar things? spr stats?)
--consider a 1-level deep copy for copying lists of pointers?
--maybe passing in list instead of returning one?
--change obj.type to int instead of string index



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
 lp=cp
 cp=p
 
 --player whose fog is visible
 --(current player if not ai
 --(otherwise, last player)
 --consider making blackout
 --for all ai turns if two players
 vp=cp
 if (cp.ai) vp=lp --comment out to watch ai turn
 
 --reset for this turn
 for h in all(cp.heroes) do
  h.move=100
 end
 
 --setup portrait bar, basically
 update_static_hud()
 
 hud_menu_open=false
 actl_menu_y=0

  
 --a bit awkward, but we need
 --to update fog before tiles
 update_fog()
 
 --and need to set sel after fog
 --since whether we snap cam
 --depends on if in fog or not
 set_sel()
 
 --and set sel and fog before
 --we create our tiles/reachable area
 create_i2tile()
 

 if cp.ai then
  return
 end
 
  
 --player controlled turn
 
 blackout=true

 open_dialog({
   colorstrings[cp.color].." player's turn",
   "   ok"
  },{
   close_dialog
  })
  
end


function random_starting_army()
 return {
  ms("peasants",rnd_bw(10,20)),
  ms("elves",rnd_bw(5,10)),
 }
end


function _init()
-- music(0)
 srand(2)
	
	cam=pt(0,0)

 init_data()
 
 --init cursor
 cur=pt(8,8)

 
 blackout=true
 
 red_plr=create_player(8)
 green_plr=create_player(11)
 blue_plr=create_player(12)
 
 green_plr.ai=true
 
 plrs={
  red_plr,
  green_plr,
  blue_plr
 }
 
 
 
 tc=spawn("castle",3+2,5+2)
 red_plr.castles[1]=tc
 tc.army=random_starting_army()
 red_plr.heroes[1]=
 	spawn("hero",tc.x,tc.y+1)
 red_plr.heroes[2]=
 	spawn("hero",tc.x-5,tc.y+2)
 	
 tc=spawn("castle",26,4)
 tc.army=random_starting_army()
 green_plr.castles[1]=tc
 green_plr.heroes[1]=
 	spawn("hero",tc.x,tc.y+1)
 green_plr.heroes[2]=
 	spawn("hero",tc.x-5,tc.y+2)
 	
 --test castle attack/walk-in
-- tc2=spawn("castle",3+6,5+2)
-- tc2.army=random_starting_army()
-- green_plr.castles[2]=tc2
 	
 tc=spawn("castle",20,22)
 tc.army=random_starting_army()
 blue_plr.castles[1]=tc
 blue_plr.heroes[1]=
 	spawn("hero",tc.x,tc.y+1)
 	
 
 set_player(red_plr)
 
 
	spawn("mine_gold",13,8)
	spawn("mine_gems",15,8)
	spawn("mine_sulfur",17,8)
	spawn("mine_ore",19,8)
	spawn("mine_mercury",10,10)
	spawn("mine_wood",11,6)
	spawn("mob",6,14)
	spawn("mob2",13,14)
	spawn("mob2",6,18)
	spawn("gold",2,1)
	spawn("gold",7,16)
	spawn("gold",8,16)
--	spawn("gold",6,10)
	
	--in gob danger
	spawn("gems",6,13) --(can't pickup)
	spawn("gems",7,14) --(can pickup)
	spawn("gems",5,14) --left
	
--	--near enemy
	spawn("mob2",26,8)
--	spawn("gold",28,6)
--	spawn("mine_ore",30,8)
	
	--in corner of castle
	spawn("mercury",3,5)
	
	--above gold near gobs
	spawn("gems",7,15)
	
	--block grove
--	spawn("ore",22,20)
--	spawn("mob2",22,20)

	--block hero in castle test
--	spawn("ore",5,9)
	
 
 --do once here so we don't
 --randomly spawn anything
 --over anything else
 create_i2tile()
 
 do_grid(tilesw-1,function(p)
	 if not tile_is_solid(p) 
--	 and not g(i2hot,p)
	 then
	  if rnd_bw(1,100)<4 then
	   r=rnd_bw(1,7) --#resources
	   spawn(res_names[r],p.x,p.y)
	  end
	 end
	end)
	
	
 --after populating map
 --(and whenever anything moves)
 create_i2tile()
	
end


function create_player(c)
 --tokens: use . isntead of []
 --or return {[""]=} format?
 local res={}
 res.color=c
 res.gold=200
 res.wood=10
 res.ore=10
 res.gems=5
 res.sulfur=5
 res.mercury=5
 res.crystal=5
 
 res.heroes={}
 res.castles={}
 
 res.ai=false
 
 res.fog={}
-- do_grid(tilesw+30,function(p)
--  ptinc(p,pt(-15,-15))
 do_grid(tilesw-1,function(p)
  s(res.fog,p,true)
--  s(res.fog,p,false)
 end)
   
 return res
end


function split_update()
	
	amt=1
	if (btn(🅾️)) amt=5
	
	if btnp(⬅️) 
	and movingmob.count>amt
	then
	 movingmob.count-=amt
	 splitmob.count+=amt
	end
	if btnp(➡️)
	and splitmob.count>amt
	then
 	--todo: token: func here?
	 movingmob.count+=amt
	 splitmob.count-=amt
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
 spr(49,55,70,1,1,true)
 spr(49,63,70)
 
 --todo: need this still?
 --feels better tahn bottom ui
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
   elseif mob.id==movingmob.id then
    bar.army[tcur.x].count+=movingmob.count
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
	   and splitmob.count>1 then
			  splitval=1
			  splitmob.count-=splitval
			  movingmob=copy(splitmob)
			  movingmob.count=splitval
			  
			  main_update=split_update
			  main_draw=split_draw
			  
			 end
		 end
  end
 end
 
end

function trade_draw()

 map_draw()
 
  
 draw_army_b(trade_a,60)
 
 draw_army_b(trade_b,85)
 
 
 text_box("done",58,110)
 
 
 if movingmob!=nil then
  draw_big_mob(movingmob,
   tcur.x*18+13,
   tcur.y*28+30+flashamt())
 end
 
 --draw cursor
 spr(48,
     tcur.x*18+22,
     tcur.y*28+46+flashamt())
 
 --draw instructions?
 
end


function pickup(obj)
 --should only get here 
 --with type==treasure
 if (p_can_see(obj)) sfx(57)
 resstr=res_names[obj.subtype]
 if has(res_names,resstr) then
-- if obj.subtype<=7
  cp[resstr]+=obj.amount
 end
 del(things,obj)
end
    
function move_hero()
 moving=true
end
function move_hero_tick()

 if sel.move>0
-- and path[1]!=nil
 and #path>0
 then
  
  local p=path[1]
  local obj=g(mapobj,p)
	 del(path,p)
	  
  --always move if open space
  if not tile_is_solid(p) then
			--token:ptset()?
			sel.x=p.x
			sel.y=p.y
			sel.move-=5
			if (sel.move<0) sel.move=0
			--lock cam to hero?
			if p_can_see(sel) then
				sfx(58,-1,1,1)
				cam=copy(sel)
				limit_camera()
			end
			update_fog()--make sure to do even for ai
  end
 
  --special case for obj in p
  if obj!=nil then
   --token: try array of functions
   --instead of if statements?
   if obj.type=="hero" then
    if obj_owner(obj)==cp then
     --todo: ai support for trade?
	    hero_trade(sel,obj)
	   else
     start_battle(sel,obj)
    end
   elseif obj.type=="mob" then
    start_battle(sel,obj)
   elseif obj.type=="treasure" then
    pickup(obj)
   elseif obj.type=="mine" then
    obj.owner=cp
   else
    --add other obj here
   end
   sel.movep=nil
   moving=false
   create_i2tile()
  else
   --(obj==nil)
   local mob=g(i2danger,p)
   if mob then
    start_battle(sel,mob)
   end
  end
 
 else
  sel.movep=nil
  create_i2tile()
  moving=false
 end
 
end

function limit_camera()
 
 --make sure cam follows enemy hero
 if (cp.ai) cur=copy(sel)
 
 --tokens: common limit func?
 cam.x=mid(cam.x,
           cur.x-4,
           cur.x+4)
 cam.y=mid(cam.y,
           cur.y-4,
           cur.y+4)
end

function ai_tick()

 --todo: consider: instead of
 --searching every frame, maybe
 --create list of dist/values 
 --when floodfilling region?
 --(basically calc dist to every space?)

 --basic ai value function
 --combine with battle?
 ltarget=nil
 for h in all(cp.heroes) do
  if h.move>0 then
   
   --first make list of
   --fog frontier
   
   --do here so we don't have
   --to re-create this every
   --time we blacklist something
   local fog_edge={}
   do_grid(tilesw-1,function(p)
    if not g(cp.fog,p) then
     --only use spots adjacent to fog
     for d in all(cardinal) do
      if g(cp.fog,ptadd(p,d)) then
       add(fog_edge,p)
       break --only bother with first adjacent fog square
      end
     end
    end
   end)
   
   
   local blacklist={}
   ::search_for_obj::
   
   --find closest object
	  local min_dist=0x7fff --max signed int
	  local target=nil
   for t in all(things) do
    if not has2(blacklist,t)
    and obj_owner(t)!=cp
    and not ptequ(h,t)
    and not g(cp.fog,t)
    and t!=ltarget
    then
	    --todo: eval targets by value?
	    --todo: euclidean dist?
	    local dist=map_dist(h,t)
	    if dist<min_dist then
	     min_dist=dist
	     target=t
	    end
	   end
   end
   
   --(if no objects, 
   -- target will be nil
   -- at this point)
   
   --compare all fog spots
   --to our closest obj (target)
   
   --note we inherit 
   --target / min_dist 
   --from above
   --(their value here is important)
   for spot in all(fog_edge) do
    local dist=0
    for piece in all(cp.castles) do
     dist+=map_dist(piece,spot)
--          *map_dist(piece,spot)
    end
    if dist<min_dist
    and not has2(blacklist,spot) --could blacklist points too
    then
     min_dist=dist
     target=spot
    end
   end

   --in case no fog to reveal
   --and no objs to go to
   if target==nil then
    cls(7)
    stop("castle target")
    
    --todo:pick better default?
    target=cp.castles[1]
   end
   
   if target==ltarget then
    cls(7)
    stop("same target?")
    
    --if same target,
    --at this point,
    --is only possible
    --if fallback to castle
    --and already in castle
    --(i think)
    --so just don't move
    goto skip_hero
    
   end
   ltarget=target
   
   --move to new target
   sel=h
   create_path(target)
   if #path<1 then
    --seems to occur when
    --no path can be found
    --eg mine is visible,
    --but front is covered in fog
    --sometimes [nil] ???
--    cls()
--    stop("unable to path to "..target.type)
    
    --todo: should still move
    --towards obj if in fog?
    --but not if blocked by obj
    
    --if can't path to obj,
    --blacklist it and search again
    add(blacklist,target)
    goto search_for_obj
   end
    
   move_hero()
   ::skip_hero::
   
  end
 end
 
 --bug:
 --don't do this if we're
 --in a battle with player,
 --until the battle is over
 
 --using "moving" as flag here
 --to see if we still have
 --a hero with movement
 --(less tokens than another var)
 if not moving then
  end_turn()
 end
 
end


function p_can_see(p)
 return not g(vp.fog,p)
end


function update_map()
 
 if moving then
  if p_can_see(sel) then
   if frame%5==0 then --token (use flash?)
    move_hero_tick()
   end 
  else
   move_hero_tick()
  end
 else
 
  --only choose new action
  --if not already moving
  --(could change to make
  -- better at adapting)
	 if cp.ai then
	  ai_tick()
	 end
	 
 end
 
 
 --now using ports for fog too
 --(ai doesn't need this except
 -- for updating fog)
 update_static_hud()
 
 --note relies on ports
 --from update_static_hud()
 update_fog()
 
 
 --feels like there should be
 --a better way to do this
 if cp.ai then
  return
 end
 
 
 --open/close menu
 if (btnp(🅾️)) then
  hud_menu_open=not hud_menu_open
  if hud_menu_open then
   sfx(63)
   
   --basically hud_menu_init()
   topc=pt(selport,1)
   hudtop=true

  else 
   sfx(61) 
  end
 end
 

 --always update, so we 
 --animate open/close 
 animate_hud_menu()

 if hud_menu_open then
  update_hud_menu_cursor()
 else
  update_map_cursor()
 end
 
 
end


--ideally this doesn't need
--to be a function, but for
--now just calling it before
--create_i2tile when setting player
--since create_i2 needs updated fog
function update_fog()

 --update fog of war
 for thing in all(ports) do
  --token: something like this?
  --(if int index, might work)
--  sizes.castle=5
--  sizes.hero=4
--  size=sizes[thing.type]

  local size=4
  if thing.type=="castle" then
   size=5
  end
 
  do_grid(size*2,function(p)
   ptinc(p,pt(-size,-size))
   if abs(p.x)+abs(p.y)<size*2-1 then
    s(cp.fog,
     ptadd(p,thing),
     false)
   end
  end)
  
 end
 
end


function update_map_cursor()

 --update cursor
 move_cursor(
  cur,
  0,tilesw-1,
  0,tilesh-1)
 
 
 limit_camera()
 
 if sel!=nil
 and sel.type=="hero" 
 then
  if btnp(❎)
  and path!=nil
  and ptequ(path[#path],cur)
  then
   move_hero()
  end
 end
 update_cursor_spr()

 --tokens here? this feels awkward
 if sel!=nil 
 and sel.movep!=nil
 then
  if not ptequ(sel.movep,
               path[#path])
  then
   create_path(sel.movep)
  end
 end
 
end


function create_path(p)
 path=pathfind(
  sel,
  p,
  map_neighbors,
  map_dist)
 del(path,path[1]) --token?
end


frame=0
function _update()

 frame+=1
 
 --true if open
 if update_dialog() then
  return
 end
 
-- if in_battle then
--  cur_obj=nil --todo: better place for this
--  update_battle()
--  return
-- end




 if main_update!=nil then
  main_update()
 else
  update_map()
 end
 
 
end









function map_draw()

 	camera(cam.x*8-64,cam.y*8-64)
	
	 draw_overworld()
	 
	 
	 --draw path
	 --7861 (both ways)
	 --tokens? change nx,dx to pts?
	 if path!=nil and #path>0 
	 and not cp.ai --turn off to see ai path
	 then
--	  lx,ly=sel.x,sel.y
	  local l=copy(sel)
		 for i=1,#path do
--		  nx,ny=path[i].x,path[i].y
		  local n=copy(path[i])
		  local dx,dy=n.x-l.x,n.y-l.y
		  if dx==0 then
		   if (dy<0) sprt=16 yflip=false
		   if (dy>0) sprt=16 yflip=true
		  else
		   if (dx<0) sprt=32 xflip=false
		   if (dx>0) sprt=32 xflip=true
		  end
		  if (i==#path) sprt=0
	 	 spr(sprt,n.x*8,n.y*8,1,1,xflip,yflip)
--		  lx,ly=nx,ny
    l=copy(sel)
		 end
	 end
	 
	 	 
--	 drawdebug_reach()
--	 drawdebug_zones()
--	 drawdebug_layer(i2danger,8)
--	 drawdebug_layer(i2hot,11)
--	 drawdebug_layer(i2col,10)
	 
	 
	 
	 --fog only inside borders
  do_grid(tilesw-1,function(p)
   if g(vp.fog,p) then
	   drw_bspr(162,p)
   end
	 end)
	 
	 
	 --the rest is for player's only?
	 if cp.ai then
	  
	  camera()
	  
	  text_box(
	   colorstrings[cp.color].. 
    " player's turn",
    65,100,true)
    
   rectfill2(58,90,11,9,1)
   rectfill2(59,91,9,9,6)
   spr(224-1+flash(7,4),60,92)
--   spr(248-1+flash(8,4),60,92)
	  
	  return
	 end
	 
	 
	 if not hud_menu_open then
 	 draw_cursor()
	 end
	 
	 
	 --hud elements
	 color()
	 cursor()
	 camera()
	 
	 
 	draw_static_hud()
 	
 	--draw even when closed,
 	--so we animate closing
  draw_hud_menu()
  
  if not hud_menu_open then
   draw_cur_popup_info()
  end
  
  
	 --when switching players
	 --(so no hidden info revealed)
	 if blackout then
	  do_grid(16,function(p)
	   drw_bspr(162,p)
		 end)
		end
	 
 	
-- 	print("cpu "..stat(1),0,64,0)
 	
end


function _draw()
 
--	if in_battle then
--  draw_battle()
-- else
 
  if main_draw!=nil then
   main_draw()
  else
   map_draw()
  end

-- end 
 
	 
	draw_dialog()
	
	--cpu
--	print(stat(1),0,64)
	
end




function end_turn()
 menudown=false
 path=nil
 
 --income from mines
 for t in all(things) do
  if t.type=="mine"
  and t.owner==cp
  then
   local resnmae=res_names[t.subtype]
   t.owner[resnmae]+=mine_incs[t.subtype]
  end
 end
 
 --tokens
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
 --if only call with init pts,
 --dont need this nil check.
 --but looks like making sure 
 --pts are init is taking more
 --tokens than just checking here
 
 --a and b -> nil if either is
 --not x   -> true if nil else false
 if (not (a and b)) return false
 return a.x==b.x and a.y==b.y
end

function ptadd(a,b)
 return pt(a.x+b.x, a.y+b.y)
end

function ptinc(p,amt)
 --not this because p might be 
 --a full obj (not just a pt)
 --(or a shared ptr)
 --(todo: test this? could save 4 tokens)tadd(p,amt) 

 p.x+=amt.x
 p.y+=amt.y
end

function pt(x,y)
 return {x=x,y=y}
end


--hash pt for use as keys
--assumes x,y are 2 byte ints
--(signed, so approx +/-32,000)
--packs y into the decimal bits
--recall pico numbers are stored
--like so: 1:15:16 sign:whole:decimal
function pt2i(p)
 return bor(p.x,lshr(p.y,16))
end
--function i2pt(i)
-- local x=band(i,0b1111111111111111)
-- local y=band(i,0b0000000000000000.1111111111111111)
-- y=shl(y,16)
-- return pt(x,y)
--end






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



function rect2(x,y,w,h,c)
 c=c or 10 --default val
 rect(x,y,x+w-1,y+h-1,c)
end


function rectfill2(x,y,w,h,c)
 if w>0 and h>0 then
  rectfill(x,y,x+w-1,y+h-1,c)
 end
end



----drop shadow print
--function print2(str,col)
-- local cursor_x=peek(0x5f26)
-- local cursor_y=peek(0x5f27)
---- if (col==nil) col=7
-- col=col or 7 --default val
-- print(str,cursor_x+1,cursor_y+1,0)
-- print(str,cursor_x,cursor_y+1,0)
-- print(str,cursor_x,cursor_y,col)
-- poke(0x5f27,cursor_y+6)
--end


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



--todo: change name to id?
function ms(name,count)
 return {
  id=indexof(mob_names,name),
  count=count
 }
end


--a bit of a convoluted way
--to save a few tokens
--when iterating over an area
function do_grid(size,f)
 for x=0,size do
  for y=0,size do
   f(pt(x,y))
--   f(x,y)
  end
 end
end




--draw sprite id at tile pos p
--with black color visible
function drw_bspr(id,p)
-- palt(0,not binvis)
 palt(0,false)
 spr(id,p.x*8,p.y*8)
 palt(0,true)
end


-->8
--overworld/pathfinding/cursor



--size of world
tilesw=32
tilesh=32


--used for creating valid
--reachable spots for pathfinding
function floodfill2(res,p)
 
 --force any danger zone spot
 --to stop filling (lets us
 --get one square into danger)
 local mob=g(i2danger,p)
 
 --try to do this here? tokens
-- s(res,p,mob?"attack:"horse")
 
 if mob then
  s(res,p,"attack")
  s(res,mob,"attack") --but also add that mob
  return
 end
 
 --might be overridden in cursor
 s(res,p,"horse")
 
 for d in all(cardinal) do
  local testp=ptadd(p,d)
  if tile_is_solid(testp) 
  or g(res,testp) --dont add duplicate pts
  or g(cp.fog,testp) --dont walk through fog
  then
  else
   floodfill2(res,testp)
  end
  
  --add adjacent objects
  local obj=g(mapobj,testp)
	 if obj!=nil
  --todo: are we adding
  --duplicate spots here?
  --(if we reach obj from 2 places)
	 and obj_interactable(obj)
	 --we don't need to check if
	 --this obj is only accessable
	 --from danger zone, bc danger
	 --has early exit above
  then
   s(res,testp,obj.type)
  end
	 
 end
end



--reverse lookups
--maps tile xy to obj,col,hot,etc
function create_i2tile()

 --could try i2* as lists
 --intead of maps,
 --however if i2reachable is
 --any indication, we need the
 --faster access that maps have

 --not i2col and i2danger
 --now map to their obj
 
 mapobj={}  --rename back to i2obj?
	i2col={}    --all collisions
	i2danger={} --mob attack squares

 for it in all(things) do

  --8047
--  spots={
--   mob=eightway,
--   castle=castle_col,
--   mine=mine_col}
--  i2={
--   mob=i2danger,
--   castle=i2col,
--   mine=i2col}
--  maybemap={
--   mob={},
--   castle=mapobj,
--   mine=mapobj}
--  if has(it.type,spots) then
--		 for n in all(spots[it.type]) do
--		  local p=ptadd(it,n)
--		  s(i2[it.type],p,true)
--		  s(maybemap[it.type],p,it)
--		 end
--  end

  s(mapobj,it,it)
   
  --8046
  spots={}
  i2={}
  maybemap={}
  if it.type=="mob" then
   spots=eightway
   i2=i2danger
   s(i2col,it,true)
  elseif it.type=="castle" then
   spots=castle_col
   i2=i2col
   maybemap=mapobj
  elseif it.type=="mine" then
   spots=mine_col
   i2=i2col
   maybemap=mapobj
  else 
   s(i2col,it,true)
  end
  for n in all(spots) do
   local p=ptadd(it,n)
   s(i2,p,it)
   s(maybemap,p,it)
  end
  
 end
 
 --create reachable zone
 --(for selected object)
 
 --better to have i2reachable
 --be i2* style (a table)
 --or just list of coordinates?
 --more tokens to do table
 --(7977 vs 7991)
 --but we need the faster runtime
 --access with g() vs has()
 
 --valid for selected hero only
 --need check if sel nil here?
 i2reachable={}
 
 --fill empty space
 --also grabs mobs adj to space
 --stops on first danger square
 if sel.move then 
  --note only create reachable
  --area when sel hero
  floodfill2(i2reachable,sel)
 end
 
end

function obj_interactable(o)
 return o.type=="hero" or
        o.type=="mob" or
        o.type=="treasure"
end

--basically just for debug
--wrong, also for tile_is_solid
function tmap_solid(p)
 local x,y=p.x,p.y
 --feels like tokens here
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



--function itrect(it)
-- r={}
-- for i=1,#it.col do 
--  r[i]=it.col[i]*8
-- end
-- r[1]+=it.x*8
-- r[2]+=it.y*8
-- return r
--end

things={}

--token: split into diff funcs
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
 
 --todo: maybe have random
 --mob of different level
 --or specific mob of type/amt
 if res.type=="mob" then
  res.group.count=rnd_bw(5,9)
 end
 
 if res.type=="treasure" then
  res.amount=rnd_bw(1,4)
  if res.subtype==1 then --gold
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
 --tokens: just check both always
 --check ports somehow instead?
 if obj.type=="mine" then
  return obj.owner
 end
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


--for about 30 tokens we
--can make heros draw over
--nearby objects.. is it worth it?
function hero_adjust(t,amt)
 for obj in all(t) do
  if obj.type=="hero" then
   obj.y+=amt
  end
 end
end

--sort table list by k element of table
function sort_by_y(t)
 
 --awkward hack to force hero
 --to draw over near objects
 hero_adjust(t,0.2)
 
 for n=2,#t do
  local i=n
  while i>1 and
   t[i].y < t[i-1].y
  do
   t[i],t[i-1]=t[i-1],t[i]
   i-=1
  end
 end
 
 hero_adjust(t,-0.2)
 
end


function draw_flag(i,x,y,f)
	pal(8,obj_owner(i).color)
	spr(56,
	   i.x*8+i.sprx+x,
	   i.y*8+i.spry+y,
	   1,1,f)
	pal(8,8)
end


function draw_overworld()


 --border around world
 cls(13)
 rect(-1,-1,tilesw*8,tilesh*8,1)
 rect(-2,-2,tilesw*8+1,tilesh*8+1,1)

 
 map(0,0,0,0,32,32)
 
 
 
 --draw_things()--
 
 sort_by_y(things)
 --tokens: this seems like it could be simplified?
 for i in all(things) do
 
  sprt=i.spr
  if i.type=="treasure" then
   sprt=res_sprs[i.subtype]
  end
  if i.type=="mob" then
   sprt=mob_sprs[i.group.id]
  end
  
  --prevent bleeding into border
  --if pos is covered by fog
  --todo: is pos enough to check?
  if g(vp.fog,i) then
   --note clip isn't affected by
   --camear(), so we have to 
   --awkwardly offset it ourselves
   
   --tokens: this one call is 36 (22 now)
   --(try tl cam pos again? would only save 4 tokens?)
   --(try tl cam in real x,y? would save 12)
   clip(-cam.x*8+64,
        -cam.y*8+64,
        tilesw*8,
        tilesh*8)
  end
  
  spr(sprt,
      i.x*8+i.sprx,
      i.y*8+i.spry,
      i.sprw,i.sprh)
      
  if i.type=="mine" then
   --tokens: make {7,2} list and use has() (here and elsewhere)
   if i.subtype!=7
   and i.subtype!=2
--   if i.subtype!="mercury"
--   and i.subtype!="wood"
   then
    --minecart resource
    spr(res_sprs[i.subtype],
      i.x*8-5,
      i.y*8-5)
    --minecart over top resource
    spr(214,
      i.x*8-8,
      i.y*8,
      2,1)
   end
   --mine owner flag
	  if i.owner!=nil then
	   draw_flag(i,13,3,false)
	  end
  end
      
  --flash edge of selected
  if ptequ(sel,i) then
   flashcols={1,1,1,13,12,13}
   pal(1,flashcols[flash(#flashcols)])
  end
      
  if i.type=="hero" then
   draw_flag(i,5,-4,true)
   
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
   draw_flag(i,7,18,true)
   draw_flag(i,26,18,false)
  end
  
  pal()  --reset spr edge hl
  clip() --reset border fog clip
 end

end




---- some debug functions
--function drawdebug_reach()
-- for i,v in pairs(i2reachable) do
---- for p in all(i2reachable) do
--  if v then
--   p=i2pt(i)
--   rectfill2(p.x*8+2,p.y*8+2,4,4,0)
--   rectfill2(p.x*8+3,p.y*8+3,2,2,11)
--  end
-- end
--end
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
--  rect2(x*8+1,y*8+1,6,6,c)
-- end
--end
--function drawdebug_tilecol()
-- for x=0,tilesw-1 do
--  for y=0,tilesh-1 do
--   if tmap_solid(pt(x,y)) then
--    rect2(x*8+2,y*8+2,4,4,6)
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
--  rect2(x,y,8,8,8)
--  
--  --tl (reminder all rel from this)
--  rect2(bx+2,by+2,4,4,2)
--  
-- end
--end





--a* pathfinding

--global_walkable={}
--global_goal=pt(-100,-100)
function map_iswall(p)
 if (g(cp.fog,p)) return true
 
 if (ptequ(p,global_goal)) return false

 if (tile_is_solid(p)) return true
 
 if not attacking_mob then
  if (g(i2danger,p)) return true
 end
 
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



--todo: del returns val now?
--can replace this with that?
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


--input: pt(x,y) tile positions
--returns: path as list of pts
--caller should check for failure
--by checking if path=={}
--also can pass in obj to ignore
function pathfind(start,goal,
 func_nei,
 func_dist)
 
 
 --reset these
--	global_goal=pt(-100,-100)
 local targ=g(mapobj,goal)
	attacking_mob=
	 targ!=nil and
	 targ.type=="mob"
 global_goal=goal
	 
	 
 if (ptequ(start,goal)) return {}
 
 
	 
 
 
 

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
  if #frontier>1000 then
   cls()
   stop("a* frontier explosion")
  end

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


function update_cursor_spr()
 local obj=g(mapobj,cur)
 
 local obj_and_friend=
  obj and
  obj_owner(obj)==cp
 
 --tokens: just set directly
 cur_obj=obj

 --goal: only get obj here
 --or in floodfill, not both
 --goal2: combine this with
 --updt_sel_cur (eg no i2reachable)
 
 style=g(i2reachable,cur)
 
 --i2reachable is set
 --in floodfill and could be
 --any obj.type 
 --or "attack" (if danger/mob)
 --or "horse" if empty space
 --or nil if not reachable
 
 if style==nil then 
  style="arrow"
  if obj_and_friend then
   style=obj.type
		 if (btnp(❎)) then
	 	 select(obj)
		 end
  end
 elseif style=="hero" then
		if obj_and_friend then
		 style="trade"
		 if obj==sel then
		  style="hero"
		 end
		else
		 style="attack"
		end
	elseif style=="horse" then
	 if obj!=nil then
 	 style="hot"
 	 
 	 --kind of special case
 	 --for attacking enemy castles
 	 --note: i don't think we need
 	 --to actually check if castle
-- 	 if obj.type=="castle"
			if not obj_and_friend 
			and obj.army
			then
			 style="attack"
			end
			
 	end
 end
 
 
 local walkable={
  "horse",
  "hot",
  "treasure",
  "attack",
  "trade",
 }
 if btnp(❎) 
 and has(walkable,style) 
 then
  if on_hot then
	  --kludge to pass goal
	  --obj to pathfind
	  --(to know if it's a mob)
   cur=copy(obj)
  end
  sel.movep=copy(cur)
 end
 
 cur_spr=cur_sprs[style]
 
end


function move_cursor2(p,maxx)
 move_cursor(p,1,maxx,1,1)
end
function move_cursor(
 p, minx,maxx, miny,maxy)
 
 for i=0,3 do
  if btnp(i) then
   ptinc(p,cardinal[i+1])
   sfx(58,-1,1,2)
  end
 end
 --20 extra tokens and we could
 --add uneven limit to x
-- if type(maxx)=='table' then
--  p.x=mid(p.x,minx,maxx[p.y])
-- else
--  p.x=mid(p.x,minx,maxx)
-- end
 p.x=mid(p.x,minx,maxx)
 p.y=mid(p.y,miny,maxy)
end

--something like this?
-- clamp(p,minx,maxx,"x")
-- clamp(p,miny,maxy,"y")
--function clamp(p,mn,mx,comp)
-- p[comp]=mid(p[comp],mn,mx)
--end


function draw_cursor()
 bb=flashamt()
 if (hud_menu_open) bb=0
 spr(cur_spr, cur.x*8,cur.y*8+bb)
end




-->8
--battle


--we now have a current_team
--pointer to a team object...
--teams are aaa and bbb
--(aaa: l side/attacker)
--(bbb: r side/defender) 
--each has what's needed 
--as well as .enemy 
--(to get the opposite team)
--it works pretty well to
--satisfy our earlier goals:
--
--need to clarify:
--attacker / defender
--current turn / opposite
--player vs ai control
--mob vs army vs hero vs player


function open_battle_menu()
 open_dialog({
  "--battle menu--",
  "   skip turn",
  "   cast spell",
  "   retreat",
  "   surrender",
 },{
  next_mob_turn,
  close_dialog,
  ask_retreat,
  ask_surrender,
 })
end


function ask_retreat()
 open_dialog({
  "are you sure",
  "you want to retreat?",
  "   yes",
  "   no",
 },{
  retreat,
  open_battle_menu,
 })
end
function retreat()
 end_msg1=hero_names[current_team.hero_id].." retreated"
 end_msg2="from battle"
 end_with_loser(current_team)
end


function ask_surrender()
 local enemy_id=
  current_team.enemy.hero_id
 if enemy_id==nil then
  open_dialog({
   "no hero to negotiate with",
   "   ok"
  },{
   open_battle_menu
  })
 else
  cost=0
  for m in all(current_team.mobs) do
   cost+=m.count*mob_hps[m.id]
  end
	 open_dialog({
	  hero_names[enemy_id].." will accept",
	  "your surrender for ",
	  cost.." gold",
	  "   accept",
	  "   deny",
	 },{
	  function() surrender(cost) end,
	  open_battle_menu,
	 })
	end
end
function surrender(cost)

 --less tokens to just inline
-- local l_plr=current_team.plr
-- local w_plr=current_team.enemy.plr
 
 if current_team.plr.gold<cost then
  open_dialog({
   "you can't afford it!",
   "   ok"
  },{
   open_battle_menu
  })
 else
 
	 current_team.plr.gold-=cost
	 current_team.enemy.plr.gold+=cost
	
	 end_msg1=hero_names[current_team.hero_id].." negotiated"
	 end_msg2="a peaceful surrender"
	  
  end_with_loser(current_team)
	 
 end
end




function team_is_dead(team)
 return #team.mobs<=0
 --token: just check #mobs
 --now that we actually remove them
-- for m in all(team.mobs) do
--  if (m[2]>0) return false
-- end
-- return true
end

--todo: token: simplify this?
function cas_from_army(army)
 local res={}
 for m in all(army) do
  if m.casualties>0 then
   local c=copy(m)
   c.count=c.casualties
   add(res,c)
  end
 end
 return res
end

function team_wipe(loser)
 if is_team_player(loser) then
	 end_msg1="attackers defeated"
	 end_msg2=hero_names[loser.hero_id].." abandons your cause"
	else
	 end_msg1="victory"
	 end_msg2=""
	end
	end_with_loser(loser)
end

function end_with_loser(loser)
 

 --reset from last battle
 btnx_wasup=false
 
 
 --turn these off
 activemob=nil
 bcur.x=1000
-- binstructions=false
 
 
	l_cas=cas_from_army(aaa.cas)
	r_cas=cas_from_army(bbb.cas)
 
 hack_to_center_dialog=true
 diag_open=true
 diag_txt={
  "    --battle end--    ",
  "",
  end_msg1,
  end_msg2,
  "",
  "casualties",
  "",
  "",
  "",
  "",
  "",
  "",
  "done"}
 if player_battle then
	 while true do
	  battle_draw()
	  draw_dialog()
	  draw_army_s(l_cas,61)
	  draw_army_s(r_cas,81)
	  if player_battle then
	   flip()
	  end
	  frame+=1
	  if btn(❎) and btnx_wasup then
	   break
	  end
	  btnx_wasup=not btn(❎)
	 end
 end
 
 diag_open=false
 
-- in_battle=false
 main_update=map_update
 main_draw=map_draw
 
 
 del_obj(loser.unit)
 
 
 --adjust mob numbers down
 --if they are still alive
 --todo: reduce tokens here
 --(and in battle start)
 --by treating mobs/armies
 --more of the same maybe??
 if bbb.unit.type=="mob" then
  mobsleft=0
  for m in all(bbb.mobs) do
   mobsleft+=m.count
  end
  bbb.unit.group.count=mobsleft
 end
 
end



----token: combine with other sorts?
--function sort_by_speed(t)
-- for n=2,#t do
--  local i=n
--  while i>1 and
--   mob_speeds[t[i].id]>
--   mob_speeds[t[i-1].id]
--  do
--   t[i],t[i-1]=t[i-1],t[i]
--   i-=1
--  end
-- end
--end

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
 speed=mob_speeds[mob.id]
 for spot in all(grid) do
  if grid_dist(spot,mob)<speed then
   if is_empty(spot) then   
    add(result,spot)
   end
  end
 end
 return result
end

function from_unit(x,unit)
 local mobs={}
 
 if unit.type=="hero" then
 
	 for i=1,5 do
	  local m=unit.army[i]
	  if m!=nil then
	   m.x=x
	   m.y=i*2-2
	   add(mobs,m)
--	   cls()
--	   for k,v in pairs(m) do
--	    print(k.." "..v)
--	   end
--	   stop()
	  end
	 end
	 
 else
  
  --todo: can we save tokens here?
    
  --mobs with no hero
  mobname=mob_names[unit.group.id]
  mobcount=unit.group.count
	 
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
	 
	 for i=0,count-1 do
 	 thisamt=split
 	 if (leftover>i) thisamt+=1
	  mobstack=ms(mobname,thisamt)
	  mobstack.x=8
	  mobstack.y=(starty+i)*2
   add(mobs,mobstack)
	 end
	 
	 
 end
 
 return mobs
end

--start/init rolled into one
function start_battle(l,r)

 --stop hero movement
 moving=false --todo: better place/way?
 
 
 main_update=battle_update
 
 if is_plr_ai(obj_owner(l))
 and is_plr_ai(obj_owner(r)) 
 then
  player_battle=false
 else
  player_battle=true
  main_draw=battle_draw
 end

 
 --l is always hero
 --r could be hero or mob
 
 
 corpses={}
 
 
 --grid start x/y (margins)
 gstart=pt(19,19)
 
 
 
 --setup units / teams
 
 --master list of all units
 --on battlefield
 --used to track turn order
 --(usually sorted by speed)
 --but also used to sort by y
 --when drawing battlefield units
 moblist={}
 
 --used to draw mobs
 --sorted by y
 mobdrawlist={}
 
 --each mob pointer is a key
 --into this hastable that
 --returns a pointer to the
 --team that owns that mob
 --(less tokens than a func)
 --3+5=8 tokens this way
 --vs about 20 in a function 
 mob_team={}
 
 --these also populate
 --moblist and mob_team
 aaa=make_battle_team(0,l)
 bbb=make_battle_team(8,r)
 
 --8 tokens to quickly
 --get opp team
 --(easier than a func that
 -- checks if x is part of one
 -- and then returns the other)
 aaa.enemy=bbb
 bbb.enemy=aaa
 
 
 
 --sort by alternate teams
 --if multiple of same speed
 for speed=20,1,-1 do
  for i=1,5 do
   add_mob_of_speed(aaa,speed)
   add_mob_of_speed(bbb,speed)
  end
 end
 
 
 activemob=moblist[1]
 
 --shortcut to init a few things
 --that also reset every turn:
 --attack_portion=false
 --bcur=copy(activemob)
 --current_team=mob_team[activemob] 
 inc_mob_turn(0)


end


function add_mob_of_speed(team,speed)
 for m in all(team.temp) do
  if mob_speeds[m.id]==speed then
   del(team.temp,m)
   add(moblist,m)
   break
  end
 end
end


function make_battle_team(x,unit)
 local res={}
 
 --so we know if ai or plr 
 res.plr=obj_owner(unit)
 
 --todo: could try to combine
 --these .unit and .hero
 --but need some way to check
 --if combined new var is hero
 --before trying to get its id
 --maybe... use these two vars:
 -- .is_hero=unit.type=="hero"
 -- .unit  (and use unit.id)
 --todo: test if less tokens
 
 --so we know what unit to
 --remove from map if defeated
 res.unit=unit
 
 --so we know what hero 
 --to draw / name to use
 res.hero_id=nil
 if unit.type=="hero" then
  res.hero_id=unit.id
 end
 
 res.mobs=from_unit(x,unit)
 res.cas={}
 res.temp={} --used for sorting
 
 for m in all(res.mobs) do
  m.flipx=x==8 --flip defenders at battle start
  
--  add(moblist,m)
  add(mobdrawlist,m)
  
  add(res.temp,m)
  
  --can't copy b/c we don't
  --actually want full deep copy
  --just a 1-level deep copy
  --(copy the mob pointers)
  add(res.cas,m)
  
  --init these here so we don't
  --have to check if nil later
  m.casualties=0
  m.damage=0
  
  --important token-saving
  --reverse lookup table
  mob_team[m]=res
 end
 
 return res
end



function get_enemies(mob)
 return mob_team[mob].enemy.mobs
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
 
  local bpath=pathfind(m,p,
   b_neighbors,
   grid_dist)
  for step in all(bpath) do
   --token: ptset
   m.x,m.y=step.x,step.y
   if player_battle then
    for i=1,3 do
 		  battle_draw(true)
 		  flip()
 		 end
		 end
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

 --death animation
 if player_battle then
	 for i=1,20 do
	  local m=mob
	  local sx,sy=bgrid2screen(m)
	  pal(8,0)
	  spr(60,sx,sy)
	  pal()
	  flip()
	 end
 end
 
 if mob==activemob then
  --set activemob back one
  --so when we delete it and
  --call next_mob later, it
  --correctly goes to next mob
  --(feels like a kludge)
  inc_mob_turn(-1)
 end
 
 add(corpses,mob)
 
 --7912
 del_lists={
  aaa.mobs,
  bbb.mobs,
  moblist,
  mobdrawlist,
  aaa.unit.army,
  bbb.unit.army,
  }
 for l in all(del_lists) do
  del(l,mob)
 end
  
 --7916
-- del(aaa.mobs,mob)
-- del(bbb.mobs,mob)
-- del(moblist,mob)
-- del(mobdrawlist,mob)
-- 
-- --todo: func that does xx to
-- --both aaa and bbb ??
-- 
-- --remove from unit too
-- del(aaa.unit.army,mob)
-- del(bbb.unit.army,mob)
 
end

function mob_attack(pos)

 --token: potential here
 local mob=activemob
 local enemy=mob_at_pos(pos)
 
 mob.flipx=enemy.x<mob.x
 
 --attack/hurt animation
 if player_battle then
	 battle_draw(true)
	 for i=1,20 do
	  local a=mob
	  local sx,sy=bgrid2screen(a)
	  spr(59,sx,sy)
	  
	  local d=enemy
	  local sx,sy=bgrid2screen(d)
	  spr(60,sx,sy)
	  flip()
	 end
 end
 
 
 enemy.damage+=mob_attacks[mob.id]
              *mob.count
 
 enemy_hp=mob_hps[enemy.id]
 while enemy.damage>enemy_hp do
  enemy.damage-=enemy_hp
  if enemy.count>0 then
   enemy.count-=1
   enemy.casualties+=1
  end
 end
 
 if enemy.count<=0 then
  mob_die(enemy)
 end
 
 next_mob_turn()
 
end


--function get_mob_team()
--
--end

function is_plr_ai(p)
 return p==nil or p.ai
end

function is_team_player(team)
 return not is_plr_ai(team.plr)
end

--right now l_mobs is assumed player
--hotseat battle support tbd
function is_player_turn()
 return is_team_player(current_team)
--todo: something that works
--if player is plr (with .ai or some other way)
--or if player is nil (mob controlled)
-- return not mob_team[activemob].plr.ai
-- return has(aaa.mobs,activemob)
end

function mob_at_pos(pos)
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
function is_empty(p)
 --token: inline this
 return not has2(moblist,p)
end


function inc_mob_turn(amt)
 local newi=
  indexof(moblist,activemob)+amt

 --token: wrapclamp( ?
 if (newi>#moblist) newi=1
 if (newi<1) newi=#moblist
 
 activemob=moblist[newi]
 
 
 attack_portion=false
 
 bcur=copy(activemob)
 
 --5 tokens here saves us
 --2 per use
 --(1 token vs 3)
 current_team=mob_team[activemob] 
 
end

--todo: inline
function next_mob_turn()
 inc_mob_turn(1)
end


function battle_update()
    
 --better place for this?
 cur_obj=nil
 
 --debug win button
 if btn(🅾️) and btn(❎) then
  bbb.mobs={}
 end
 
 --needs to be here so we
 --can abort out of update...
 --if we change end screen
 --to not be a blocking, modal
 --kind of thing, then maybe
 --we could move this check
 --to mob_die or somewhere else 
 --but still would need to be 
 --careful with what's ran
 --after team_wipe() is called
 if team_is_dead(aaa) then
  team_wipe(aaa)
  return
 end
 if team_is_dead(bbb) then
  team_wipe(bbb)
  return
 end
 
 
 attacks=adjacent_enemies(activemob)
 moves=valid_moves(activemob) 

 options=copy(moves)
 --if move mode, still allow 
 --attacks if there are any
 --todo:token:concat lists function
 for a in all(attacks) do
  add(options,a)
 end
 
 --todo: might not need this
 --since we concat attack anyway
 if (attack_portion) options=attacks

 if is_player_turn() then
  
  if btnp(❎) then
   if has2(options,bcur) then
    if has2(moves,bcur) then
	    mob_move(bcur)
    else
     mob_attack(bcur)
	   end
   end
   
  elseif btnp(🅾️) then
   sfx(64)
   open_battle_menu()
--   return --needed?
      
	 end
  
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
	  mob_move(closest_spot)
  end
  
 end
 
 
 
 move_cursor(bcur, 0,8, 0,9)
 if evencol(bcur.x) 
 --token: clampx/y functions?
 and bcur.y>8
 then
  bcur.y=8
 end

end



function battle_draw(hidecursor)

	camera()
	cls(3)
	
	--todo: token:
	--consider a spr2() that takes
	--a pt instead of x,y?


 --draw grid
 
 for spot in all(grid) do
  x,y=bgrid2screen(spot)
--  rect2(x,y,gw+1,gh+1,11)
  rect2(x,y,11,11,11)
 end
 
 
 --heros
 spr(hero_battle_sprs
  [aaa.hero_id],
  2,30,2,2)
 
 if bbb.hero_id!=nil then 
  spr(hero_battle_sprs
   [bbb.hero_id],
   111,30,2,2,true)
 end
 
 
 --draw debug valid move spots
 if is_player_turn() then
	 if activemob!=nil then
		 for spot in all(options) do
		  x,y=bgrid2screen(spot)
		  circfill(x+5,y+5,1,6)
		 end
	 end
 end
 
 
 --draw corpses
 for c in all(corpses) do
  local sx,sy=bgrid2screen(c)
  pal(8,0)
  spr(11,sx+1,sy+1)
  pal(8,8)
 end
 
 
 --draw armies
 
 sort_by_y(mobdrawlist)
 for m in all(mobdrawlist) do
  --highlight active mob
  if m==activemob then
   flashcols={7,6,10,13,1}
   pal(1,flashcols[
    flash(#flashcols,3)])
  end
  --draw mob
  sx,sy=bgrid2screen(m)
  sx-=2
  sy-=10
  draw_big_mob(m,sx,sy,m.flipx)
 end
 
 
 
 --cursor
 if not hidecursor then
 	sx,sy=bgrid2screen(bcur)
--	 rect2(sx,sy,gw+1,gh+1,15)
	 rect2(sx,sy,11,11,15)
	 --bounce?
	-- cw,ch=gw+1,gh+1
	-- ex=0
	-- if (frame%10<5) c=10 ex=1 cw+=2 ch+=2
	-- rect2(sx-ex,sy-ex,cw,ch,10)
	 
	 --draw cursor symbol
	 if has2(options,bcur) then
	  local tspr=58
	  if has2(attacks,bcur) then
	   tspr=59
	  end
   spr(tspr,sx+2,sy+1+flashamt())
	 end
	end
 
 

-- if binstructions then
-- if not hidecursor then
 if is_player_turn() 
 and not hidecursor
 then
  if diag_open then
 	 draw_control("close menu","select")
	 else
	  draw_control("menu","move/attack")
	 end
 end
 
 
 --todo: better way to indicate
 --this phase of the turn??
 if attack_portion then
  print("attack",30,0,6)
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
--  print(mob_names[m.id],4,60+i*8,1)
--  if m==activemob then
--   print("-",0,60+i*8,10)
--  end
--  i+=1
-- end
 	
end

function bgrid2screen(p)
 --ptmul or ptscale ?
-- local res=pt(p.x*gw,p.y*gh)
 local res=pt(p.x*10,p.y*10)
 ptinc(res,gstart)
 if not evencol(p.x) then
  res.y-=5 --gh/2
 end
 return res.x,res.y
end



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
 hack_to_center_dialog=false
 diag_open=true
 diag_txt=txt
 diag_opts=opts
 diag_sel=1
end
function close_dialog()
 blackout=false --better place?
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
  
  --hack for battle menu
--  if btnp(🅾️) and in_battle then
  if btnp(🅾️) and main_draw==battle_draw then
   sfx(61)
   close_dialog()
  end
  
  return true
 end
 return false
end

function draw_dialog()
 if diag_open then
  maxw=0
  for l in all(diag_txt) do
   maxw=max(maxw,#l)
  end
  w=maxw*4+2+6
  h=#diag_txt*7+6
  x=63-w/2//-3
  y=63-h/2-3 --todo: centered without -3 actually?
  draw_window(x,y,w,h)
	 
  x+=1+3
  y+=1+3
  for l in all(diag_txt) do
	  if hack_to_center_dialog then
	   x=63-#l*2
	  end
   print(l,x,y,1)
   y+=7
  end
  y-=7*(#diag_opts+1)
  if hack_to_center_dialog then
   x=45
   y=99
   spr(49,x+flash(2,15),y-1)
  else  
   spr(49,x+1+sin(t()),y+diag_sel*7-1)
	 end
	 
 end
end




--hud



function select(obj)

 --fix slowdown from hud menu 
 --calling this every frame
 if (sel==obj) return
 
 sel=obj
 if (obj==nil) return
 
 cur=copy(sel) --only need x,y but cheaper to copy entire
 if sel.type=="castle" then
  cur.y+=1
 end
 
 if p_can_see(cur) then
  cam=copy(cur)--snap to new selection
 end
 
 frame=15--reset flash (start on highlight)

 path={}--new sel means new path
 
 create_i2tile()--need new i2reachable
end




targ_menu_y=0
actl_menu_y=0

function animate_hud_menu()

 --animate menu open/close
 local targ=0
 if hud_menu_open then
  targ=16
 end 
 actl_menu_y+=flr(targ-actl_menu_y)/3
 
end

function update_hud_menu_cursor()

 if (btnp(⬇️)) hudtop=false
 if (btnp(⬆️)) hudtop=true
 
 if hudtop then
  move_cursor2(topc,#ports)
  hcur_x=topc.x
  
  select(ports[hcur_x])
 else
  move_cursor2(botc,#buttons)
  hcur_x=botc.x
  
  if btnp(❎) then
  
   --end turn
   if hcur_x==4 then
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
   
   --dig, inspect, etc
   if hcur_x==3 then
    
   end
   
   --inspect
   if hcur_x==2 then
    
   end
   
  end
 end
 
 
end

function update_static_hud()

 --todo: proper home for this?
 --need to call in init as well as update
 ports={}
 i=1
 for c in all(cp.castles) do
  add(ports,c)
  if (sel==c) selport=i
  i+=1
 end
 for h in all(cp.heroes) do
  add(ports,h)
  if (sel==h) selport=i
  i+=1
 end

end





function draw_cur_popup_info()

 --token: set this when creating
 --i2reachable or i2* data??
 

 --map item description
 if cur_obj!=nil 
 and not g(cp.fog,cur)
 then
 
  --text descrip
  
  if cur_obj.type=="hero"
  or cur_obj.type=="castle"
  then
   map_desc=
    colorstrings[obj_owner(cur_obj).color]
    .." "..cur_obj.type
    
  elseif cur_obj.type=="mob"
  then
   --token
   stack=cur_obj.group
   map_desc=vague_number(stack.count)
    ..mob_names[stack.id]
    .." ["..stack.count.."]"
    
  elseif cur_obj.type=="treasure" 
  then
   map_desc=res_names[cur_obj.subtype]
   
  elseif cur_obj.type=="mine"
  then
   map_desc=
    mine_names[cur_obj.subtype]
   
  else
   map_desc=cur_obj.type
  end
  
  if map_desc!=nil then
	  local x=63-#map_desc*2
	  local y=118
	  local w=#map_desc*4+1
	  
	  if cur_obj.army then
	   draw_army_s(cur_obj.army,y-5)
	   y-=14 --move text up
	  end
	  --token
	  rect2(x-1,y-1,w+2,9,1)
	  rectfill2(x,y,w,7,6)
	  print(map_desc,x+1,y+1,1)
  end
 end
 
end


function flashingbox(x,y,w,h)
 
 bb=flashamt()
 rect2(x-bb,y-bb,w+bb*2,h+bb*2,15)
 
end


function draw_hud_menu()

 --menu
 clip(0,0,128,18+actl_menu_y)
 draw_btn_list(buttons,20)
 clip()
 
 
 --flashing selection box
 --(only draw when menu open)
 if hud_menu_open then
	 local i=hcur_x --tokens
	 if hudtop then
	  local w=#ports*10
	  local x,y=53-w/2+10*i,9
	  flashingbox(x,y,10,10)
	 else
	  --todo:hardcode this w
		 local w=0
		 for text in all(buttons) do
			 w+=text_box(text,200,0)
			end
	  local sx=62-ceil(w/2)--18
	  for j=1,#buttons do
	   w=#buttons[j]*4+3
	   if (j==i) break 
	   sx+=w
	  end
	  flashingbox(sx,19,w,9)
	 end
 end
 
 --right sidebar: army
 
-- if actl_menu_y>0 then
--  d_army(sel,130-actl_menu_y,21)
-- end
 
end

function draw_static_hud()
 
 --top bar
 
 --color banner
 pal(8,cp.color)
 spr(57,0,9)
 pal(8,8)
 
 
 d_res_bar()
 
 
 
 --portrait bar

 local w=#ports*10
 local x,y=63-w/2,9
 rectfill2(x,y,w,10,6)
 for p in all(ports) do
  d_port(p,x,y)
  x+=10
 end
 
 
 --todo: token:
 --could put these controls in 
 --their respective functions?
 --hmm but drawing over each other?
 
 --controls
 if main_draw==split_draw then
  draw_control("fast","done")
 elseif main_draw==trade_draw then
  draw_control("split","select")
 else
  draw_control("menu","select")
 end

end



function draw_btn_list(list,y)

 --tokens: can hardcode this w
 local w=0
 for text in all(list) do
	 w+=text_box(text,200,0)
	end
	x=63-w/2
 for text in all(list) do
	 x+=text_box(text,x,y)
	end
end

--x,y is top left
--unless center is passed in
--then passed-in x is center
function text_box(text,x,y,center)
 local w=#text*4+3
 if center!=nil then
  x-=w/2
 end
 --token: draw_window
 rect2(x-1,y-1,w,9,1)
 rectfill2(x,y,w-2,7,6)
 print(text,x+1,y+1,1)
 return w
end



--token: combine these?
function flashamt()
 return flash(2)-1
end
--counts from 1 to amt, change every f frames
function flash(amt,f)
 f = f or 5 --default value
 for i=1,amt do
  if (frame%(amt*f)<i*f) return i
 end
end


--todo: token: shouldn't need this
--map from id to spr directly
--function res_spr(n)
-- return res_sprs[
--  indexof(res_names,n)]
--end
function d_res_bar()

 rectfill2(0,0, 128,9, 6)
 
 for i=1,7 do --all resources
  local name=res_names[i]
--  res_spr(name)
	 local x = 17*i-9
	 if (i==1) x=0 --gold
	 spr(res_sprs[i],x,0)
	 print(cp[name],x+9,2,0)
	end
end



function vague_number(amt)
 for i=1,8 do
  if amt<group_numbers[i] then
   return group_names[i]
  end
 end
 return "a legion of "
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
	 rect2(x,y,10,10,12)
	end
   
end



function draw_window(x,y,w,h)
 rectfill2(x+1,y+1,w-2,h-2,6)
 rect2(x,y,w,h,1)
end


function draw_big_mob(m,x,y,flipx)
-- rectfill2(x,y,16,20,14)
 spr(big_mob_sprs[m.id],
     x+4,y+2,1,2,flipx)  
 pal(1,1)--reset possible flash
 print_mobnum(m,x+4,y+7,true)
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

function print_mobnum(m,x,y,bg)
 local str=tostr(m.count)
 local ofx=-2*#str+4
 local c=0
 if bg!=nil then
  rectfill2(x+ofx,y+8,4*#str,6,1)
  c=7
 end
 print(str,x+ofx,y+8,c)
end


function draw_army_s(arm,y)

 local w=12*5+2--52--=10*5+2
 local x=34--39--=63-w/2+2
 draw_window(x-2,y-2,w,16)
 for i=1,5 do
  local mob=arm[i]
  if mob!=nil then
	  spr(mob_sprs[mob.id],x,y)
	  print_mobnum(mob,x,y)
  end
  x+=12
 end

 if #arm==0 or arm==nil then
  print("none",57,y+4,1)
 end

end



function draw_control(o,x)
 --token: bake y in
 local y=122
 
-- rectfill2(0,y-1,#o*4+7+2,7,6)
 rectfill2(0,y-1,#o*4+9,7,6)
 print("🅾️"..o,1,y,1)
 
 local xw=#x*4+7
 rectfill2(126-xw,y-1,128,7,6)
 print(x.."❎",127-xw,y,1)

end
-->8
--data


function init_data()


-- --for cursor icon
-- cursor_type={
--  castle="castle",
--  hero="trade
-- }


 --pretty much just for
 --checking if p is on grid?
	grid={}
 do_grid(8,function(p)
  add(grid,p)
  if not evencol(p.x) then
   add(grid,ptadd(p,pt(0,1)))
  end
	end)


 --default to "end turn" option
 botc=pt(4,1)
 
 
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
	
	--create from appending?
	eightway={
		pt(-1,0),
		pt( 1,0),
		pt(0,-1),
		pt(0, 1),
		pt(-1,-1),
		pt( 1,-1),
		pt(-1, 1),
		pt( 1, 1),
	}
	
	castle_col={
		pt(-2,0),
		pt(-2,-1),
		pt(2,0),
		pt(2,-1),
		pt(-1,0),
		pt( 1,0),
		pt(-1,-1),
		pt( 0,-1),
		pt( 1,-1),
		pt(-1,-2),
		pt( 0,-2),
		pt( 1,-2),
	}
 mine_col={
		pt(-1,-1),
		pt( 0,-1),
		pt(-1,0),
	}
	
	
	group_numbers={
	 5,10,20,50,100,250,500,1000
	}
	group_names={
		"a few ",
		"several ",
		"a pack of ",
		"lots of ",
		"a horde of ",
		"a throng of ",
		"a swarm of ",
		"zounds... ",
	}

 --menu
 
	--menu buttons 
	buttons={
	 "dig",
	 "inspect",
	 "spell",
	 "end turn",
	}
--	buttons={
--	 "map",
--	 "dig",
--	 "spell",
--	 "end turn",
--	}
--	menusel=4
	
	
	res_names={
	 "gold",
	 "wood",
	 "ore",
	 "sulfur",
	 "crystal",
	 "gems",
	 "mercury",
	}
	mine_names={
	 "gold mine",
	 "sawmill",
	 "ore mine",
	 "sulfur mine",
	 "crystal mine",
	 "gem mine",
	 "alchemist lab",
	}
	res_sprs={
	 241,
	 242,
	 243,
	 244,
	 245,
	 246,
	 247,
	}
	
	mine_incs={100,2,2,1,1,1,1}
	
	

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
	 arrow=48,
	 castle=50,
	 hero=51,
	 horse=52,
	 hot=53,
	 treasure=53, --always hot cursor, less tokens to do it like this
	 trade=54,
	 attack=55,
	}
	
	--mob stats
	
	mob_names={
	 "goblins",
	 "skeletons",
	 "peasants",
	 "elves",
	 "calavry",
	}
	
	mob_sprs={
	 33,34,35,36,37,
	}
	
	big_mob_sprs={
	 1,2,3,4,5,
	}
	
	mob_speeds={
	 4,4,2,4,8,
	}
	
	mob_attacks={
	 4,4,2,5,8,
	}
	
	mob_hps={
	 4,6,1,7,10,
	}


 --other
	
	
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
	
	hero_names={
	 "alakazam",
	 "benny",
	 "charon"
	}
	
	hero_port_sprs={
	 74,75,76
	}
	hero_bport_sprs={
	 74,75,76
	}
	hero_map_sprs={
	 64,66,68
	}
	hero_battle_sprs={
	 96,98,100
	}
	
	
	
	// note activation spot (hot)
	// is relative to the x,y pos
	// not the collider (col) pos
	archetypes={
	 castle={
	  type="castle",
	  port=90,
	  spr=137,
	  sprx=-2*8,
	  spry=-3*8,
	  sprw=5,
	  sprh=4,
	 },
	 hero={
	  type="hero",
	  id=1,
	  sprx=-4,
	  spry=-4,
	  sprw=2,
	  sprh=2,
	  move=100,
	  army={
	   ms("calavry",20),
	   ms("elves",40),
	   ms("peasants",250)
	  },
	 },
	 mine_={
	  type="mine",
	  spr=196,
	  sprx=-8,
	  spry=-8,
	  sprw=2,
	  sprh=2,
	 },
	 mob={
	  type="mob",
	  sprx=0,
	  spry=0,
	  sprw=1,
	  sprh=1,
	  group=ms("goblins",40)
	 },
	 mob2={
	  type="mob",
	  sprx=0,
	  spry=0,
	  sprw=1,
	  sprh=1,
	  group=ms("skeletons",15)
	 },
	 gold={
	  type="treasure",
	  subtype=1, --gold
	  amount=rnd_bw(1,4)*50,
	  spr=242,
	  sprx=0,
	  spry=0,
	  sprw=1,
	  sprh=1,
	 },
	}
	
	--dup some similar archetypes
	--8187
--	for r in all(resources) do
	for i=1,7 do
	 r=res_names[i]
	 if i!=1 then --gold
	  archetypes[r]=copy(archetypes.gold)
	  archetypes[r].subtype=i 
	 end
	 
	 archetypes["mine_"..r]=copy(archetypes.mine_)
  archetypes["mine_"..r].subtype=i
	 if i==2 then --wood
	  archetypes["mine_wood"].spr=192
	 end
	 if i==7 then --mercury
	  archetypes["mine_mercury"].spr=194
  end
	end

end
__gfx__
00000000000000000000000000000000111100000000011111011100000000000000000000000000000000000000000000000000000000000000000000000000
0111111000000000111110000000000013311100000001ddd1116100000000000000000000000000000000000000000000000000000000000000000000000000
01f11f1000000000177711000000000013333110000001d221166100000000000000000000000000000000000000000000000000000000000000000000000000
011ff11000000000170701000011111013333310000001ddd1661100000000000000000000000000000000000000000000000000000000000000000000000000
011ff1100011111017771100001fff1015ff1110000011ddd6641100000000000000000000000000000000000000000000000000000000000000000000000000
01f11f10001bbb1111111000011fff1111ff651100001ccccc455110000000000000000000000000000000000000000000000000000000000000000000000000
01111110011b3b3117771000114fff661333615100011cc8cc444410000000000000000000000000000000000000000000000000000000000000000000000000
0000000011bbbb1117661000144411511333615100114c888c499410000000000000000000000000000000000000000000000000000000000000000000000000
000000001bbb11161677100014f411511333615100124cc8cc991110000000000000000000000000000000000000000000000000000000000000000000000000
000111001b3bb16117661000144fff5113336511001244ccc4211000000000000000000000000000000000000000000000000000000000000000000000000000
0011f1101bb336111677110014444151133311100012421dd4211000000000000000000000000000000000000000000000000000000000000000000000000000
001fff101bbb61101611610014444151151151000011422114221000000000000000000000000000000000000000000000000000000000000000000000000000
001111101b11b100171171001f111f11151151000001441114411000000000000000000000000000000000000000000000000000000000000000000000000000
0001f1001b11b110171171101f111f11151151100001111011110000000000000000000000000000000000000000000000000000000000000000000000000000
0001f1001bb1bb10167167101ff11ff1155155100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011100111111101111111011111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000111100001111000011110001331100001d111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000011bb10000176111001ff100013331110019912100000000000000000000000000000000000000000000000000000000000000000000000000000000
011f111111bbb11101166171011ff100015f17511119922200000000000000000000000000000000000000000000000000000000000000000000000000000000
01ff1ff11bb11171111611710141110001331715526d621200000000000000000000000000000000000000000000000000000000000000000000000000000000
011f11111bbbb611167766d101441000013317155266621100000000000000000000000000000000000000000000000000000000000000000000000000000000
001110001bbb61101176611101441100013317511222221000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001b1611000161610001f1f100015151111211121000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001b1b10000161610001f1f100015151001111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000000011100111011100000111100001110000000001110011110018888810001111000000111188000088000000000000000000000000
0111110001f11000111111111f1111f111f1000011ff100011f11110000011f10018811118888810001ff10000011ff108800880000000000000000000000000
01fff10001ff11001f1ff1f11f1ff1f11ff111101ff111001ff1ff1011111ff10018888118888810001ff1001111fff100888800000000000000000000000000
01ff110001fff1001ffffff111ffff111f1fff11111ff11011f111111f11ff110018811118888810111f11111f1fff1100088000000000000000000000000000
01f1f11001ff11001ffffff11ffffff1111ffff111ffff1101111f1111fff11000111100188188101f1f11f111fff11000888800000000000000000000000000
01111f1001f110001ff11ff11ffffff101f11ff11f11fff101ff1ff111ff11000011000018101810111ff11111ff110008800880000000000000000000000000
0000111001110000111111111111111101f11f1111f11f1101111f111f11f10000110000110001101ff1f1101f11f10088000088000000000000000000000000
000000000000000000000000000000000111111000001f10000011101111110000110000100000101f11ff101111110000000000000000000000000000000000
000000111100000000000011110000000000001111000000000000000000000000000000000000000dddddd00222228011111110000000000000000000000000
00000117710000000000015551000000000001177100000000000000000000000000000000000000dddffddd2211128816666611000000000000000000000000
00000175510000000000022991000000000001717000000000000000000000000000000000000000dfffffdd2999912811611661000000000000000000000000
0000017dd1111000000001d991111000000001777111100000000000000000000000000000000000d1f11fdd0919192811611661000000000000000000000000
00000177711711000000019dd11711000000011111171100000000000000000000000000000000000fffffd00999991216166661000000000000000000000000
000001cc617551100000015541755110000001227177511000000000000000000000000000000000ddddff000dddd91216666611000000000000000000000000
000111cc667777100001115544777710000111227d777710000000000000000000000000000000000ffff0000d11d81211616110000000000000000000000000
00117ccc667667100011755546766710001172227d7d171000000000000000000000000000000000000000000dddd82201111100000000000000000000000000
00167cccc66611100016755556661110001672222ddd111000000000000000000000000000000000eeeeeeee0000000000000000000000000000000000000000
001677ccc7d110000016775557d11000001677222751100000000000000000000000000000000000eee11eee0000000000000000000000000000000000000000
00167d0cc7d1100000167d0557d11000001675022751100000000000000000000000000000000000e1e661ee0000000000000000000000000000000000000000
00117dd117dd100000117dd117dd1000001175511755100000000000000000000000000000000000e61617110000000000000000000000000000000000000000
00017711177110000001771117711000000177111771100000000000000000000000000000000000116676670000000000000000000000000000000000000000
00001110111100000000111011110000000011101111000000000000000000000000000000000000676116670000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000676116670000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000335555330000000000000000000000000000000000000000
000000111100000000000011110000000000001111000000000000000000000000000000000000000000000033b333b33b3b3b3bb333b3333b333b3377cccc77
00000117711111100000011771111110000001177100000000000000000000000000000000000000000000003b3b3b3bbbbb3bbb3b333b33b3b3b3b37cc7777c
0000017551166611000001755114441100000175510111100000000000000000000000000000000000000000b333b3b33b3b3b3b33b333b33b3b3b3b7777cc77
0000017dd16677610000017dd14455410000017dd111771100000000000000000000000000000000000000003b3b3b3bbbbbbbbb333b333b33b333b3ccc77ccc
000001777167dd710000017771451151000001777117dd71000000000000000000000000000000000000000033b333b33b3b3b3bb333b3333b333b3377cccc77
000001cc66777771000001cc66555555000001224177176100000000000000000000000000000000000000003b3b3b3b3bbbbbbb3b333b33b3b3b3b37cc7777c
011111cc66777d71011111cc66555d5501111122447711710000000000000000000000000000000000000000b3b3b3333b3b3b3b33b333b33b3b3b3b7777cc77
11771ccc667ddd1111551ccc665ddd1111771222447ddd1100000000000000000000000000000000000000003b3b3b3bbbbbbbbb333b333b33b333b3ccc77ccc
16771ccccddd711014551ccccddd51101677122224dd71100000000000000000000000000000000000000000b3b3b3b3b3b3b3b3b333b333b333b333cccccccc
167711ccc777d100145511ccc555d100167711222777d10000000000000000000000000000000000000000003b3b3b3b3333b3333b333b3333b333b377cc77cc
161771ccc771d100141551ccc551d100161771222771d1000000000000000000000000000000000000000000b3b3b3b3b3b3b3b3333b333b33333333cc77cc77
1617711cc171d1001415511cc151d100161771122171d10000000000000000000000000000000000000000003b3b3b3b3333333333b333b333333333cccccccc
11171d111171d11011151d111151d11011171d111171d1100000000000000000000000000000000000000000b3b3b3b3b3b3b3b3b333b333b333b333cccccccc
00171dd10171dd1000151dd10151dd1000171dd10171dd1000000000000000000000000000000000000000003b3b3b3bb33333333b333b3333b333b377cc77cc
0017711101771110001551110155111000177111017711100000000000000000000000000000000000000000b3b3b3b3b3b3b3b3333b333b33333333cc77cc77
00111100011110000011110001111000001111000111100000000000000000000000000000000000000000003b3b3b3b3333333333b333b333333333cccccccc
0000000000000000b333b3333333bbb334debbb3333a9a9333bbbb33b333b3330000000000000000000000000000110000000000000000000000011111000000
000000000000000033b333b33ddbbb6bddedd3bb339999a93b3b3bb3333333b3000000000000000000000000000111100000000000000000000011d444110000
000000000000000033333333ddbbbbb64dddeb3b3399a9993b3b3b3b336333330000000000000000000000000011111100000000000000000001155544441000
000000000000000033333333ddbbbbbb4ddedbbb33999a9a3b3b3b3b3111333300000000000000000000000000dddddd000000000000000000112554dd444100
0000000000000000b333b333dd33bbb344dddbb3111999933b3b3b3bb333363300000000000000000000000000077770000000000000000001122d55555d4410
000000000000000033333333dddbbbb3145d151331115533311b3b1133b3111300000000000000001d10000000067070000000000000000001224555454dd441
000000000000000033bbbb331513151311511113331155133111511133333d63000000000000000011101dd10007776000001dd100000000112555555555dd45
00000000000000003b3b3bb31113111331113333333111133311111333331111000000000000000006701111000667701d101111000000001225555554555555
00000000000000003b3b3b3b3333a9a9333336333333363333399333b333b333b333b33300000000076007700007666011100770000000001211555555522225
00000000000000003b3b3b3b3339999a93333d6333333d6333999a333333336333b333b300000000077006600007777007700670000000001211111111121125
0000000000000000bb3b3b3b33349a99aa9a3dd3aa9a3dd333b99933336363333333333300000001dd111771101dddd10670076000000000011d111166121121
0000000000000000b3bb3b3b333499a9aa9a3dd3aa9a3dd33bbb9aa3363333633333d6330000000111107667771111111761177000000000001ddd6666161161
0000000000000000b3b3bb3b31114999aa993533aa99353313bb9aa333363633333dd66300000007dd377667777777777777777000000000001ddd6666211611
00000000000000003113b31133111553a999a533a999a533133b99a3b3333363311d66630000007553333b11117776666777777000000000661ddd2262216110
0000000000000000311151133331bb511539aa331539aa3311511513336363333311111300000655533b3b5551166771177111d7700000001111dd2211661100
000000000000000033111113333bbb1115199a3315199a33311115133333333333333333000006555b33b3776666616667761133770000000116611111111000
00000000000000000000000033bbbbb31111bbb3111469d300000000b333b33333333333000006bb5333dd3dddd161ddddd61333370000000000000000000000
00000000000000000d00000011b3bb9aa33bbbbb333dd36d0000000033333363333333330000067bbb3ddd1d1d11611d1d13b775570000000000000000000000
0000000000000000000000d0311b3b99a9a3bbbba9add1d600000000336363b33d663333000006677bbd2d1d1d1ddd1d1d1b3555770000000000000000000000
0000000000000000000000003311539aa9aa3bbba9a6d3dd00000000363b3b63111113330000067667777711111d661111133777770000000000000000000000
00000000000000000000d00033315399a99a333b999ad3dd0000000033b63633333dd33300000666777766677766dd6777677777660000000000000000000000
00000000000000000d00000033311139399915339999135300000000b333b36333111133000016776666776777ddd6d777676666770000000000000000000000
00000000000000000000000033333115399915131995115300000000336363b3333333330001366677776667176d6dd71767777777b000000000000000000000
0000000000000000000000d03333333311531113151333330000000033333333333333330013b677667777676766d6d76767666777b000000000000000000000
0000000000000000000000003333a9a9111d63d3111333d3000000000000000033333333013b3b667776666777d6dd67776777777bbb00000000000000000000
0000000000000000000000003339999a3336d36da331d36d00000000000000003333366301b3b3bbbb777767776d66d7776667bbbbbbb0000000000000000000
00000000000000000000000033349a99a9ad61d6a9add1d600000000000000003333dd661b3b3bbbbbbb333777d67667776bbbbbbbbbb0000000000000000000
000000000000000000000000333499a9a9ad63dda9aad3dd00000000000000003311d66613b3b3bbbbbbb333bb667773bbbbbbbbbbbbb0000000000000000000
00000000000000000000000031114999999ad3dda99ad3dd000000000000000033d66111013b3bbbb3bbbbbbbb766763bbbbbbbbbbbb00000000000000000000
000000000000000000000000331115539999135339991353000000000000000033dd6333001bbbbbbb33bbbbb76677673bbbbbbbbb0000000000000000000000
0000000000000000000000003331bb5119951153399511510000000000000000111111330000000bbbbbbbbbb667767673bbbbbb000000000000000000000000
000000000000000000000000333bbb111513333311533333000000000000000033333333000000000000bbbb6666666663bbb000000000000000000000000000
00a9a900044000000000000999900000000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999aa1155000440000099994999000000011d44411000000000000011111100001111000000055500000000000000000011110000111110111111001111110
049a99a000001155000999911499999000011555444410000000000001781a1001116810000055555550000050000000011168100111c7c101681a100166d111
0499a9a004000000000ee99999999ff000112554dd4441000000000001881111016c8810000054444455555555000000016c881001b17cc1018811111111d161
1149990115011110000eeee9999ffff001122d55555d441000000000111117c111cc16b100054444444441555450000011cc16b11111ccc1111111c1166d1111
1115500000112211000e1deeeffffff001224555454dd441000000001c17b11116811bb100554154444415545545000016811bb1178111111c16b11116dd16d1
0115514411122221000e11eeeffffff0112555555555dd4500000000111bb1811881aa110054155544555444555450001881a11118817910111bb1811ddd1dd1
1111115114442211000eeeeeefffd1f0125555555455555500000000001111111111111000541545554444444455550011111100111111100011111111111111
1551111144444151000e111eeffdd1f0125555555552222500000000000000000000000005515544455444444444550000000000000000000000000000000000
1155441111111551000e1d1eeffdd1f0122111511112112500011111111000000001111005155444445444444444450000111100000111000001110000111000
151144115111551111111d11effdd1f01121d111661211210001dd66661000000111cc10055444444455444444444450111aa1110111a1100111a110016d1110
15551221511151100111ddd11ff110000111dd66661611610011dd666610000001bbcc100554444444454444555554501aa1aa1101a19a1101a19a1101dd1d10
1154424111111100001776661ff000000012dd66662116110012dd666621000011b88bb105444444111111445111545011991991117919a1117979a111111111
011441110000004400166666100000006612dd22622161106612dd22622100001cc88bb10544441111111114511154501991aa1119aa979119aa979116d16dd1
00111100044011550011111110000000111111221166110011111122116600001cc1aa1155441111111111115111555011aa1991119aa111119aa1111dd1dd11
00000001155000000000000000000000011661111111100001166111111110001111111055441d11111111615111550001111111011111000111110011111110
11111110111111101111111011111110001111001111111001111000011110000000000055441dd1111666611000100000000000000000000000000000011111
1fffff101fdddf101ddddd101ddddd10001dd1101f111d1011ff1000016811100111111055441dddd66666611001100001111110011111100111111001115551
11fff11011fff11011fff11011ddd110111ddd101ff1dd101fff111001881a1001681a1055441dddd66666dd11110000017a1a10017a1a10017a1a1001445511
011d1100011f1100011f1100011d11001ffddd101ffddd101fffdd101111cb1101881b11055511ddd66661dd11000000019911110199111101aa111111441151
11ddd11011dfd11011dfd11011fff1101fff11101ff1dd10111ddd1016c11ac1111111c10011111dd6dd11111000000011111aa111111aa1111111a114115551
1ddddd101ddddd101dfffd101fffff1011ff10001f111d10001dd1101cc6b1811c16b1810000001111dd1110000000001a17a1911a17a1111a17a11114445511
11111110111111101111111011111110011110001111111000111100111bb111111bb1110000011111111100000000001119911111199191111aa1a111441110
00000000000000000000000000000000000000000000000000000000001111000011110000000000000000000000000000111100001111110011111101111000
00000000000000000001111100000000000000000001000001111000000000001111111011111110111111101111111011111110111111101111111011111110
11111110011111100111555101111110001111000017100001781110001110001fffff101ffdff101fdddf101ddddd101ddddd101ddddd101ddddd101ddddd10
1aba2c11017a1a10014455110166d1110116a1100017e10001881a100015100011fff11011fff11011fff11011fff11011fff11011fdf11011ddd11011ddd110
118cb8a101991111114411511111d161116aa9111017e1101117cb11011d1100011d1100011f1100011f1100011f1100011f1100011f1100011f1100011d1100
4111111111111aa112115551166d111119aaa991111ee1e117c1178111ddd11011ddd11011ddd11011dfd11011dfd11011dfd11011fff11011fff11011fff110
449944911a17a1911244551116dd16d11999994117e117e11cc7b881177666101ddddd101ddddd101ddddd101ddfdd101dfffd101dfffd101fffff101fffff10
1499999111199111114411101ddd1dd11144441111ee1711111bb111166666101111111011111110111111101111111011111110111111101111111011111110
11111111001111000111100011111111011111100111111000111100111111100000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000101010100000000000000000000000101010101000000000000000000000000010101000000000000000000000000000101010000000000000000000001010000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
7e7d7e7e857e977e7e7e7e7e7ea87e7e7e7d7e6e6e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7e7e7e837e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e857e7e7e7e7e7d7d877e7e7e7e7d6e6e6e6e7e7e7e6f6f7f7f7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e7e7e7e7d7e7e7e7e7e7e7e7e7e7e7e7e837e7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e857e7e7d7e7d7d7e7e7e7d7e7e7e6e6e6e6e7d7e7e6f6f6f7f7f7f7f7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7d7e83838300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

