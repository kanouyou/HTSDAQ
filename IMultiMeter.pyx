import visa
import time

class IException(Exception):
    pass


class INanoMeter:
    
    def __init__(self):
        self.fRM = visa.ResourceManager()

    def CheckGpib(self):
        gpib = self.fRM.list_resources()
        print " ------------------------------------ "
        print " Connected port: "
        for i in range(len(gpib)):
            print " %i. %s" %(i, str(gpib[i]))
            print " ------------------------------------ "
            print "\n"
        return gpib

    def SetGpib(self, gpib):
        self.fInstr = self.fRM.open_resource(gpib)

    def CheckInstrument(self):
        w = self.fInstr.write("*IDN?")
        r = self.fInstr.read()
        print r

    def Read(self):
        w = self.fInstr.write(":measure:voltage:dc?")
        r = self.fInstr.read()
        return float(r)


class IMultiMeter(INanoMeter):
    
    def __init__(self):
        INanoMeter.__init__(self)
        self.fSleep = 0.5

    def SetScanner(self, scan):
        if len(scan) > 10:
            raise IException()
        self.fScan = scan
        w = self.fInstr.write(":route:open:all")

    def SetSleepTime(self, time):
        self.fSleep = time

    def Read(self):
        data = []
        for i in range(len(self.fScan)):
            #w = self.fInstr.write(":route:close (@%i)" %self.fScan[i])
            w = self.fInstr.write(":sense:channel %i" %self.fScan[i])
            w = self.fInstr.write(":measure:voltage:dc?")
            r = self.fInstr.read()
            data.append(float(r))
            time.sleep(self.fSleep)
            time.sleep(0.01)
        return data
