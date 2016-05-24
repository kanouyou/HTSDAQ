
import visa

class IPowerSupply:

    def __init__(self):
        self.fRm = visa.ResourceManager()

    def SetGpib(self,Gpib):
        self.fPower = self.fRm.open_resource(gpib)

    def SetProtection(self,volt=5.):
        w = self.fPower.write("volt:prot %.2f" %volt)
        w = self.fPower.write("volt:prot?")
        r = self.fPower.read()
        print "protection voltage: %.2f" %volt

    def TurnOff(self):
        w = self.fPower.write("outp OFF")
    
    def TurnOn(self):
        w = self.fPower.write("outp ON")

    def SetCurrent(self, current):
        # read setup voltage
        w = self.fPower.write("volt?")
        r = self.fPower.read()
        setvolt = float(r)
        # read measured voltage
        w = self.fPower.write("meas:volt?")
        r = self.fPower.read()
        measvolt = float(r)

        while True:
            if measvolt>setvolt+0.01 or measvolt<setvolt-0.01:
                break
            setvolt+=0.1
            w = self.fPower.write("volt %.2f" %setvolt)

        w = self.fPower.write("curr %.2f" %current)

    def Read(self):
        # 0: current, 1: voltage
        data = []
        w = self.fPower.write("meas:curr?")
        r = self.fPower.read()
        data.append(float(r))
        w = self.fPower.write("meas:volt?")
        r = self.fPower.read()
        data.append(float(r))
        return data

