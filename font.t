local ffi=require"ffi"
local lcd=require"lcd"
local freetype=terralib.includecstring([[
#include <ft2build.h>
#include FT_FREETYPE_H
]],{"-I/usr/include/freetype2"})
terralib.linklibrary("/usr/lib/x86_64-linux-gnu/libfreetype.so.6.16.1")
local lib=terralib.new(freetype.FT_Library[1])
local face=terralib.new(freetype.FT_Face[1])
assert(freetype.FT_Init_FreeType(lib)==0,"FreeType Init Error")
lib=lib[0]
assert(freetype.FT_New_Face(lib,"/usr/share/fonts/truetype/ubuntu/UbuntuMono-R.ttf",0,face),"Error loading ubuntu mono")
face=face[0]
assert(freetype.FT_Set_Pixel_Sizes(face,16,16)==0,"Inval Font Size")
local function convert_glyph(idx)
  local map=terralib.new(uint16[16])
  local gidx=freetype.FT_Get_Char_Index(face,idx)
  assert(freetype.FT_Load_Glyph(face,gidx,0)==0)
  assert(freetype.FT_Render_Glyph(face.glyph,freetype.FT_RENDER_MODE_MONO)==0)
  local glyph=face.glyph
  for i=0,15 do map[i]=0 end
  for y=0,glyph.bitmap.rows-1 do
    local row=glyph.bitmap.buffer+(y*glyph.bitmap.pitch)
    local yoff=14-glyph.bitmap_top
    local xoff=glyph.bitmap_left
    for x=0,glyph.bitmap.width-1 do
      local val=bit.rshift(row[math.floor(x/8)],7-(x%8))%2~=0
      local xv=x+xoff
      local yv=y+yoff
      if xv>15 then xv=15 end
      if yv>15 then yv=15 end
      if val then
        map[yv]=bit.bor(map[yv],bit.lshift(1,xv))
      end
    end
  end
  return terralib.constant(uint16[16],map)
end
local choose=macro(function(glph,ret)
  local gl={}
  local function add_glyph(idx)
    local map=convert_glyph(idx)
    table.insert(gl,quote
      if glph==idx then
        ret[0]=map
      end
    end)
  end
  for i=20,127 do
    add_glyph(i)
  end
  local ret=`[gl]
  return ret
end)
--return 
local terra ret(c:uint8):&uint16
  var ret:&uint16=nil
  choose(c,&ret)
  return ret
end
return ret
