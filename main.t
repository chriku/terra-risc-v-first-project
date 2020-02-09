local C=terralib.includecstring([[
#include <stdlib.h>
]])
local gd32=require"gd32"
local gpio=require"gpio"
local timer=require"timer"
local tim=require"tim"
local lcd=require"lcd"
local state=terralib.global(uint8)
local font=require"font"
local terra draw_line(y:uint8,data:&int8)
  var pos:uint8=0
  while data[pos]~=0 do
    var char=font(data[pos])
    if char~=nil then
      lcd.paint_char(pos*16,y,char)
    end
    pos=pos+1
  end
end
tim.add_timer(1,terra()
  --state=(state+7)%256
  --gpio.A_2.toggle()
  lcd.clear()
  draw_line(0,"Hello")
  draw_line(16,"World")
  draw_line(32,"from TERRA")
end)
local terra main()
  gpio.A.enable()
  gpio.B.enable()
  gpio.C.enable()
  gpio.C_13.output()
  gpio.A_1.output()
  gpio.A_2.output()
  gpio.C_13.set(true)
  gpio.A_1.set(true)
  gpio.A_2.set(true)
  lcd.init()
  lcd.clear()
  tim.init()
  while true do
    gd32.pmu.pmu_to_sleepmode(0)
    --gpio.A_1.toggle()
  end
end
local target=assert(terralib.newtarget {
  Triple="riscv32-generic-elf",
  CPU="generic-rv32",
  Features="m,a"
})
local objects={main=main}
tim.register_functions(objects)
terralib.saveobj("main.o","object",objects,nil,target)
local file=io.open("src/main.c","w")
file:write("int build_time() {return "..os.time()..";}")
file:close()
os.execute("pio run  -e sipeed-longan-nano --target upload -v")
