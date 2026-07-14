ENTRY(_start)

MEMORY
{
  IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 4096
  DMEM (rw)  : ORIGIN = 0x00010000, LENGTH = 4096
}

SECTIONS
{
  .text : { *(.text*) } > IMEM

  .data : { *(.data*) } > DMEM
  .bss  : { *(.bss*) *(COMMON) } > DMEM

  _stack_top = ORIGIN(DMEM) + LENGTH(DMEM);
}
