#!/usr/bin/env python

import IPowerSupply

if __name__=="__main__":
    ps = IPowerSupply.IPowerSupply()
    ps.SetGpib("GPIB1::2::INSTR")

    protect = 0.3
    #ps.SetProtection(protect)

    I = 0.1
    ps.SetVoltage(0.1)
    ps.SetCurrent(I)
    ps.TurnOn()

    while True:
        ps.SetCurrent(I)

        data = ps.Read()
        data2 = ps.ReadSetup()
        print data[1], data2[1]
        if (data[1]>protect):
            ps.TurnOff()
            break
        I += 0.5
