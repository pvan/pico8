pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--game


tilesz=16 


 
function _init()
 cartdata("pv_caspian")
 cls()
 
 local ptx,pty=dget(0),dget(1)
 player.x=(ptx)*tilesz
 player.y=(pty)*tilesz
 
 
 init_mouse()
 
end




lastrec={0,0,0,0}

function eq(r1,r2)
 return r1[1]==r2[1] and
        r1[2]==r2[2] and
        r1[3]==r2[3] and
        r1[4]==r2[4]
end

function _update()

 --for storing timing metrics
 gtime={}
 
 cls() -- clear here since we use screen memory for building our tilemap
 
 
 add(gtime,{"cls(",stat(1)})
 
 
 if btn(❎) and btn(🅾️) then
  pause_menu=true
  
  playing_music=false
  music(-1)
  
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
  if (pm==1) debugmsgs=not debugmsgs
  if (pm==2) debugmap=not debugmap
  if (pm==3) debugfill=not debugfill
  if (pm==4) debugcol=not debugcol
  pm=0
 end
 
 
 
 
 --using map mem from last frame
 player_update(player)

 ptx=flr(player.x/tilesz)
 pty=flr(player.y/tilesz)
 subpx=player.x%tilesz
 subpy=player.y%tilesz
 
 add(gtime,{"plyr",stat(1)})
 
 
 
 --mapreset()
 
 --camxy are center of screen now
 camx,camy=player.x,player.y
 camtx,camty=w2wt(camx,camy)

 camtrec={
  camtx - (mapw/2),
  camty - (maph/2),
  camtx + (mapw/2),
  camty + (maph/2)}
 bigrec={
  camtrec[1]-5,
  camtrec[2]-5,
  camtrec[3]+5,
  camtrec[4]+5}
 --if not eq(rec,lastrec) then
  curves=curves_in_rect(bigrec)
  add(gtime,{"curv",stat(1)})
  gen_map(curves,camtrec[1],camtrec[2])
  add(gtime,{"genm",stat(1)})
  fill_map()
  add(gtime,{"fill",stat(1)})
  fill_islands(camtrec[1],camtrec[2])
  add(gtime,{"isld",stat(1)})
  copy_screen_map_to_mem()
  add(gtime,{"2mem",stat(1)})
  
 --end
 lastrec=rec
 
 --[[
 --little assert style
 --sanity check for where
 --we need lake points, etc
 local dx,dy=camtx-lctx,camty-lcty
 if not compare_mem_maps(dx,dy) then
  dset(0,camtx)
		dset(1,camty)
  stop("mismatch at "..camtx..","..camty)
 end
	copy_mem_map_to_cache()
 lctx,lcty=camtx,camty]] 
 
end

--lctx,lcty=-100,-100

function _draw()
 

 --draw_map_as_tiles(subpx,subpy)
 draw_map_style2(subpx,subpy)
 add(gtime,{"dmap",stat(1)})
 
 
 player_draw(player)
   
   
 if debugmap then
  draw_map_from_mem(64,64,mapaddr)
  local wdtx,wdty=w2lt(player.x,player.y,player.x,player.y)
  pset(64+wdtx,64+wdty,7)
 end
 

 
 if pause_menu then
  spr(223,64-4,64-4)
  spr(239,64-4,64-4-10)
  spr(254,64-4-10,64-4)
  spr(255,64-4,64-4+10)
  spr(238,64-4+10,64-4)
  
  local rx,ry=64-4,64-4
  if (pm==1) rx=64-4 ry=64-4-10
  if (pm==2) rx=64-4-10 ry=64-4
  if (pm==3) rx=64-4 ry=64-4+10
  if (pm==4) rx=64-4+10 ry=64-4
  rect(rx-1,ry-1,rx+8,ry+8)
 end
 
 
 camera()
 color(0)
 if debugmsgs then
  cursor(0,0)
  print("fps "..stat(7).."/"..stat(8))
  kbs=stat(0)
  bts=(kbs-flr(kbs))*1024
  print("ram "..flr(kbs).."k "..bts.." (of 2048k)")
  print("cpu "..stat(1))
  print("sys "..stat(2))
 	
 	print(" ")
 	lastt = 0
 	for i=1,#gtime do
 	 delta = gtime[i][2]-lastt
 	 --delta=flr(delta*100)
 	 print(gtime[i][1].." "..delta)
 	 lastt = gtime[i][2]
 	end
 	
 	print(" ")
 	print("p:"..player.x.." "..player.y)
 	print("pt:"..ptx..","..pty)
 
 	print(" ")
 	
 end
 
 camx,camy=player.x,player.y
 local ctx,cty=w2wt(camx,camy)
  
  local mx,my=get_mouse()
  local wx,wy=screen2world(mx,my,camx,camy)
  local wtx,wty=w2wt(wx,wy)
  local ltx,lty=wt2lt(wtx,wty,ctx,cty)
  local tx,ty=screen_to_tlocal(mx,my,player.x,player.y)
  local t=mapget(tx,ty)
  mltx,mlty=ltx,lty
  
 if debugmouse then
  print("c "..camx.." "..camy)
  print("ct "..ctx.." "..cty)
  print("m "..mx.." "..my)
  print("mw "..wx.." "..wy)
  print("mwt "..wtx.." "..wty)
  print("mlt "..ltx.." "..lty)
  print(tx.." "..ty.." "..t)
  
  spr(207,mx,my)
  
  --minimap mouse dot
  pset(64+ltx,64+lty,0)
 end

 if debugpts then
  render_curve_pts(curves,ctx,cty)
 end
 
end

gptx=0
gpty=0
gsteps={}
rolmsg={}

debugfill=true
debugmap=false
debugmsgs=false
debugcol=true
debugmouse=false
-->8
--tile world (using memory map)


--we index into this with
--0,0 being top left (first tile)
--but note first and last rows
--are never drawn
--so if you want the top left
--(aka first) tile visible on 
--screen, then it's 1,1

mapw=19 //+1 for subpixel sliding
maph=19 //+2 so visible tiles have accurate neighbors

mapaddr = 0x4300

function copy_screen_map_to_mem()
 for x=0,mapw-1 do
  for y=0,maph-1 do
   poke(mapaddr+(x+y*mapw),pget(x,y))
   --screen 0x6000
  end
 end
end

--note 19x19 < 0x200
cacheaddr=0x4300+0x200

function copy_mem_map_to_cache()
 memcpy(cacheaddr,mapaddr,mapw*maph)
end

function compare_mem_maps(dx,dy)
 --designed to only work
 --if dx and dy are 1
 --also ignore borders for now
 local bld=4--border to egore
 if dy==1 or dx==1 then
  for x=bld+dx,mapw-1-bld do
   for y=bld+dy,maph-1-bld do
    local m=peek(mapaddr+((x-dx)+(y-dy)*mapw))
    local c=peek(cacheaddr+(x+y*mapw))
    if m!=c then
     cls()
     print(m.."!="..c)
     print(x..","..y)
     
     draw_map_from_mem(64,64,mapaddr)
     draw_map_from_mem(64+20,64,cacheaddr)
     
     return false
    end
   end
  end
 end
 return true
end


function mem_is_all_tile(addr,t)
 local bld=4--border to egore
 for x=bld,mapw-1-bld do
  for y=bld,maph-1-bld do
   if peek(addr+(x+y*mapw))!=t then
    return false
   end
  end
 end
 return true
end


--in tight loops, should
--just call peek/poke directly
function mapget(x,y)
 return peek(mapaddr+(x+y*mapw))
end

function mapset(x,y,t)
 poke(mapaddr+(x+y*mapw),t)
end


function lt2s(tx,ty)
   --the first screen tile (st=0)
   --is actually the second
   --local map tile (lt=1)
   --
   --but now we only need 8x8
   --out of a 16x16 map,
   --so skip 4 on each end
   --(start 4 more in from 0,0)
  local stx,sty=tx+1+4,ty+1+4
		return stx*16-8,sty*16-8
end

function screen2world(sx,sy,cx,cy)
 return cx+sx-64,cy+sy-64
end

--world x,y to world tile x,y
function w2wt(wx,wy)
 return flr(wx/tilesz),flr(wy/tilesz)
end

--world tile x,y to local map x,y
--note local map starts at 0,0
--but first visible tile is 5,5?
function wt2lt(wtx,wty,camtx,camty)
 return (wtx-camtx)+10,(wty-camty)+10
end

function w2lt(wx,wy,camwx,camwy)
 local wtx,wty=w2wt(wx,wy,camwx,camwy)
 local camtx,camty=w2wt(camwx,camwy)
 return wt2lt(wtx,wty,camtx,camty)
end

--screen x,y to tile local x,y
function screen_to_tlocal(sx,sy,camx,camy)
 local wx,wy=screen2world(sx,sy,camx,camy)
 --local wx,wy=sx+camx,sy+camy
 local wtx,wty=w2wt(wx,wy)
 local camtx,camty=w2wt(camx,camy)
 --local ltx,lty=wtx-camtx,wty-camty
 local ltx,lty=wt2lt(wtx,wty,camtx,camty)
 return ltx,lty
end


function draw_map_from_mem(sx,sy,addr)
 for mx=0,mapw-1 do
  for my=0,maph-1 do
			local t=peek(addr+(mx+my*mapw))
   pset(sx+mx,sy+my,t)
  end
 end
 color(6)
end


// {tile, flipx, flipy}
style2codes={
{0},
{1},
{1,true},
{2},
{1,false,true},
{3},
{4},
{5},
{1,true,true},
{4,true},
{3,true},
{5,true},
{2,false,true},
{5,false,true},
{5,true,true},
{6}
}

function draw_map_style2(scx,scy)

 --the full camera position
 --doesn't matter to this function,
 --only the sub-tile shift
 --
 --the memory tilemap is created
 --based on the camera location
 --here, we only draw it
 --and assume the tilemap 5?,5?
 --is the first tile we draw
 --
 --iterate over all visible tiles
 --starting in tl to br
 --note we draw 1 more than would 
 --fit perfectly on screen
 --since the screen might not 
 --line up exactly with the tiles
 --(sub-tile x,y -- passed in)
 
 --now we're iterating over
 --the spaces between our tiles
 --(the gaps)
 --and we check the 4 corners
 --of every gap we check
 
 --with 16x16 tiles,
 --there are only 9 on screen
 for stx=0,9 do
  for sty=0,9 do
  
   --the first screen tile (st=0)
   --is actually the second
   --local map tile (lt=1)
   --
   --but now we only need 8x8
   --out of a 16x16 map,
   --so skip 4 on each end
   --(start 4 more in from 0,0)
   local ltx,lty=stx+1+4,sty+1+4
   
   //actual screen draw location 
   //is shifted by our sub-tile values
   //-8 to offset tile halfway
			local sx,sy=stx*16-8-scx,sty*16-8-scy
   
   --check the corners of this gap
			local tl=peek(mapaddr+(ltx+lty*mapw))
			local tr=peek(mapaddr+((ltx+1)+lty*mapw))
			local bl=peek(mapaddr+(ltx+(lty+1)*mapw))
			local br=peek(mapaddr+((ltx+1)+(lty+1)*mapw))

			--setup like this:
			--tl tr bl br
			--1  0  1  0
			
			tl=(tile_is_land(tl) and 1 or 0)
			tr=(tile_is_land(tr) and 1 or 0)
			bl=(tile_is_land(bl) and 1 or 0)
			br=(tile_is_land(br) and 1 or 0)

			tl=shl(tl,3)
			tr=shl(tr,2)
			bl=shl(bl,1)
			
			local code=bor(tl,bor(tr,bor(bl,br)))
			 			
			local drawcode=style2codes[code+1]
			
			local id=(drawcode[1])*2+18
			local hf=drawcode[2]
			local vf=drawcode[3]
			
			spr(id,sx,sy,2,2,hf,vf)
 			
  end
 end

end
-->8
--player

player={
 x=(662+8)*tilesz, --overwritten
 y=(161+8)*tilesz, --by init
 d=0
}

u_frames_released = 0
d_frames_released = 0
l_frames_released = 0
r_frames_released = 0

diag_skip_counter = 0

function player_update(p)

 local frames_of_forgiveness = 2
 
 local u = btn(⬆️)
 local d = btn(⬇️)
 local l = btn(⬅️)
 local r = btn(➡️)
 
 if u then u_frames_released =0
      else u_frames_released+=1 end
 if d then d_frames_released =0
      else d_frames_released+=1 end 
 if l then l_frames_released =0
      else l_frames_released+=1 end
 if r then r_frames_released =0
      else r_frames_released+=1 end
      
 u_frames_released=min(u_frames_released,frames_of_forgiveness)
 d_frames_released=min(d_frames_released,frames_of_forgiveness)
 l_frames_released=min(l_frames_released,frames_of_forgiveness)
 r_frames_released=min(r_frames_released,frames_of_forgiveness)
      

 -- desired direction
 if u and not l and not r then p.d = 0 end
 if u and     l and not r then p.d = 1 end
 if l and not u and not d then p.d = 2 end
 if l and     d and not u then p.d = 3 end
 if d and not l and not r then p.d = 4 end
 if d and     r and not l then p.d = 5 end
 if r and not u and not d then p.d = 6 end
 if r and     u and not d then p.d = 7 end

 -- don't switch unless released button is up enough
 if (p.d == 0 and l_frames_released<frames_of_forgiveness) then p.d=1 end
 if (p.d == 0 and r_frames_released<frames_of_forgiveness) then p.d=7 end
 if (p.d == 2 and u_frames_released<frames_of_forgiveness) then p.d=1 end
 if (p.d == 2 and d_frames_released<frames_of_forgiveness) then p.d=3 end
 if (p.d == 4 and l_frames_released<frames_of_forgiveness) then p.d=3 end
 if (p.d == 4 and r_frames_released<frames_of_forgiveness) then p.d=5 end
 if (p.d == 6 and u_frames_released<frames_of_forgiveness) then p.d=7 end
 if (p.d == 6 and d_frames_released<frames_of_forgiveness) then p.d=5 end 



 if u or d or l or r then
 --if true then --always move for now
 
 	if not playing_music then 
 	  music(4)
 	  playing_music=true
 	end
  --music(1)
  --sfx(4,0)
  --sfx(5,0)
  
  xstep = 0
  ystep = 0
  
  speed = 1
  if (btn(🅾️)) then speed=4 end
  skip_diag_every = 10

  angle = p.d / 8 --pico trig is percent of circle (0-1 is 0-360)
  xstep = round(sin(angle))*speed
  ystep = -round(cos(angle))*speed

  --skip diag here
  diag_skip_counter=(diag_skip_counter+1) % skip_diag_every
  if (xstep==0 or ystep==0) then
   --straight movement
   --note the implied movement in the u d l r check
  else
   if (counter==0) then
    xstep=0
    ystep=0
   end
  end
  
  -- collisiton detection here 
  local allowx=true
  local allowy=true
  if debugcol then
   local hotspotsx={0,7}
   local hotspotsy={0,7}
   for j=1,#hotspotsy do
    local hy=hotspotsy[j]
    for i=1,#hotspotsx do
     local hx = hotspotsx[i]
     
     local sx,sy=64+hx,64+hy
     local ptx,pty=
      screen_to_tlocal(sx,sy,player.x,player.y)
     local ntx,nty=
      screen_to_tlocal(sx+xstep,sy+ystep,player.x,player.y)
     
     --recall we test 1 dir at a time so we can slide against walls
     testtilex = peek(mapaddr+(ntx+pty*mapw))
     if (tile_is_land(testtilex)) allowx = false
     testtiley = peek(mapaddr+(ptx+nty*mapw))
     if (tile_is_land(testtiley)) allowy = false
    end
 	 end
	 end
     
  if not btn(❎) then
   if allowx then p.x += xstep end
   if allowy then p.y += ystep end    
  end
  local ptx,pty=w2wt(p.x,p.y)
  dset(0,ptx)
  dset(1,pty)
 else
  -- not moving
  playing_music=false
  music(-1)
 end

end




function player_draw(p)
 
 hull = 160-64
 --spr(hull+p.d,p.x-cam.x,p.y-cam.y)
 spr(hull+p.d,64,64)
 
 sail = 80
 --spr(sail+p.d,p.x-cam.x,p.y-3-cam.y)
 spr(sail+p.d,64,64-3)


  hotspotsx={0,7}
  hotspotsy={0,7}
  for j=1,#hotspotsy do
   hy=hotspotsy[j]
   for i=1,#hotspotsx do
    hx = hotspotsx[i]
    pset(64+hx,64+hy,14)
   end
  end

end
-->8
--util



function pinrect(p,r)
 return p[1]>=r[1] and
        p[2]>=r[2] and
        p[1]<r[3] and
        p[2]<r[4]
end


--round to nearest int
function round(num)
 if num>0 then return flr(num+0.5) 
 else return ceil(num-0.5) 
 end
end

function test_round()
 y = 64
 print(round(4.6),0,y,0) y+=8
 print(round(4.5),0,y,0) y+=8
 print(round(4.2),0,y,0) y+=8
 print(round(-1.1),0,y,0) y+=8
 print(round(-3.5),0,y,0) y+=8
 print(round(-3.6),0,y,0) y+=8
end



-->8
--generating map on screen buffer
--bezier

tile_water=12
tile_land=11
tile_fill_water=1
tile_fill_land=3
tile_border=4
tile_test=14
tile_nil=0

function tile_is_land(t)
 return t==tile_land
     or t==tile_border
     or t==tile_fill_land
end

function aabb_col(r1,r2)
 return
  r1[1]<r2[3] and r1[3]>r2[1] and
  r1[2]<r2[4] and r1[4]>r2[2]
end
function tri_bb(t)
 lt=min(min(t[1][1],t[2][1]),t[3][1])
 rt=max(max(t[1][1],t[2][1]),t[3][1])
 tp=min(min(t[1][2],t[2][2]),t[3][2])
 bt=max(max(t[1][2],t[2][2]),t[3][2])
 return {lt,tp,rt,bt} 
end
function tri_cuts_rect(r,t)
 --just check the tri bounding box lol
 return aabb_col(r,tri_bb(t))
end


function curves_in_rect(r)
 result={} 
	num_curves = (#pts-1)/2
	for i=0,num_curves-1 do
	 local p1=pts[i*2+1]
	 local dx=abs(p1[1]-r[1])
	 local dy=abs(p1[2]-r[2])
	 if dx<100 and dy<100 then -- faster, coarse check
 	 local p2=pts[i*2+2]
 	 local p3=pts[i*2+3]
 	 local t={p1,p2,p3}
 	 if tri_cuts_rect(r,t)
  	then
  	 add(result,t)
 	 end
	 end
	end
	return result
end

function render_curve_pts(crvs,ctx,cty)
 
	if (not crvs) return
	num_curves = #crvs
	for i=1,num_curves do
	 for t=1,3 do
	  stx=crvs[i][t][1]
	  sty=crvs[i][t][2]
	  lx,ly=wt2lt(stx,sty,ctx,cty)
	  
	  sx,sy=lt2s(lx,ly)
	  			
	  --world
 	 pset(sx,sy,9)
 	 
 	 --minimap
 	 pset(64+lx,64+ly,1)
 	 
 	 if mltx==lx and mlty==ly then
 	  pset(64+lx,64+ly,1)
 	  print(stx..","..sty)
 	 end
 	 
	 end
	end
	
end

--map at 0,0,mapw,maph
function flood_fill(x,y,t,nt)
 if x>=0 and y>=0 and 
    x<mapw and y<maph
 then
  --local tt=peek(mapaddr+(x+y*mapw))
  local tt=pget(x,y)
  if tt==tile_nil
  or tt==t
  then
   --poke(mapaddr+(x+y*mapw),nt)
   pset(x,y,nt)
   flood_fill(x-1,y,t,nt)
   flood_fill(x+1,y,t,nt)
   flood_fill(x,y-1,t,nt)
   flood_fill(x,y+1,t,nt)
  end
 end
end

function fill_map() 

 if debugfill then

  local wdtx,wdty=w2lt(player.x,player.y,player.x,player.y)
  flood_fill(wdtx,wdty,tile_nil,tile_water)
 
  --fill lakes here
  
  --rest default to land
  for x=0,mapw-1 do
   for y=0,maph-1 do
    local t=pget(x,y)
    if t==tile_nil
    or t==tile_fill_land
    then
     pset(x,y,tile_land)
    end
   end
  end
  
 end
 
end


function fill_islands(mx,my)
 for i=1,#islands do
  local lx=islands[i][1]-mx
  local ly=islands[i][2]-my
  if lx>=-16 and ly>=-16 and
     lx<mapw and ly<maph then
   --poke(mapaddr+(lx+ly*mapw),tile_test)
   spr(islands[i][3],lx,ly,2,2)
  end
 end
end



function gen_map(curves,tx,ty)
	result = {}
	if (not curves) return result
	num_curves = #curves
	for i=1,num_curves do
	 plotbez(tx,ty,curves,i)
	end
	return result
end




function plotbez(mx,my,curves,i)

	local x0=curves[i][1][1]
	local y0=curves[i][1][2]
	local x1=curves[i][2][1]
	local y1=curves[i][2][2]
	local x2=curves[i][3][1]
	local y2=curves[i][3][2]

 --triangle dist
 --should always over estimate
 --and small for straight curves
 --better than using start-to-end 
 --distance and scaling up by some guess factor
 --(which was the old method)
 local leg1dx=abs(x1-x0)
 local leg1dy=abs(y1-y0)
 local leg2dx=abs(x2-x1)
 local leg2dy=abs(y2-y1)
 local dist=leg1dx+leg1dy+leg2dx+leg2dy

 local steps=dist
 local lastp={x0,y0}
 for t = 0,1,(1/steps) do
  
  local x=((1-t)^2)*x0 + 2*(1-t)*t*x1 + (t^2)*x2
	 local y=((1-t)^2)*y0 + 2*(1-t)*t*y1 + (t^2)*y2
    
  local lx = x-mx
  local ly = y-my
  local llx=lastp[1]-mx
  local lly=lastp[2]-my
  line(round(lx),round(ly),
       round(llx),round(lly),
       tile_border)
  
  lastp = {x,y}
  
 end 

end

-->8
--raw world data



--[[
 -- to iterate over all curves
	num_curves = #curves
	for i=1,num_curves do
	 p1=curves[i][1]
	 p2=curves[i][2]
	 p3=curves[i][3]
]]

islands={
{657,172,16}
}

pts = {
{538, 255},
{537, 248},
{534, 240},
{537, 236},
{538, 230},
{544, 229},
{544, 222},
{548, 221},
{549, 216},
{557, 214},
{560, 208},
{561, 195},
{568, 193},
{573, 192},
{574, 185},
{577, 189},
{586, 189},
{589, 184},
{594, 185},
{595, 181},
{601, 182},
{614, 181},
{624, 180},
{627, 183},
{628, 187},
{618, 193},
{641, 199},
{643, 205},
{649, 203},
{654, 209},
{657, 205},
{659, 205},
{657, 198},
{665, 195},
{673, 202},
{689, 205},
{693, 201},
{700, 206},
{705, 202},
{710, 189},
{708, 180},
{703, 180},
{702, 183},
{696, 184},
{694, 180},
{689, 179},
{689, 183},
{678, 178},
{678, 168},
{689, 166},
{700, 161},
{713, 167},
{722, 165},
{728, 159},
{719, 155},
{715, 151},
{709, 149},
{717, 144},
{711, 141},
{701, 141},
{700, 147},
{708, 145},
{705, 150},
{700, 151},
{696, 146},
{693, 144},
{690, 142},
{678, 150},
{681, 163},
{678, 167},
{673, 164},
{667, 163},
{664, 166},
{663, 169},
{666, 172},
{664, 175},
{661, 174},
{658, 170},
{655, 167},
{659, 159},
{649, 157},
{643, 155},
{641, 149},
{634, 151},
{636, 147},
{630, 143},
{632, 153},
{638, 156},
{636, 159},
{640, 161},
{643, 162},
{648, 165},
{646, 168},
{643, 170},
{638, 165},
{632, 162},
{628, 158},
{625, 149},
{617, 153},
{613, 158},
{610, 154},
{602, 154},
{602, 161},
{598, 164},
{595, 165},
{592, 167},
{591, 174},
{591, 178},
{586, 178},
{587, 181},
{583, 181},
{578, 180},
{574, 182},
{572, 177},
{564, 180},
{567, 169},
{563, 171},
{569, 171},
{566, 157},
{572, 154},
{579, 155},
{593, 161},
{591, 144},
{587, 144},
{588, 140},
{588, 138},
{585, 139},
{580, 139},
{583, 135},
{591, 139},
{591, 132},
{600, 134},
{600, 127},
{605, 127},
{609, 127},
{608, 124},
{610, 122},
{614, 123},
{612, 118},
{618, 118},
{623, 116},
{622, 111},
{621, 107},
{624, 104},
{626, 102},
{628, 106},
{624, 109},
{625, 118},
{634, 115},
{638, 119},
{640, 116},
{644, 115},
{648, 112},
{653, 117},
{655, 112},
{659, 114},
{657, 104},
{660, 101},
{666, 106},
{667, 100},
{664, 98},
{661, 95},
{673, 96},
{675, 94},
{681, 94},
{680, 89},
{665, 92},
{656, 93},
{657, 83},
{672, 74},
{663, 72},
{652, 71},
{655, 79},
{642, 83},
{645, 93},
{648, 91},
{648, 95},
{643, 95},
{641, 98},
{646, 103},
{643, 105},
{639, 105},
{635, 111},
{635, 104},
{631, 101},
{628, 90},
{621, 99},
{613, 100},
{616, 91},
{619, 92},
{620, 90},
{618, 88},
{615, 87},
{617, 84},
{622, 82},
{628, 85},
{627, 79},
{633, 80},
{635, 70},
{646, 66},
{646, 62},
{651, 63},
{658, 58},
{675, 56},
{681, 62},
{697, 63},
{704, 69},
{701, 73},
{682, 68},
{683, 73},
{688, 72},
{690, 80},
{697, 80},
{699, 78},
{695, 76},
{697, 75},
{703, 79},
{708, 79},
{703, 74},
{706, 72},
{710, 71},
{716, 75},
{714, 69},
{721, 71},
{723, 68},
{729, 65},
{733, 63},
{735, 68},
{738, 64},
{744, 66},
{746, 63},
{753, 66},
{751, 60},
{755, 61},
{757, 60},
{784, 70},
{764, 56},
{770, 41},
{785, 66},
{778, 77},
{788, 68},
{790, 66},
{787, 64},
{807, 65},
{785, 60},
{784, 59},
{779, 54},
{782, 49},
{783, 54},
{790, 56},
{789, 51},
{820, 67},
{792, 48},
{807, 49},
{806, 43},
{831, 43},
{833, 36},
{839, 38},
{863, 41},
{838, 57},
{863, 47},
{894, 51},
{893, 47},
{906, 47},
{919, 57},
{922, 58},
{921, 54},
{942, 57},
{934, 51},
{960, 52},
{973, 56},
{994, 54},
{994, 60},
{1039, 65},
{1021, 58},
{1055, 62},
{1074, 69},
{1099, 73},
{1084, 74},
{1097, 81},
{1077, 74},
{1056, 68},
{1069, 75},
{1057, 77},
{1077, 83},
{1067, 84},
{1064, 93},
{1058, 89},
{1055, 94},
{1045, 89},
{1050, 101},
{1062, 105},
{1059, 125},
{1030, 105},
{1041, 99},
{1045, 81},
{1036, 84},
{1041, 94},
{1031, 87},
{1019, 83},
{1022, 97},
{1014, 94},
{1008, 95},
{986, 94},
{990, 102},
{982, 115},
{988, 113},
{997, 120},
{998, 114},
{1013, 120},
{1011, 126},
{1019, 138},
{1013, 154},
{1009, 160},
{1004, 156},
{999, 159},
{1002, 167},
{990, 166},
{1009, 182},
{1010, 188},
{1000, 189},
{999, 178},
{990, 175},
{989, 165},
{978, 172},
{978, 159},
{970, 171},
{963, 173},
{968, 176},
{974, 175},
{972, 180},
{977, 181},
{977, 176},
{987, 179},
{981, 181},
{975, 188},
{980, 190},
{996, 204},
{986, 206},
{993, 207},
{991, 211},
{988, 235},
{972, 238},
{962, 237},
{962, 244},
{959, 245},
{960, 240},
{949, 237},
{947, 250},
{971, 272},
{958, 282},
{953, 282},
{951, 288},
{948, 292},
{948, 283},
{939, 275},
{935, 273},
{931, 263},
{929, 286},
{933, 289},
{934, 295},
{945, 301},
{945, 312},
{952, 323},
{940, 314},
{934, 307},
{933, 297},
{930, 291},
{926, 290},
{927, 273},
{922, 261},
{920, 252},
{915, 262},
{909, 264},
{910, 250},
{897, 241},
{902, 241},
{898, 239},
{899, 236},
{895, 231},
{892, 239},
{880, 238},
{883, 244},
{877, 247},
{875, 252},
{870, 254},
{869, 261},
{862, 259},
{862, 268},
{864, 273},
{863, 277},
{863, 284},
{860, 283},
{861, 289},
{857, 287},
{856, 296},
{852, 287},
{835, 251},
{835, 241},
{834, 233},
{833, 242},
{826, 244},
{823, 237},
{830, 235},
{822, 233},
{815, 231},
{813, 225},
{783, 227},
{780, 219},
{780, 216},
{772, 220},
{766, 215},
{761, 215},
{757, 202},
{749, 209},
{751, 217},
{756, 219},
{765, 240},
{778, 222},
{779, 234},
{788, 233},
{795, 237},
{786, 243},
{787, 246},
{786, 249},
{781, 248},
{782, 253},
{776, 252},
{776, 257},
{769, 257},
{767, 262},
{754, 269},
{743, 273},
{736, 275},
{739, 270},
{735, 267},
{735, 261},
{731, 250},
{722, 242},
{723, 232},
{714, 227},
{713, 218},
{707, 215},
{708, 200},
{705, 216},
{694, 199},
{702, 218},
{711, 230},
{710, 234},
{717, 238},
{717, 250},
{724, 254},
{723, 261},
{726, 267},
{730, 267},
{739, 275},
{737, 279},
{739, 285},
{751, 281},
{758, 281},
{764, 277},
{765, 290},
{761, 292},
{754, 310},
{742, 318},
{718, 343},
{723, 349},
{725, 359},
{728, 364},
{732, 389},
{718, 390},
{714, 396},
{707, 399},
{711, 420},
{706, 420},
{698, 422},
{700, 429},
{700, 435},
{693, 439},
{684, 457},
{664, 456},
{660, 457},
{656, 458},
{651, 457},
{651, 453},
{653, 445},
{649, 441},
{649, 433},
{643, 431},
{640, 428},
{640, 411},
{636, 407},
{636, 403},
{633, 396},
{630, 392},
{633, 380},
{633, 375},
{639, 371},
{635, 361},
{637, 352},
{633, 349},
{632, 340},
{622, 331},
{620, 323},
{624, 322},
{626, 305},
{622, 308},
{617, 304},
{610, 306},
{606, 293},
{583, 305},
{576, 301},
{562, 306},
{554, 297},
{547, 294},
{546, 285},
{540, 282},
{539, 278},
{534, 276},
{534, 270},
{532, 267},
{535, 260},
{538, 255},
}
-->8
--mouse

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


__gfx__
0000000033bbbbbbddddddddb666666db653356dd666666dbbb3956dd653356dbbb3956dd666666dbbbbbbbb0000000000000000000000000000000000000000
00000000b333bbbbdddddddd665555666653356666555566bbb3956666533566bbb3956666555566bbbbbbbb0000000000000000000000000000000000000000
00700700bbbbb33bddddd66d655995566553355655599556bbb3955665533556bbb3955655599555bbbbbbbb0000000000000000000000000000000000000000
0007700033bbbbb3dddddddd6593395665933956333399563333995665933956bbb3995633333333333333330000000000000000000000000000000000000000
00077000bb33bbbbdddddddd6593395665999956333399569999995665933956bbb3995633333333999999990000000000000000000000000000000000000000
007007003bbb33bbdd66dddd6559955665599556555995565559955665533556bbb3955655599555555995550000000000000000000000000000000000000000
00000000b33bbbbbdddddddd6655556666555566665555666655556666533566bbb3956666555566665555660000000000000000000000000000000000000000
00000000bbbb333bddddddddd666666dd666666db666666dd666666dd653356bbbb3956db666666dd666666d0000000000000000000000000000000000000000
000b0000000bb000dddddddddddddddddddddddddddddddddddddddddddddddd66dddd65593bbbbbddddddd6593bbbbbddd66d65593bbbbb33bbbbbb33bbbbbb
0b000bbbbb000bb0dddddddddddddddddddddddddddddddddddddddddddddddddddddd66593bbbbbddddddd65933b33bdddddd65993bbbbbb333bbbbb333bbbb
bb00000bbbbb00b0ddddd66dddddd66dddddd66dddddd66dddddd66dddddd66dddddddd6593bb33bdddd66d65993bbbbddddd665933bb33bbbbbb33bbbbbb33b
b00000000bbbb000ddddddddddddddddddddddddddddddddddddddddddddddddddddddd6593bbbbbddddddd655933bbb66ddd65593bbbbb333bbbbb333bbbbb3
000bb000bb00b000dddddddddddddddddddddddddddddddddddddddddddddddddddddd66593bbbbbddddddd66599333bdddd665993bbbbbbbb33bbbbbb33bbbb
0bbbbbbbb0000000dd66dddddd66dddddd66dddddd66ddddddddddddddddddddddd66d65593b33bbdd66ddd665599933dd66655933bb33bb3bbb33bb3bbb33bb
bbbbbbbbbb000000ddddddddddddddddddddddddddddddd666666dd666666dd6dddddd65993bbbbbdddddddd66555999666555993bbbbbbbb33bbbbbb33bbbbb
bbbbbbbb0bb00000ddddddddddddddddddddddddddd666665555666655556666dddddd65993bbbbb66666dddd6665555555599933bbb333bbbbb333bbbbb333b
0bbbbbbb00000000ddddddddddddddddddddddddd6665555599555555995555566dddd65593bbbbb5555666dddd6666659999333bbbbbbbb33bbbbbb33bbbbbb
00bbbbbbb0000000dddddddddddddddddddddddd665559999999999999999999dddddd66593bbbbb99955566dddddddd993333bbbb33bbbbb333bbbbb333bbbb
00bbbb0bb0000000ddddd66dddddd66ddddd66dd655999333333333333333333ddddddd6593bb33b33999556dddd66dd333bbbb33bbbb33bbbbbb33bbbbbb33b
00bb0b00bb000000ddddddddddddddddddddddd66599333bbbbbbbbbbbbbbbbbddddddd6593bbbbbb33399566dddddddbbbbbbbbbbbbbbb333bbbbb333bbbbb3
000b0b0000000000ddddddddddddddddddddddd655933bbbbb33bbbbbb33bbbbdddddd66593bbbbbbbb339556dddddddbb33bbbbbb33bbbbbb33bbbbbb33bbbb
000000b0b0000000dd66dddddd66dddddd66ddd65993bbbb3bbb33bb3bbb33bbddd66d65593b33bbbbbb39956d66dddd3bbb33bb3bbb33bb3bbb33bb3bbb33bb
0000000000000000ddddddddddddddddddddddd65933b33bb33bbbbbb33bbbbbdddddd65993bbbbbb33b33956dddddddb33bbbbbb33bbbbbb33bbbbbb33bbbbb
0000000000000000dddddddddddddddddddddd66593bbbbbbbbbbbbbbbbbbbbbdddddd65993bbbbbbbbbb3956dddddddbbbbbbbbbbbbbbbbbbbb333bbbbb333b
000000000000000000000000bbbbb36d00000000bbb3956db666666d00000000d653356d00000000000000000000000000000000000000000000000000000000
000000000000000000000000bbbbb36600000000bbb3956666555566000000006653356600000000000000000000000000000000000000000000000000000000
000000000000000000000000bbbb335600000000bbb3955665599556000000006553355600000000000000000000000000000000000000000000000000000000
00000000000000000000000033333956000000003333995665933956000000006593395600000000000000000000000000000000000000000000000000000000
00000000000000000000000099999956000000009999995665933956000000003333333300000000000000000000000000000000000000000000000000000000
00000000000000000000000055599556000000005559955665599556000000005559955500000000000000000000000000000000000000000000000000000000
00000000000000000000000066555566000000006655556666555566000000006655556600000000000000000000000000000000000000000000000000000000
000000000000000000000000d666666d00000000d666666dd666666d00000000d666666d00000000000000000000000000000000000000000000000000000000
11111100111111000011110000011100001111110011111100111100111111000011111100111110000111110011100000111000001111110011110000111111
17112100177721000111210001112111001217710012177100127110177121000012117100121710001111711112110000121110001217710012711000127771
17712100177721000117710001177771011777710011777100121710177121000012177100121710011121711177710001177710001177710012171000127771
17712111177721110177210001777711117777110117777100121710177121111112177111121710017121711777110011777710011777710012171011127771
17712171167121710176210001677711177777111177777100117710116121711712177117121610017121111677110017777110117777710011771017121761
16612171116121710176211101677711177777111677776101177710011121711712166117121110017111001677110017777110167777610117771017121611
11112111011121110116216101677771166666611666661101666110001126611112111016621100011611001677710016666610166666110166611011121110
00011100000111000011111101111111111111111111111001111100000111110011100011111000001111001111100011111110111111100111110000111000
01111100011111000111100000011100000111000001110000011110001111001111100011111000011110000011100000111000001111110011110001111000
01112100017721001112100000112110000121110001211100012711001721001112100017721000111210000112110000121110001217710012711001721000
01712100017721001177100001177710001117710011177100012771001721101712100017721000117710001177710001177710001177710012771001721000
01712111017721111772100001777710011777710117777100012171001727111712111017721110177210001777110011777710011777710012171001727110
01712171017121711762100001777110117777111177777100011171001727711712171017121710177210001677110017777110117777710011171001727710
01612161016121711762111001777110177777111777777100111771001121711612161016121710177211101677110017777110167777610111771001121710
01112111011121111162161001666610176666611166661100166611001121611112111011121110117217101677710016666610166666110166611001121610
00011100000111000111111001111110111111110111111000111110000111110011100000111000011111101111110011111110111111100111110000111110
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044000000000000000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000000000000
00000000005200004400000000522250000000000522250000000044000002500000000000000000000000000000000000000000000000000000000000000000
00522250075522200522225004455557005242507555544005222250002225570000000000000000000000000000000000000000000000000000000000000000
07555557007755577555555775557777075545577777555775555557075557700000000000000000000000000000000000000000000000000000000000000000
07777777000077707777777707777000077777770007777077777777007770000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777c77cccccccccccccc77777777ccc000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc77cccccccc7cccc77777777ccc000000013100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc77cc7777777ccc777cc777cccc000000113110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc7777777c777777777ccccccccc000000133310000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc7777ccccccccc7777ccccccccc000001133311000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccc7cccccccccccc77cccccccccc000001333331110000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccc7ccccccccccccc7cccccccccc000001333331b10000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccc77cccccccccccc7cccccccccc000001333311b11000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc77ccccccccccc77ccccccccc00001113331bbb1000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccc77ccccccccccc7ccccccccc00011b11311bbb1100000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccc77ccccccccccc7ccccccccc0001bbb131bbbbb100000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc7ccccccccccc7777cccccc0001bbb111bbbbb100000000000000000000000000000000000000000000000000000000000000000000000000000000
777cccccc77cccccccccccc777c777cc110111110111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
7777cccc777cccccccccccc77777777c000001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc777cc777ccccccccccc777777cc777011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc77777cccccccccccc77ccc77cc7cc000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc77777cccccccccccc77cccc77c7cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc77777ccccccccccc77ccccc7777cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc7777777cccccccccc77cccccc77777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777cccc777cccccccc77cccccc77c77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77cccccc7777777ccc77ccccccccc777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccc7777777cc7cccccccccc777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7cccccccccccc7777777cccccccccc77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777ccccccccccccc7777cccccccccc77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777ccccccccccc777cccccccccc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc777cccccccccccc77ccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc777cccccccccccc77ccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccc77ccccccccccc77cccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc7ccccccccccc77cccccc77cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc7ccccccccccc7cccccccc777cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccc77ccccccccccc777ccccccc7777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7cccc7ccccccccccccc777cccc777ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc7777cccccccccccc777777777cccc11d1111111111111dddddddddddddddd22222222222222222222222222222222d653bbbbbbbbbbbb0555550077000000
cccc7777ccc777777ccc77777c7cccccdd1dd111111d1111dddddddddddddddd22222222222222222222222222222442d653bbbbbbbbbb3b55a5955071700000
ccccc777777777c77ccc77cccccccccc111111111dd1dd11dddddddddddd666d224422222222222222222222222222226633bb3bbb33bbbb5aa5995071170000
ccccccc7777ccccc77777ccccccccccc1111111111111111dddd666ddddddddd22222222224442222224442222222222653bbbbbbb33bbbb5aa5995071117000
ccccccc77cccccccc77777cccccccccc1111d11111111111dddddddddddddddd22222222222222222222222222222222653bbbbbbbbbbbbb5a55595071111700
cccccccc7ccccccccc7777cccccccccc111d1dd111111d11d666ddddd666dddd222222222222222222222222222222226533bbbbbbbbb3bb5555555071177700
ccccccc77ccccccccccc77cccccccccc111111111111d1dddddddddddddd666d222222222222222222222222222222226553bbbbb3bbbbbb5544455077770000
ccccccc77ccccccccccc77cccccccccc1111111111111111dddddddddddddddd222222222222222222222222222444226653bbbbbbbbbbbb5441445000000000
ccccccc777cccccccccc777ccccccccc11d1111111111111dddddddddddddddd44222444422222442222222222222222d653b3bbbbbbbbbb0000000011111111
ccccccccc77ccccccccc77777ccccccc1d1dd11111d11111dd66dddddddddddd55444555544444552222222222222222d633bbbbbbbb3bbb0000000017777771
ccccccccc77ccccccccc77777ccccccc11111111dd1dd11166dd666ddddddddd55555555555555552222222222222222663bbb3333bbbb330000000017555771
cccccccc777cccccccccc777cccccccc1111111111111111dddddddddddd666d6555556655555566222444222222222265333335533333350000000017575d71
ccccccc7777ccccccccccc7777cccccc1111d11111111111ddddddddd666dddd665556666555566d222222222222222265333555553333550000000017555d71
7777cc777ccccccccccccc7777777ccc111d1dd11111d111d666ddddddddddddd66666dd666666dd2222222224422222655555555555555500000000177ddd71
777777777ccccccccccc77777777777711111111111d1dd1ddddddddddddd666dddddddddddddddd222222222222222265555666655556660000000017777771
ccc77777ccccccccccc777ccc77cc7cc1111111111111111dddddddddddddddddddddddddddddddd2222222222222222666666dd666666dd0000000011111111
ccc77777ccccccccc7777ccccc77c7cc11d111dd11d111ddcccccccccccccccc33b33bbb00000000bbbb6bbbbbb3b6bb66bb3b66000000001111111111111111
cc7777777cccccccc77cccccccc777ccdd1dd111dd1dd111ccccccccccccccccb3bb33b300000000bbb366b3b6bb36bbb36bb3b60000000017776d7111177771
c77777777777ccccc7cccccccccc777711111ddd11111dddcccccccccccc66ccb333b33b000000003b6bbb66bbb6bb6bbbb3b63b000000001776dd7111111771
77cccccc7777777c77cccccccccccc771dd111111dd11111cccc66ccccccccccbbb3b3bb00000000b3b6bb36bbb36b3b66bb3b6300000000176ddd7111177771
ccccccccc77777777ccccccccccccc771111d1111111d111cccccccccccccccc3b3b33b300000000bbbb6bb33bbbb3bbb3636bbb0000000017ddd77111777771
ccccccccccccc7777cccccccccccccc7111d1dd1111d1dd1c666cccccc66ccccb3bbb3b300000000333bbbbbb6bbbbbbbbb636b30000000017dd777111177771
7cccccccccccccc77cccccccccccccc7dd111111dd111111ccccccccccccccccb3b3bb33000000002233333b3333333363bbb36b000000001577777117777771
777ccccccccccccc77ccccccccccccc71111dd111111dd11cccccccccccccccc333b33b3000000002222223332223333b63bbbb6000000001111111111111111
7777ccccccccccccc777ccccccccccc711d111dd11d111ddcccccccccccccccc3bbbbbbb3bbb33bb9998599985985998bbbbbbbbbfbbfbbf1111111111111111
c77777cccccccccccc77ccccccccccccdd1dd111dd1dd111cccccccccccccccc93b33bb54344443b9998599985985998bbbbbbbbbbfbbfbb1bbbbbb117b7b7b1
cc77777cccccccccc77ccccccccccccc11111ddd11111dddcccc66cccccccccc933a99354a94a9939998599959985998bbbbbbbbfbbfbbfb1b1111b11b7b7b71
ccc777ccccccccccc77ccccccccccccc1dd111111dd11111ccccccccccccc66c9a999a954995a995999559985995998833b333bb333333331b13313117b33331
ccc77cccccccccccc777cccccc77cccc1111d1111111d111cccccccccccccccc99955a9549959995555599985995885593339999aaa95aa91b1331c11b73ccc1
ccc77cccccccccccc7777cccccc777cc111d1dd1111d1dd1cc66ccccc66ccccc799565555545944566665888555555569999955555595555131111c11333ccc1
7ccc7cccccccccccc7777ccccccc7777dd111111dd111111ccccccccccccccccc777677677555555ddd665555666666666995566665555661cccccc11cccccc1
777777cccccccccccc7777cccc777ccc1111dd111111dd11cccccccccccccccccccccccccc777777dddd666666ddddddd666666dd666666d1111111111111111
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c7c7cccdcdcdcdcd0000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000
cacbcacbc7c7cccdcdcdcdcd0000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201010202020000000000000000000000000000000000000000
dadbdadbc7c7cccdcdcdcdcd0000c0c1c2c3c0c1c2c300000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201020202020000000000000000000000000000000000000000
c8c9c8c9c7c7dcdddddddddd0000d0d1d2d3d0d1d2d300000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201020202020000000000000000000000000000000000000000
d8d9d8d9c7c7c7c7c7c7c7c70000e0e1e2e3e0e1e2e300000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201010202020000000000000000000000000000000000000000
c7c7c7c7c7c7c7c7c7c7c7c70000f0f1f2f3f0f1f2f300000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202010202020000000000000000000000000000000000000000
c7c7c7c7c7c7c7c7c7c7c7c70000c0c1c2c3c0c1c2c300000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202010102020000000000000000000000000000000000000000
c7c7c7c7c7c7c7c7c7c7c7c70000d0d1d2d3d0d1d2d300000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020102020000000000000000000000000000000000000000
0000000000000000000000000000e0e1e2e3e0e1e2e300000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020102020000000000000000000000000000000000000000
0000000000000000000000000000f0f1f2f3f0f1f2f300000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020102020000000000000000000000000000000000000000
00ecec00fdfdfdfcfc0000e8e8e8e80000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101020000000000000000000000000000000000000000
00eaeb00c7c7c7c7c700e7f8f9f9f80000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101020000000000000000000000000000000000000000
00fafb00000000000000e7e7e7e7e70000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020102020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101010101010101010102020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201010102020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201020202020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101020202020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101020202020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101020202020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101020202020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101020202020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020101020202020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201010202020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202010102020202020202020202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000
__sfx__
000100001405014050140501405015050170501a0501e0502204025030290302d0200300001000070000100001000010000100002000020000300003000030000200002000030000300002000010000100000000
01130010016140161102611026150361404611056110561105615056140461103611016110161501610016100d0000d0000d0000d0000d0000460005600056000560005600046000361101611016150000000000
00130018026140361104611086110c6110e6110f6110f6110c6110861104615006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
001300200d6510e6511165114651186511a6511d6511f651246512665127651286512865129651296512965129651276512665125651226511f6511c6511a65118651166511465112651106510f6510e6510d651
011000101f70016641166311662116611166111661516600166001660016600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000100060022610026000260002600026000260002600026000360003600036000360003600026000260002600026000160001600016000160001600016000160001600016000160000600006000060000600
011000002150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c7070e7071070711707070002d0002400000700007000070000700007000270002700027000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
011100000c6240c6211362113621106211062117621176210e6210e6210e6210e6210e6210e6210e6210e6210c6210c6211362113621106211062117621176210e6210e6210e6210e6210e6210e6210e6210e625
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c6050f605000000c605106053f6050c6050c6053f6053f6050c6053f605106050c6050c6053f6050f6050f6050c605106053f6050c6050c6050f6050f6050c6050c6050c6050c6053f6050000000000
001000000560300600006030560300603006030060300603006030060300603006030060338603006030060300603006030060300603306030060300603006030060300603006030060330603006030060300603
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000000200002000020021250212502225000200242500020027250292502b2502d2502d2502d250282500020025250212501f2501d2501c2501a250002000020000200002000020000200002000020000200
011000000e3030000018150181530e3031a1500e3031d1501d150000000e30300000251532615027153291502b1502c150241501e15000000000001b1501d1500000000000000000000000000000000000000000
011000000e605000002a355000002a3530e6002a3512b3510e6002b3500e6052b3502b3530e6000e6012b35500000000002c35000000000002c35000000000002c350000002c350000002d350000002d35000000
001000000470004702047020470504700047020470204705057000570205702057050470004702047020470204700047020070200705007020070200702007050070000702047020470504702047020470204705
001000001030200300003001030210302003001130211302113021130210302103021030010300113021130210302103021130211302103021030211300113000030000300003000030000300003000030000300
00100000103020030000300103021030200300113021130211302113021030210302103001030011300113000e3020e3010e30110300113021130111301113001030210301103011030010300103000030000300
011600000e1500e1500e1500e150131501315011150111501015010150171501715015150151501515015150101501015010150101500e1500e15010150101500c1500c1500c1500c15000100001000010000100
0119000026150261612d1502d15132150321612d1502d16126150261612d1502d15132150321612d1502d16126150261612d1502d15134150341612d1502d16126150261612d1502d15132150321612d1502d161
__music__
03 03424344
03 04054344
03 0a0b4344
03 0f101113
00 01424344

