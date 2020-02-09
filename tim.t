local gd32=require"gd32"
local eclic_h=require"include"("gd32vf103_eclic.h",gd32.incf)
local timer_h=require"include"("gd32vf103_timer.h",gd32.incf)
local ECLIC_GROUP_LEVEL3_PRIO1=eclic_h.value("ECLIC_GROUP_LEVEL3_PRIO1","uint32_t")
local ret={}

local struct timer_parameter_struct {
  prescaler: uint16
  alignedmode: uint16
  counterdirection: uint16
  period: uint32
  clockdivision: uint16
  repetitioncounter: uint8
}
local struct timer_oc_parameter_struct {
  outputstate: uint16
  outputnstate: uint16
  ocpolarity: uint16
  ocnpolarity: uint16
  ocidlestate: uint16
  ocnidlestate: uint16
}

local timers={
  {
    TIMER_INT_CH=require"include"("gd32vf103.h",gd32.incf).value("TIMER_INT_CH0","uint32_t"),
    TIMER_CH_=require"include"("gd32vf103.h",gd32.incf).value("TIMER_CH_0","uint32_t"),
    TIMER_IRQn=gd32.timer["TIMER1_IRQn"],
    TIMER=require"include"("gd32vf103.h",gd32.incf).value("TIMER1","uint32_t"),
    rcu=gd32.rcu["RCU_TIMER1"],
  },
  {
    TIMER_INT_CH=require"include"("gd32vf103.h",gd32.incf).value("TIMER_INT_CH1","uint32_t"),
    TIMER_CH_=require"include"("gd32vf103.h",gd32.incf).value("TIMER_CH_1","uint32_t"),
    TIMER_IRQn=gd32.timer["TIMER2_IRQn"],
    TIMER=require"include"("gd32vf103.h",gd32.incf).value("TIMER2","uint32_t"),
    rcu=gd32.rcu["RCU_TIMER2"],
  },
  {
    TIMER_INT_CH=require"include"("gd32vf103.h",gd32.incf).value("TIMER_INT_CH2","uint32_t"),
    TIMER_CH_=require"include"("gd32vf103.h",gd32.incf).value("TIMER_CH_2","uint32_t"),
    TIMER_IRQn=gd32.timer["TIMER3_IRQn"],
    TIMER=require"include"("gd32vf103.h",gd32.incf).value("TIMER3","uint32_t"),
    rcu=gd32.rcu["RCU_TIMER3"],
  },
}

local timer_reg={}

function ret.add_timer(hertz,callback)
  local timer=assert(timers[#timer_reg+1],"Cannot allocate timer")
  table.insert(timer_reg,{cb=terra()
    if 1 == gd32.timer.timer_interrupt_flag_get(timer.TIMER, timer.TIMER_INT_CH) then
      gd32.timer.timer_interrupt_flag_clear(timer.TIMER, timer.TIMER_INT_CH);
      callback()
    end
  end,init=quote
    gd32.eclic.eclic_irq_enable(timer.TIMER_IRQn,1,0);
    var timer_ocinitpara:timer_oc_parameter_struct
    var timer_initpara:timer_parameter_struct
    gd32.rcu.rcu_periph_clock_enable(timer.rcu)
    gd32.timer.timer_deinit(timer.TIMER)
    gd32.timer.timer_struct_para_init([&gd32.timer.timer_parameter_struct](&timer_initpara))
    timer_initpara.prescaler         = [uint16](5399);
    timer_initpara.alignedmode       = [timer_h.value("TIMER_COUNTER_EDGE","uint32_t")]
    timer_initpara.counterdirection  = [timer_h.value("TIMER_COUNTER_UP","uint32_t")];
    timer_initpara.period            = [20000/hertz];
    timer_initpara.clockdivision     = [timer_h.value("TIMER_CKDIV_DIV1","uint32_t")];
    gd32.timer.timer_init(timer.TIMER, [&gd32.timer.timer_parameter_struct](&timer_initpara));
    gd32.timer.timer_channel_output_struct_para_init([&gd32.timer.timer_oc_parameter_struct](&timer_ocinitpara));
    timer_ocinitpara.outputstate  = [timer_h.value("TIMER_CCX_ENABLE","uint32_t")];
    timer_ocinitpara.ocpolarity   = [timer_h.value("TIMER_OC_POLARITY_HIGH","uint32_t")]
    timer_ocinitpara.ocidlestate  = [timer_h.value("TIMER_OC_IDLE_STATE_LOW","uint32_t")]
    gd32.timer.timer_channel_output_config(timer.TIMER, timer.TIMER_CH_, [&gd32.timer.timer_oc_parameter_struct](&timer_ocinitpara));

    gd32.timer.timer_channel_output_pulse_value_config(timer.TIMER, timer.TIMER_CH_, 2000);
    gd32.timer.timer_channel_output_mode_config(timer.TIMER, timer.TIMER_CH_, [timer_h.value("TIMER_OC_MODE_TIMING","uint32_t")]);
    gd32.timer.timer_channel_output_shadow_config(timer.TIMER, timer.TIMER_CH_, [timer_h.value("TIMER_OC_SHADOW_DISABLE","uint32_t")]);

    gd32.timer.timer_interrupt_enable(timer.TIMER, timer.TIMER_INT_CH);
    gd32.timer.timer_enable(timer.TIMER);
  end})
end

ret.init=macro(function()
  local ret={}
  if #timer_reg>0 then
    table.insert(ret,quote
      gd32.rcu.rcu_periph_clock_enable([gd32.rcu["RCU_AF"]])
      gd32.eclic.eclic_global_interrupt_enable();
      gd32.eclic.eclic_set_nlbits(ECLIC_GROUP_LEVEL3_PRIO1);
    end)
  end
  for i,t in ipairs(timer_reg) do
    table.insert(ret,t.init)
  end
  return ret
end)

function ret.register_functions(objects)
  for i=1,#timer_reg do
    objects["TIMER"..i.."_IRQHandler"]=timer_reg[i].cb
  end
end
return ret
