local gd32=require"gd32"
local gpio_h=require"include"("gd32vf103_gpio.h",gd32.incf)
local rcu_h=require"include"("gd32vf103_rcu.h",gd32.incf)
gd32.gpio.GPIOA=gpio_h.value("GPIOA","uint32_t")
gd32.gpio.GPIOC=gpio_h.value("GPIOC","uint32_t")
gd32.gpio.GPIO_OSPEED_50MHZ=gpio_h.value("GPIO_OSPEED_50MHZ","uint8_t")
gd32.gpio.GPIO_MODE_OUT_PP=gpio_h.value("GPIO_MODE_OUT_PP","uint8_t")
gd32.gpio.GPIO_MODE_AF_PP=gpio_h.value("GPIO_MODE_AF_PP","uint8_t")
local ret={}
local function create_port(name,base)
  local port={}
  ret[name]=port
  port.enable=macro(function()
    return `gd32.rcu.rcu_periph_clock_enable([gd32.rcu["RCU_GPIO"..name]])
  end)
  for i=0,31 do
    local pin={}
    ret[name.."_"..i]=pin
    local pin_id=bit.lshift(1,i)
    pin.output=macro(function()
      return `gd32.gpio.gpio_init(base,gd32.gpio.GPIO_MODE_OUT_PP,gd32.gpio.GPIO_OSPEED_50MHZ,pin_id)
    end)
    pin.alternate=macro(function()
      return `gd32.gpio.gpio_init(base,gd32.gpio.GPIO_MODE_AF_PP,gd32.gpio.GPIO_OSPEED_50MHZ,pin_id)
    end)
    pin.set=macro(function(value)
      return quote
        if value then
          gd32.gpio.gpio_bit_set(base,pin_id)
        else
          gd32.gpio.gpio_bit_reset(base,pin_id)
        end
      end
    end)
    pin.toggle=macro(function(value)
      return quote
        pin.set(gd32.gpio.gpio_output_bit_get(base,pin_id)~=1)
      end
    end)
  end
end
create_port("A",gpio_h.value("GPIOA","uint32_t"))
create_port("B",gpio_h.value("GPIOB","uint32_t"))
create_port("C",gpio_h.value("GPIOC","uint32_t"))
return ret
