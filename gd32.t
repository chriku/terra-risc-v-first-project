package.path=package.path..";../?.lua"
require"copas"
require"blue.util"
local incf={
"-I/home/christian/.platformio/packages/framework-gd32vf103-sdk/GD32VF103_standard_peripheral",
"-I/home/christian/.platformio/packages/framework-gd32vf103-sdk/GD32VF103_standard_peripheral/Include",
"-I/home/christian/.platformio/packages/framework-gd32vf103-sdk/GD32VF103_usbfs_driver",
"-I/home/christian/.platformio/packages/framework-gd32vf103-sdk/GD32VF103_usbfs_driver/Include",
"-I/home/christian/.platformio/packages/framework-gd32vf103-sdk/RISCV/drivers",
"-I/home/christian/.platformio/packages/framework-gd32vf103-sdk/RISCV/env_Eclipse",
"-I/home/christian/.platformio/packages/framework-gd32vf103-sdk/RISCV/stubs",
"-DPLATFORMIO=40100","-DUSE_STDPERIPH_DRIVER","-DHXTAL_VALUE=8000000U",
"-includestdint.h"}
local gd32={
  eclic=terralib.includec("gd32vf103_eclic.h",incf),
  gpio=terralib.includec("gd32vf103_gpio.h",incf),
  rcu=terralib.includec("gd32vf103_rcu.h",incf),
  spi=terralib.includec("gd32vf103_spi.h",incf),
  timer=terralib.includec("gd32vf103_timer.h",incf),
  pmu=terralib.includec("gd32vf103_pmu.h",incf),
  n200=terralib.includec("n200_func.h",incf),
  incf=incf
}
return gd32
