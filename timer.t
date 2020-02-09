local gd32=require"gd32"
local timer={}
local SystemCoreClock=terralib.cast(uint32,108000000)
terra timer.delay(time:uint32)
  var tmp=gd32.n200.get_timer_value()
  var start_mtime:uint64
  repeat
    start_mtime=gd32.n200.get_timer_value()
  until start_mtime~=tmp
  repeat
    var delta_mtime=gd32.n200.get_timer_value()-start_mtime
  until delta_mtime>=(SystemCoreClock/4000.0*time)
end
return timer
