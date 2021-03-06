/*
 * Copyright (c) 2005-2006 Rincon Research Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 *
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#if !defined(__MSP430_HAS_WDT__) || !defined(__MSP430_HAS_WDT_A__)
#error "Msp430WdtP: processor not supported, need WDT or WDT_A"
#endif

module WdtP {
  provides {
    interface StdControl;
    interface Wdt;
  }
  uses interface Timer<TMilli>;
}
implementation {

  bool on;

  /***************** StdControl Commands ****************/
  command error_t StdControl.start() {
    on = TRUE;
    call Wdt.resume();
    return SUCCESS;
  }

  command error_t StdControl.stop() {
    on = FALSE;
    call Wdt.pause();
    return SUCCESS;
  }

  /***************** Wdt Commands ****************/
  command void Wdt.pause() {
    call Timer.stop();
    WDTCTL = WDTPW | WDTHOLD;
  }

  command void Wdt.resume() {
    if(on) {
      call Timer.startPeriodic(512);
    
      // Watchdog mode clocked from ACLK, 1000 ms reset
      WDTCTL = WDT_ARST_1000;
    }    
  }

  command void Wdt.kick() {
    if(on) {
      WDTCTL = WDTPW | ((WDTCTL & 0xFF) | WDTCNTCL);
    }
  }

  /***************** Timer Events ****************/
  event void Timer.fired() {
    call Wdt.kick();
  }
}
