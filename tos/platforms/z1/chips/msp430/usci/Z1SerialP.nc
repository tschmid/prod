module Z1SerialP {
  provides interface StdControl;
  provides interface Msp430UartConfigure;
  uses interface Resource;
}
implementation {
  
  const msp430_uart_union_config_t msp430_uart_z1_config = { {
    ubr    : UBR_8MIHZ_115200,
    umctl  : UMCTL_8MIHZ_115200,
    ucssel : 2,
  } };

//, ssel: 0x02, pena: 0, pev: 0, spb: 0, clen: 1, listen: 0, mm: 0, ckpl: 0, urxse: 0, urxeie: 1, urxwie: 0, utxe : 1, urxe : 1

  command error_t StdControl.start(){
    return call Resource.immediateRequest();
  }

  command error_t StdControl.stop(){
    call Resource.release();
    return SUCCESS;
  }

  event void Resource.granted(){}

  async command const msp430_uart_union_config_t* Msp430UartConfigure.getConfig() {
    return &msp430_uart_z1_config;
  }
}
