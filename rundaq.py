#!/usr/bin/env python

import multiprocessing as mp
import slowcontrol     as sc

def Run():
    run = sc.ISlowControlRun()
    run.Plot()
    return

if __name__=="__main__":
    evt = mp.Process(target=Run)
    evt.start()

    print "/*******************************************/"
    print "  DAQ for HTS Critical Current Measurement\n"
    print "  press .q or exit to terminate the daq."
    print "/*******************************************/"
    sig = raw_input("daq > ")

    while True:
        if sig==".q" or sig=="exit":
            for event in mp.active_children():
                event.terminate()
            break
        else:
            sig = raw_input("daq > ")

