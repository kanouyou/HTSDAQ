
from ROOT        import TFile, TTree
from IMultiMeter import IMultiMeter, INanoMeter
from datetime    import datetime
import matplotlib.gridspec as gridspec
import matplotlib.dates    as md
import matplotlib.pyplot   as plt
import numpy               as np
import multiprocessing     as mp

MULTIMETER = "GPIB1::1::INSTR"
NANOMETER  = "GPIB1::15::INSTR"
SLEEPTIME  = 0.01

class ISlowDatasave:

    def __init__(self, filename, opt="ios"):
        if opt=="ios":
            self.fFile = open(filename, "w+")
        elif opt=="root":
            self.fFile = TFile(filename, "RECREATE")

    def Fill(self, data):
        self.fFile.write(" %.3e   %.3e   %.3e    %.3e" %(data[0], data[1], data[2], data[3]))

    def Close(self):
        self.fFile.close()


class ISlowControlRun:

    def __init__(self):
        # 1: nanometer,  2: multimeter
        # multimeter is to measure the voltage of resistor and two edge of HTS
        self.fDet  = [IMultiMeter(), INanoMeter()]
        gpib = [NANOMETER, MULTIMETER]
        scn  = [1,2]

        for i in range(len(self.fDet)):
            self.fDet[i].SetGpib(gpib[i])
            if i==0:
                self.fDet[i].SetScanner(scn)
                self.fDet[i].SetSleepTime(SLEEPTIME)

        self.fData  = {"time":[], "nano1":np.array([]), "nano2":np.array([]), "multi":np.array([])}
        self.fColor = ["dodgerblue", "orangered", "greenyellow"]

    def Plot(self):
        shunt = 0.25e-3
        cnt = 0
        while True:
            Vhts = self.fDet[0].Read()[0]
            Vres = self.fDet[1].Read()
            Vedg = self.fDet[0].Read()[1]
            self.fData[ "time"].append(datetime.now())
            self.fData["nano1"] = np.append(self.fData["nano1"], Vhts)
            self.fData["nano2"] = np.append(self.fData["nano2"], Vedg)
            self.fData["multi"] = np.append(self.fData["multi"], Vres)

            plt.clf()
            plt.figure(figsize=(9, 7))
            gs  = gridspec.GridSpec(3,3)
            ax0 = plt.subplot(gs[0,:])
            ax1 = plt.subplot(gs[1,:-1])
            ax2 = plt.subplot(gs[-1,:-1])

            ax0.plot(self.fData["multi"]/shunt, self.fData["nano1"], c=self.fColor[0], marker="o", \
                     ms=7, ls="none", mec=self.fColor[0], label="Multi / Nano1")
            ax0.plot(self.fData["multi"]/shunt, self.fData["nano2"], c=self.fColor[1], marker="v", \
                     ms=7, ls="none", mec=self.fColor[1], label="Multi / Nano2")

            ax0.grid()
            ax0.legend(numpoints=1, loc="upper right")

            ax1.plot(self.fData["time"], self.fData["nano1"], c=self.fColor[0], marker="o", \
                     linewidth=1.9, ms=7, ls="none", mec=self.fColor[0], label="Nano1")
            ax1.plot(self.fData["time"], self.fData["multi"], c=self.fColor[1], marker="v", \
                     linewidth=1.9, ms=7, ls="none", mec=self.fColor[1], label="Multi1")
            ax1.plot(self.fData["time"], self.fData["nano2"], c=self.fColor[2], marker="s", \
                     linewidth=1.9, ms=7, ls="none", mec=self.fColor[2], label="Nano2")

            days = md.AutoDateLocator()
            dfmt = md.DateFormatter("%H:%M")
            ax1.xaxis.set_major_locator(days)
            ax1.xaxis.set_major_formatter(dfmt)
            #plt.gcf().autofmt_xdate()

            ax1.grid()
            ax1.set_xlabel("Time")
            ax1.set_ylabel("Voltage [V]")
            ax1.legend(numpoints=1, loc="upper right")

            ax2.plot(self.fData["time"], self.fData["multi"]/shunt, c="darkorange", marker="^", \
                     ls="none", mec="darkorange")
            ax2.xaxis.set_major_locator(days)
            ax2.xaxis.set_major_formatter(dfmt)
            ax2.grid()
            ax2.set_xlabel("Time")
            ax2.set_ylabel("Current [A]")

            plt.subplots_adjust(hspace=0.3)
            if cnt%10==0:
                plt.savefig("out.pdf")
                print "\ndaq > number of points: %i" %cnt
            plt.pause(0.01)
            plt.close()
            cnt+=1

    def Run(self):
        evt = mp.Process(target=self.Plot)
        evt.start()

        print "/*******************************************/"
        print "  DAQ for HTS Critical Current Measurement\n"
        print "  press .q or exit to terminate the daq."
        print "/*******************************************/"
        sig = raw_input(">> ")
        while True:
            if sig==".q" or sig=="exit":
                for event in mp.active_children():
                    event.terminate()
                break
            else:
                sig = raw_input(">> ")
