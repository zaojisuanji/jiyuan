造计算机

flush信号需要区分，两个IfIdFlush需要是不同的signal，然后在IfIdRegisters里面or一下

读BF00时，如果串口没准备好数据（data_ready = '0'），应该如何处理？

ram1_en = '1'是禁止吗？？

signal PCOut  std...(15 downto 0);是默认全'0'吗？

IfIdFlush该不该放在时钟上升沿？？该不该放在IfIdKeep之后？？