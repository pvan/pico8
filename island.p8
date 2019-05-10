pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

a=64
b=80
c=96
d=112

blocks={
128,  //1 water
132,  //2 grass
136,  //3 dirt
140,  //4 sand
}

xsteps={1,0,-1,0}
ysteps={0,1,0,-1}


tw=32    //tile width
th=tw/2  //tile height
htw=tw/2 //half tile width
hth=th/2 //half tile height


function init_tiles()
 tiles={}
 for x=1,20 do
  row={}
  for y=1,20 do
   row[y]={2}
   if (rnd(20)<2) row[y]={3}
   if (rnd(20)<1) row[y]={4}
   if (rnd(10)<2) add(row[y],rndbw(3,4))
   if (rnd(50)<2) add(row[y],rndbw(3,4)) add(row[y],rndbw(3,4))
   if (x==10 and y==10) row[y]={4,4,4,4}
  end
  tiles[x]=row
 end
end


function tget(x,y)
 local row=tiles[x]
 if (row==nil) return {}
 if (row[y]==nil) return {}
 return row[y] 
end


function iso2screen(x,y)
 return htw*x-htw*y,hth*x+hth*y
end
function bbtile(sx,sy)
 return flr(sx/tw),flr(sy/th)
end
function bblocal(sx,sy) 
 return sx%tw,sy%th
end
function screen2iso(sx,sy)
 local bx,by=bbtile(sx,sy)
 local lx,ly=bblocal(sx,sy)
 local ix,iy=bx+by,by-bx
 col=sget(32+lx,32+ly)--pixels
 if (col==0) ix-=1
 if (col==1) ix+=1
 if (col==2) iy-=1
 if (col==3) iy+=1
 return ix,iy
end

function _init()
 srand(0)--6934
 init_mouse()
 init_tiles()
end


// center somewhere in middle
cx,cy=-(63-htw),5*th-th


function _update()

 mouse_pan()
 
 if (btnp(⬆️)) px+=xsteps[pd+1] py+=ysteps[pd+1]
 if (btnp(⬇️)) px-=1
 if (btnp(⬅️)) pd=(pd+3)%4
 if (btnp(➡️)) pd=(pd+1)%4
 
 
 if (outline==nil) outline=false
 if (btnp(🅾️)) outline=not outline


 msx,msy=get_mouse()
 mwx,mwy=msx+cx,msy+cy
 mix,miy=screen2iso(mwx,mwy)
 
 
end

function _draw()

 cls()
  
 
 camera(cx,cy)
 
 
 local selx,sely=iso2screen(mix,miy)
 
 
 tlx,tly=screen2iso(cx,cy)
 countx=128/tw+1 //+1 to avoid calc'ing exact row counts
 county=(128/th+1)*2 //*2 since we zig zag down the column
 local rx,ry=tlx-1,tly //start one tile to the tl
 for y=0,county+1 do //appears like we need even an extra y
	 for x=0,countx do
	  
	  local tx,ty=rx+x,ry-x
	  local sx,sy=iso2screen(tx,ty)
	  
	  local ts=tget(tx,ty)
	  
	  if #ts==0 then
 	  --water
 	  spr(blocks[1],sx,sy,4,2)
 	 else
		  lts=tget(tx,ty+1)
		  rts=tget(tx+1,ty)
		  count=max(#ts-#lts,#ts-#rts)+1
		  for ti=#ts,1,-1 do
			  t=ts[ti]
			  h=#ts-ti+1
		   spr(blocks[t],sx,sy-h*8,4,4)
	   end
   end

   --selection
   if tx==mix and ty==miy then 
    palt(1,true)
    palt(2,true)
    palt(3,true)
    spr(68,selx,sely-#ts*8,4,2)
    palt(1,false)
    palt(2,false)
    palt(3,false)
   end
  
  end
  --zig zag down left column
  --which dir we start going
  --depends on if our tl tile
  --is halfway on or off screen
  --but instead of dealing with that
  --lets just iterate 1 extra row/col
  if y%2==1 then ry+=1
  else rx+=1 end
 end
 
 
 --selection icon (bg)
	local ts=tget(mix,miy)
 spr(100,selx,sely-#ts*8,4,2)
--  pal(7,14)
-- 	spr(100,selx,sely-t*8,4,2)
--  pal()
 
 
 
 
 camera()
 color(7)
 
 print2("cpu:"..stat(1))
 
 spr(16,msx,msy)
 print2(msx..","..msy)
 
 local r=tiles[mix]
 if (r==nil) r={}
 local t=r[miy]
 if (t==nil) t=0 
 print2(mix..","..miy.." h:"..#ts)
 
 print2("c:"..cx..","..cy)

end


function print2(str,col)
 local cursor_x=peek(0x5f26)
 local cursor_y=peek(0x5f27)
 if (col==nil) col=7
 print(str,cursor_x+1,cursor_y+1,0)
 print(str,cursor_x,cursor_y+1,0)
 print(str,cursor_x,cursor_y,col)
 poke(0x5f27,cursor_y+6)
end
function rect2(x,y,w,h,c)
 rect(x,y,x+w-1,y+h-1,c)
end
function rectfill2(x,y,w,h,c)
 rectfill(x,y,x+w-1,y+h-1,c)
end
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
 cache_mouse_state()
end
-->8
--util


function rndbw(l,h)
 return flr(rnd(h+1-l))+l
end

function near(num)
 if num>0 then return flr(num+0.5) 
 else return ceil(num-0.5) 
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000003bb300000000000000000000000000003bb300000000000000000000000000003bb3000000000000000000000000000000
00700700000000000000000000003bbbbbb30000000000000000000000003bbbbbb30000000000000000000000003bbbbbb30000000000000000000000000000
000770000000000000000000003bbbbbbbbbb3000000000000000000003bbbbbbbbbb3000000000000000000003bbbbbbbbbb300000000000000000000000000
0007700000000000000000003bbbbbbbbbbbbbb300000000000000003bbbbbbbbb3bbbb300000000000000003bbbbbbbbbbbbbb3000000000000000000000000
00700700000000000000003bbbbbbbbbbbbbbbbbb30000000000003bbbbbbbbbb13bbbbbb30000000000003bbbbbbbbbbbbbbbbbb30000000000000000000000
000000000000000000003bbbbbbbbbbbbbbbbbbbbbb3000000003bbbbbbbb3bbbbbbbbbbbbb3000000003bbbbbbbbbbbbbbbbbbbbbb300000000000000000000
0000000000000000003bbbbbbbbbbbbbbbbbbbbbbbbbb300003bbbbbb3bb13bbbbbbbbb3bbbbb300003bbbbbbbbbbbbbbbbbbbbbbbbbb3000000000000000000
777700000000000013bbbbbbbbbbbbbbbbbbbbbbbbbbbbb313bbbbbb13bbbbbbbb3bbb13bbbbbb1313bbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000
70000000000000001313bbbbbbbbbbbbbbbbbbbbbbbbb3b31313bbbbbbbbbbbbb13bbbbbbbbb13131313bbbbbbbbbbbbbbbbbbbbbbbbb3b30000000000000000
7000000000000000111313bbbbbbbbbbbbbbbbbbbbb3b333111313bbbbbbbbbbbbbbbbbbbb131333111313bbbbbbbbbbbbbbbbbbbbb3b3330000000000000000
700000000000000011111313bbbbbbbbbbbbbbbbb3b3333311111313bbbbbbb3bbbbbbbb1313333311111313bbbbbbbbbbbbbbbbb3b333330000000000000000
00000000000000001111111313bbbbbbbbbbbbb3b33331111111111313bbbb13bbbbbb13133331111111111313bbbbbbbbbbbbb3b33331110000000000000000
0000000000000000111111111313bbbbbbbbb3b333331444111111111313bbbbbbbb131333331444111111111313bbbbbbbbb3b3333314440000000000000000
000000000000000055551111111313bbbbb3b3333331499955551111111313bbbb1313333331499955551111111313bbbbb3b333333149990000000000000000
00000000000000004444511111111313b3b3333333149999444451111111131313133333331499994444511111111313b3b33333331499990000000000000000
00000000000000001444451111111113b333111111499994455445111111111313331111114995591444451111111113b3331111114999940000000000000000
00000000000000000014445555511111333144444499940041144455555111113331444444999449441444555551111133314444449994990000000000000000
00000000000000000000144444451111331499999994000044444444444511113314999999999999444414444445111133149999999499990000000000000000
00000000000000000000001444445111114999999400000044444445544451111149995599999999444444144444511111499999949999990000000000000000
00000000000000000000000014444555449999940000000044444441144445554499994499999999444444441444455544999994999999990000000000000000
00000000000000000000000000144444999994000000000044444444444444444999999999999999444444444414444499999499999999990000000000000000
00000000000000000000000000001444999400000000000044444444444444499999999999999999444444444444144499949999999999990000000000000000
00000000000000000000000000000014940000000000000044444444444444444999999999999999444444444444441494999999999999990000000000000000
00000000000000000000000000000000000000000000000044444444444444499999999999999999444444444444444499999999999999990000000000000000
00000000000000000000000000000000000000000000000000444444444444444999999999999900004444444444444499999999999999000000000000000000
00000000000000000000000000000000000000000000000000004444444444499999999999990000000044444444444499999999999900000000000000000000
00000000000000000000000000000000000000000000000000000044444444444999999999000000000000444444444499999999990000000000000000000000
00000000000000000000000000000000000000000000000000000000444444499999999900000000000000004444444499999999000000000000000000000000
00000000000000000000000000000000000000000000000000000000004444444999990000000000000000000044444499999900000000000000000000000000
00000000000000000000000000000000000000000000000000000000000044499999000000000000000000000000444499990000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000444900000000000000000000000000004499000000000000000000000000000000
00000000000000000000000000000000000000000000000022222222222222220000000000000000000000000000000000000000000000000000000000000000
00000000000000444400000000000000000000000000007777222222222222220000000000000044440000000000000000000000000000333300000000000000
00000000000044444444000000000000000000000000777777772222222222220000000000004444444400000000000000000000000033333333000000000000
00000000004444444444440000000000000000000077777777777722222222220000000000444444444444000000000000000000003333333333330000000000
00000000444444444444444400000000000000007777777777777777222222220000000044444444444444440000000000000000333333333333333300000000
00000044444444444444444444000000000000777777777777777777772222220000004444444444444444444400000000000033333333333333333333000000
00004444444444444444444444440000000077777777777777777777777722220000444444444444444444444444000000003333333333333333333333330000
00444444444444444444444444444400007777777777777777777777777777220044444444444444444444444444440000333333333333333333333333333300
4444444444444444444444444444444477777777777777777777777777777777444444444444444444444444444444441333333333333333333333333333333b
55444444444444444444444444444499337777777777777777777777777777115544444444444444444444444444449913133333333333333333333333333b3b
555544444444444444444444444499993333777777777777777777777777111155554444444444444444444444449999111313333333333333333333333b3bbb
5555554444444444444444444499999933333377777777777777777777111111555555444444444444444444449999991111131333333333333333333b3bbbbb
55555555444444444444444499999999333333337777777777777777111111115555555544444444444444449999999911111113133333333333333b3bbbb333
555555555544444444444499999999993333333333777777777777111111111155555555554444444444449999999999111111111313333333333b3bbbbb3444
5555555555554444444499999999999933333333333377777777111111111111555555555555444444449999999999995555111111131333333b3bbbbbb34999
55555555555555444499999999999999333333333333337777111111111111115555555555555544449999999999999944445111111113133b3bbbbbbb349999
55555555555555559999999999999999000000000000000770000000000000005555555555555555999999999999999914444511111111133bbb333333499994
5555555555555555999999999999999900000000000007000070000000000000005555555555555599999999999999000014445555511111bbb3444444999400
5555555555555555999999999999999900000000000700000000700000000000000055555555555599999999999900000000144444451111bb34999999940000
55555555555555559999999999999999000000000700000000000070000000000000005555555555999999999900000000000014444451113349999994000000
55555555555555559999999999999999000000070000000000000000700000000000000055555555999999990000000000000000144445554499999400000000
55555555555555559999999999999999000007000000000000000000007000000000000000555555999999000000000000000000001444449999940000000000
55555555555555559999999999999999000700000000000000000000000070000000000000005555999900000000000000000000000014449994000000000000
55555555555555559999999999999999070000000000000000000000000000700000000000000055990000000000000000000000000000149400000000000000
55555555555555559999999999999999070000000000000000000000000000701100000000000001000000000000001100000000000000009999999999999977
00555555555555559999999999999900000700000000000000000000000070000011000000000001000000000000110000000000000000009999999999997700
00005555555555559999999999990000000007000000000000000000007000000000110000000001000000000011000000000000000000009999999999770000
00000055555555559999999999000000000000070000000000000000700000000000001100000001000000001100000000000000000000009999999977000000
00000000555555559999999900000000000000000700000000000070000000000000000011000001000000110000000000000000000000009999997700000000
00000000005555559999990000000000000000000007000000007000000000000000000000110001000011000000000000000000000000009999770000000000
00000000000055559999000000000000000000000000070000700000000000000000000000001101001100000000000000000000000000009977000000000000
00000000000000559900000000000000000000000000000770000000000000000000000000000011110000000000000000000000000000007700000000000000
00000000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000011cccc1100000000000000000000000000b3b30000000000000000000000000000599400000000000000000000000000004ff900000000000000
000000000011cccccccc110000000000000000000000b3bbbbb3000000000000000000000000599999940000000000000000000000004ffffff9000000000000
0000000011cccccccccccc11000000000000000000b3bbbbbbbbb300000000000000000000599999999994000000000000000000004ffffffffff90000000000
00000011cccccccccccccccc1100000000000000b3bbbbbbbbbbbbb30000000000000000599999999999999400000000000000004ffffffffffffff900000000
000011cccccccc11cccccccccc110000000000b3bbbbbbbbbbbbbbbbb3000000000000599999999999999999940000000000004ffffffffffffffffff9000000
0011cccccccccccc11cccccccccc11000000b3bbbbbbbbbbbbbbbbbbbbb300000000599999999999999999999994000000004ffffffffffffffffffffff90000
11ccccccccccccccccc1cccccccccc1100b3bbbbbbbbbbbbbbbbbbbbbbbbb30000599999999999999999999999999400004ffffffffffffffffffffffffff900
1cccccccc11ccccccccccccccccccccc03bbbbbbbbbbbbbbbbbbbbbbbbbbbb30099999999999999999999999999999400fffffffffffffffffffffffffffff90
001cccccccc11cccccccccc1ccccc10033b3bbbbbbbbbbbbbbbbbbbbbbbbb33355599999999999999999999999994994444fffffffffffffffffffffffff9ff9
00001cccccccc11cccccccccccc100001333b3bbbbbbbbbbbbbbbbbbbbb3b33b1545599999999999999999999949944954f44fffffffffffffffffffff9ff99f
0000001ccccccccc1cccccccc1000000333333b3bbbbbbbbbbbbbbbbb3b33333555545599999999999999999499444444444f44fffffffffffffffff9ff99999
000000001cccccccccccccc10000000013333333b3bbbbbbbbbbbbb3b333333b15555545599999999999994994444449544444f44fffffffffffff9ff999999f
00000000001cccccccccc100000000003333333333b3bbbbbbbbb3b3333344495555555545599999999949944444444444444444f44fffffffff9ff999999999
0000000000001cccccc1000000000000155113333333b3bbbbb3b33333399999155555555545599999499444444444495444444444f44fffff9ff9999999999f
000000000000001cc10000000000000044444133333333b3b3b333333399999955555555555545594994444444444444444444444444f44f9ff9999999999999
00000000000000000000000000000000144444533333333333333333399999951555555555555545944444444444444554444444444444f4f999999999999994
000000000000000000000000000000000014444451133333b3333444999995000015555555555555444444444444450000544444444444449999999999999400
0000000000000000000000000000000000001444444133333333999999950000000015555555555494444444444500000000544444444449f999999999940000
000000000000000000000000000000000000001444441333b3399999950000000000001555555555444444444500000000000054444444449999999994000000
0000000000000000000000000000000000000000144445333399999500000000000000001555555494444445000000000000000054444449f999999400000000
00000000000000000000000000000000000000000014445549999500000000000000000000155555444445000000000000000000005444449999940000000000
0000000000000000000000000000000000000000000014449995000000000000000000000000155494450000000000000000000000005449f994000000000000
00000000000000000000000000000000000000000000001545000000000000000000000000000015450000000000000000000000000000544400000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000003bb3000000000000000000000000000033330000000000000000000000000000b3b30000000000000000000000000000000000000000000000
0000000000003bbbbbb300000000000000000000000033333333000000000000000000000000b3bbbbb300000000000000000000000000000000000000000000
00000000003bbbbbbbbbb30000000000000000000033333333333300000000000000000000b3bbbbbbbbb3000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbb3000000000000000033333333333333330000000000000000b3bbbbbbbbbbbbb30000000000000000000000000000000000000000
0000003bbbbbbbbbbbbbbbbbb300000000000033333333333333333333000000000000b3bbbbbbbbbbbbbbbbb300000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbb30000000033333333333333333333333300000000b3bbbbbbbbbbbbbbbbbbbbb3000000000000000000000000000000000000
003bbbbbbbbbbbbbbbbbbbbbbbbbb3000033333333333333333333333333330000b3bbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000
13bbbbbbbbbbbbbbbbbbbbbbbbbbbbb31333333333333333333333333333333b03bbbbbbbbbbbbbbbbbbbbbbbbbbbb3b00000000000000000000000000000000
1313bbbbbbbbbbbbbbbbbbbbbbbbb3b313133333333333333333333333333b3b33b3bbbbbbbbbbbbbbbbbbbbbbbbb33300000000000000000000000000000000
111313bbbbbbbbbbbbbbbbbbbbb3b333111313333333333333333333333b3bbb1333b3bbbbbbbbbbbbbbbbbbbbb3b33b00000000000000000000000000000000
11111313bbbbbbbbbbbbbbbbb3b333331111131333333333333333333b3bbbbb333333b3bbbbbbbbbbbbbbbbb3b3333300000000000000000000000000000000
1111111313bbbbbbbbbbbbb3b333311111111113133333333333333b3bbbb33311113333b3bbbbbbbbbbbbb3b333333b00000000000000000000000000000000
111111111313bbbbbbbbb3b333331444111111111313333333333b3bbbbb34445555133333b3bbbbbbbbb3b33333444400000000000000000000000000000000
55551111111313bbbbb3b333333149995555111111131333333b3bbbbbb34999444451333333b3bbbbb3b3333334999900000000000000000000000000000000
4444511111111313b3b333333314999944445111111113133b3bbbbbbb34999944444513333333b3b3b333333349999900000000000000000000000000000000
1444451111111113b33311111149999414444511111111133bbb3333334999941444445111133333333333333499999400000000000000000000000000000000
001444555551111133314444449994000014445555511111bbb34444449994000014444555513333b33334444999940000000000000000000000000000000000
000014444445111133149999999400000000144444451111bb349999999400000000144444451333333349999994000000000000000000000000000000000000
00000014444451111149999994000000000000144444511133499999940000000000001444445133b33499999400000000000000000000000000000000000000
00000000144445554499999400000000000000001444455544999994000000000000000014444511334999940000000000000000000000000000000000000000
00000000001444449999940000000000000000000014444499999400000000000000000000144455449994000000000000000000000000000000000000000000
00000000000014449994000000000000000000000000144499940000000000000000000000001444999400000000000000000000000000000000000000000000
00000000000000149400000000000000000000000000001494000000000000000000000000000015440000000000000000000000000000000000000000000000
