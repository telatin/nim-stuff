import std/sha1

let
  list = ["andrea telatin", "1", "3", "asdo aiusdoauhefouhaei fuh ", "asuhdahefgohsrpigjapgjpsdjrgphsdrufndlskjnkaljsdhfiahsrugihspdiugjpsdtjhsdfjthishdgohasuyrfgauyisegdfitafsgefugaosrhgpisudthjpisdtbòksdmfòkvjandsfng", "asdhoagdfuagshrguha uh aisrh apiuhrg ipuahrg asihga isuhf svzkjxd vlzbfjggzsof gaysu hpaiuhr gpiahr goysh ghprigu hpiughsp iur gpsig "]

for i in list:
  echo "> ", i
  echo secureHash(i)
