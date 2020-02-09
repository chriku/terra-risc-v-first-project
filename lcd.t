local gd32=require"gd32"
local gpio=require"gpio"
local timer=require"timer"
local cs=gpio.B_2
local dc=gpio.B_0
local rst=gpio.B_1
local blk=gpio.B_0
local spi_h=require"include"("gd32vf103_spi.h",gd32.incf)
local SPI0=spi_h.value("SPI0","uint32_t")
local SPI_FLAG_TBE=spi_h.value("SPI_FLAG_TBE","uint32_t")
local SPI_FLAG_RBNE=spi_h.value("SPI_FLAG_RBNE","uint32_t")
local lcd={}
local w=160
local h=80
local terra write_bus(data:uint8)
  cs.set(false)
  while 0 == gd32.spi.spi_i2s_flag_get(SPI0, SPI_FLAG_TBE) do end
  gd32.spi.spi_i2s_data_transmit(SPI0, data)
  while 0 == gd32.spi.spi_i2s_flag_get(SPI0, SPI_FLAG_RBNE) do end
  gd32.spi.spi_i2s_data_receive(SPI0);
  cs.set(true)
end
local terra wr_data8(data:uint8)
  dc.set(true)
  write_bus(data)
end
local terra wr_data(data:uint16)
  dc.set(true)
  write_bus(data>>8)
  write_bus(data)
end
local terra wr_reg(data:uint8)
  dc.set(false)
  write_bus(data)
end
local terra wr_addr_set(x1:uint16,y1:uint16,x2:uint16,y2:uint16)
  wr_reg(0x2a)
  wr_data(x1+1)
  wr_data(x2+1)
  wr_reg(0x2b)
  wr_data(y1+26)
  wr_data(y2+26)
  wr_reg(0x2c)
end
struct spi_parameter_struct {
  device_mode: uint32
  trans_mode: uint32
  frame_size: uint32
  nss: uint32
  endian: uint32
  clock_polarity_phase: uint32
  prescale: uint32
}
local terra spi_init()
  var spi_init_struct:spi_parameter_struct
  cs.set(true)
  gd32.spi.spi_struct_para_init([&gd32.spi.spi_parameter_struct](&spi_init_struct));
  spi_init_struct.trans_mode           = [spi_h.value("SPI_TRANSMODE_FULLDUPLEX","uint32_t")]
  spi_init_struct.device_mode          = [spi_h.value("SPI_MASTER","uint32_t")]
  spi_init_struct.frame_size           = [spi_h.value("SPI_FRAMESIZE_8BIT","uint32_t")]
  spi_init_struct.clock_polarity_phase = [spi_h.value("SPI_CK_PL_HIGH_PH_2EDGE","uint32_t")]
  spi_init_struct.nss                  = [spi_h.value("SPI_NSS_SOFT","uint32_t")]
  spi_init_struct.prescale             = [spi_h.value("SPI_PSC_8","uint32_t")]
  spi_init_struct.endian               = [spi_h.value("SPI_ENDIAN_MSB","uint32_t")]
  gd32.spi.spi_init(SPI0, [&gd32.spi.spi_parameter_struct](&spi_init_struct));
  gd32.spi.spi_crc_polynomial_set(SPI0,7);
  gd32.spi.spi_enable(SPI0);
end
terra lcd.init()
  gd32.rcu.rcu_periph_clock_enable([gd32.rcu["RCU_AF"]])
  gd32.rcu.rcu_periph_clock_enable([gd32.rcu["RCU_SPI0"]])
  gpio.A.enable()
  gpio.B.enable()
  gpio.A_5.alternate()
  gpio.A_6.alternate()
  gpio.A_7.alternate()
  gpio.B_2.alternate()

  spi_init()

  gpio.B_0.output()
  gpio.B_1.output()
  gpio.B_0.set(false)
  gpio.B_1.set(false)

  rst.set(false)
  timer.delay(200)
  rst.set(true)
  timer.delay(20)

  wr_reg(0x11)
  timer.delay(100)
  wr_reg(0x21)
  wr_reg(0xb1)
  wr_data8(0x05)
  wr_data8(0x3a)
  wr_data8(0x3a)
  wr_reg(0xb2)
  wr_data8(0x05)
  wr_data8(0x3a)
  wr_data8(0x3a)
  wr_reg(0xb3)
  wr_data8(0x05)
  wr_data8(0x3a)
  wr_data8(0x3a)
  wr_data8(0x05)
  wr_data8(0x3a)
  wr_data8(0x3a)
  wr_reg(0xb4)
  wr_data8(0x04)
  wr_reg(0xc0)
  wr_data8(0x62)
  wr_data8(0x02)
  wr_data8(0x04)

  wr_reg(0xc1)
  wr_data8(0xc0)

  wr_reg(0xc2)
  wr_data8(0x0d)
  wr_data8(0x00)

  wr_reg(0xc3)
  wr_data8(0x8d)
  wr_data8(0x6a)

  wr_reg(0xc4)
  wr_data8(0x8d)
  wr_data8(0xee)

  wr_reg(0xc5)
  wr_data8(0x0e)

  wr_reg(0xe0)
  wr_data8(0x10)
  wr_data8(0x0e)
  wr_data8(0x02)
  wr_data8(0x03)
  wr_data8(0x0e)
  wr_data8(0x07)
  wr_data8(0x02)
  wr_data8(0x07)
  wr_data8(0x0a)
  wr_data8(0x12)
  wr_data8(0x27)
  wr_data8(0x37)
  wr_data8(0x00)
  wr_data8(0x0d)
  wr_data8(0x0e)
  wr_data8(0x10)

  wr_reg(0xe1)
  wr_data8(0x10)
  wr_data8(0x0e)
  wr_data8(0x03)
  wr_data8(0x03)
  wr_data8(0x0f)
  wr_data8(0x06)
  wr_data8(0x02)
  wr_data8(0x08)
  wr_data8(0x0a)
  wr_data8(0x13)
  wr_data8(0x26)
  wr_data8(0x36)
  wr_data8(0x00)
  wr_data8(0x0d)
  wr_data8(0x0e)
  wr_data8(0x10)

  wr_reg(0x3a)
  wr_data8(0x05)

  wr_reg(0x36)
  wr_data8(0x78)

  wr_reg(0x29)
end
terra lcd.clear()
  wr_addr_set(0,0,w-1,h-1)
  for i=1,w*h do
    wr_data(0x0000)
  end
end
terra lcd.convert_color(r:uint8,g:uint8,b:uint8):uint16
  var rv:uint16=r>>3
  var gv:uint16=g>>2
  var bv:uint16=b>>3
  return (bv or (gv<<5) or (rv<<11))
end
terra lcd.paint_char(x:uint16,y:uint16,char:&uint16)
  wr_addr_set(x,y,x+14,y+15)
  for y=0,15 do
    for x=0,15 do
      var val:uint8=0
      if (char[y] and (1<<x))~=0 then
        val=255
      end
      wr_data(lcd.convert_color(val,val,val))
    end
  end
end
terra lcd.paint(state:uint32)
  wr_addr_set(0,0,w-2,h-1)
  for y=1,h do
    for x=1,w do
      var r2=((x-80)*(x-80))+((y-40)*(y-40))
      if r2<((state*state)/(8*8)) then
        wr_data(lcd.convert_color(255,0,0))
      elseif r2<((255*255)/(8*8)) then
        wr_data(0xffff)
      else
        wr_data(0x0000)
      end
    end
  end
end
return lcd
