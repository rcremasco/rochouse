import time
import json
import paho.mqtt.client as mqtt
import os
import datetime

from re import X
from websocket import create_connection



def appendToLog(line):
    line = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S') + " - " + line
    print(line)
    filename="chain2.log"
    answ=os.path.exists(filename)
    with open(filename, "a" if answ else "w") as f:
        # if(answ):
        #     f.write(str(line) + "\n")
        f.write(str(line) + "\n")    

def sendCf1(pl):
    client = mqtt.Client()
    client.connect("192.168.10.4",1883,60)
    client.publish("rochouse/ha/sensor/chain2/payload/CurrQuartActEnergy", pl['CurrQuartActEnergy']);
    client.publish("rochouse/ha/sensor/chain2/payload/InstantPower", pl['InstantPower']);
    #client.publish("rochouse/ha/sensor/chain2/payload/MeasurePosixTimestamp", MeasurePosixTimestamp);
    #client.publish("rochouse/ha/sensor/chain2/payload/MessagePosixTimestamp", MessagePosixTimestamp);
    client.publish("rochouse/ha/sensor/chain2/payload/PrevQuartActEnergy", pl['PrevQuartActEnergy']);
    client.publish("rochouse/ha/sensor/chain2/payload/QuartAveragePower", pl['QuartAveragePower']);
    client.publish("rochouse/ha/sensor/chain2/payload/TariffCode", pl['TariffCode']);
    client.publish("rochouse/ha/sensor/chain2/payload/TotalActEnergy", pl['TotalActEnergy']);
    client.disconnect();

def sendCf21(pl):
    client = mqtt.Client()
    client.connect("192.168.10.4",1883,60)
    client.publish("rochouse/ha/sensor/chain2/payload/InstantPower", pl['InstantPower']);
    client.disconnect();

def parseInfoFrame(frame):
    line = "Info - id: " + frame['Chain2Info']['Id'] + " CFcountFromBoot: " + str(frame['Chain2Info']['CFcountFromBoot']) 
    appendToLog(line)

def parseCF21(p):
    sendCf21(p)
    line="CF21 - EventType=" + str(p['EventType']) + " EventsCounter=" + str(p['EventsCounter']) + " InstantPower=" + str(p['InstantPower']) 
    appendToLog(line)

def parseCF1(p):
    sendCf1(p)
    line="CF1 - TariffCode=" + str(p['TariffCode']) + \
        " CurrQuartActEnergy=" + str(p['CurrQuartActEnergy']) + \
        " InstantPower=" + str(p['InstantPower']) + \
        " QuartAveragePower=" + str(p['QuartAveragePower']) + \
        " TotalActEnergy=" + str(p['TotalActEnergy'])
    appendToLog(line)

def parseCF22(p):
    # esubero potenza
    line="CF22 - EventType=" + str(p['EventType']) + \
        " EventsCounter=" + str(p['EventsCounter']) + \
        " InstantPower=" + str(p['InstantPower']) + \
        " OutageDuration=" + str(p['OutageDuration'])
    appendToLog(line)

def parseCF23(p):
    # interruzione servizio elettrico
    line="CF23 - EventType=" + str(p['EventType']) + \
        " EventsCounter=" + str(p['EventsCounter']) + \
        " OutageDuration=" + str(p['OutageDuration'])
    appendToLog(line)

def parseCF51(p):
    # attraversamento soglia potenza
    line="CF51 - EventType=" + str(p['EventType']) + \
        " EventsCounter=" + str(p['EventsCounter']) + \
        " InstantPower=" + str(p['InstantPower']) + \
        " Gap=" + str(p['Gap'])
    appendToLog(line)

def parseCF5(p):
    #sendCf1(p)
    line="CF5 - DailyTotalActEnergyF1=" + str(p['DailyTotalActEnergyF1']) + \
        " DailyTotalActEnergyF2=" + str(p['DailyTotalActEnergyF2']) + \
        " DailyTotalActEnergyF3=" + str(p['DailyTotalActEnergyF3']) + \
        " DailyTotalActEnergyF4=" + str(p['DailyTotalActEnergyF4']) + \
        " DailyTotalActEnergyF5=" + str(p['DailyTotalActEnergyF5']) + \
        " DailyTotalActEnergyF6=" + str(p['DailyTotalActEnergyF6']) + \
        " DailyMaxInstantPower=" + str(p['DailyMaxInstantPower']) + \
        " DailyMaxInstantPowerDateTime=" + str(p['DailyMaxInstantPowerDateTime']) + \
        " DayType=" + str(p['DayType'])
    appendToLog(line)

def parseCF9(p):
    #sendCf1(p)
    line="CF9 - WeeklyVeffMin=" + str(p['WeeklyVeffMin']) + \
        " WeeklyVeffMinDateTime=" + str(p['WeeklyVeffMinDateTime']) + \
        " WeeklyVeffMax=" + str(p['WeeklyVeffMax']) + \
        " WeeklyVeffMaxDateTime=" + str(p['WeeklyVeffMaxDateTime']) + \
        " CounterVeffBetween10Percent=" + str(p['CounterVeffBetween10Percent']) + \
        " CounterVeffUpto15NegPercent=" + str(p['CounterVeffUpto15NegPercent']) + \
        " CounterVeffUpto15PosPercent=" + str(p['CounterVeffUpto15PosPercent']) + \
        " CounterVeffOver15PosPercent=" + str(p['CounterVeffOver15PosPercent']) + \
        " CounterVeffUnder15NegPercent=" + str(p['CounterVeffUnder15NegPercent'])
    appendToLog(line)

def parseCF10(p):
    #sendCf1(p)
    line="CF10 - MonthlyTotalActEnergyF1=" + str(p['MonthlyTotalActEnergyF1']) + \
        " MonthlyTotalActEnergyF2=" + str(p['MonthlyTotalActEnergyF2']) + \
        " MonthlyTotalActEnergyF3=" + str(p['MonthlyTotalActEnergyF3']) + \
        " MonthlyTotalActEnergyF4=" + str(p['MonthlyTotalActEnergyF4']) + \
        " MonthlyTotalActEnergyF5=" + str(p['MonthlyTotalActEnergyF5']) + \
        " MonthlyTotalActEnergyF6=" + str(p['MonthlyTotalActEnergyF6']) + \
        " MonthlyMaxQuartAveragePower=" + str(p['MonthlyMaxQuartAveragePower']) + \
        " MonthlyMaxQuartAveragePowerDateTime=" + str(p['MonthlyMaxQuartAveragePowerDateTime'])
    appendToLog(line)

def parseCF20(p):
    #sendCf1(p)
    line="CF20 - EventType=" + str(p['EventType']) + \
        " EventsCounter=" + str(p['EventsCounter']) + \
        " CustomerCode=" + str(p['CustomerCode']) + \
        " POD=" + str(p['POD']) + \
        " PESSE=" + str(p['PESSE']) + \
        " Vendor=" + str(p['Vendor']) + \
        " Phone=" + str(p['Phone']) + \
        " StartContract=" + str(p['StartContract']) + \
        " ContractPower=" + str(p['ContractPower']) + \
        " AvailablePower=" + str(p['AvailablePower']) + \
        " FreezingDay=" + str(p['FreezingDay']) + \
        " Gap=" + str(p['Gap']) + \
        " DataPlate=" + str(p['DataPlate']) + \
        " K=" + str(p['K'])
    appendToLog(line)


def parseDataFrame(frame):
    type=frame['Chain2Data']['Type']

    if type == "CF21" :
        parseCF21(frame['Chain2Data']['Payload'])
    elif type == "CF22" :
        parseCF22(frame['Chain2Data']['Payload'])
    elif type == "CF23" :
        parseCF23(frame['Chain2Data']['Payload'])
    elif type == "CF5" :
        parseCF5(frame['Chain2Data']['Payload'])
    elif type == "CF9" :
        parseCF9(frame['Chain2Data']['Payload'])    
    elif type == "CF10" :
        parseCF10(frame['Chain2Data']['Payload'])
    elif type == "CF20" :
        parseCF20(frame['Chain2Data']['Payload'])
    elif type == "CF1" :
        parseCF1(frame['Chain2Data']['Payload'])
    else:
        appendToLog("unknown type" +  str(frame))

wsOpen=False
procRun=True

while (procRun):
    while (not wsOpen):
        try:
            appendToLog("Opening websocket..")
            ws = create_connection("ws://192.168.10.199:81")
            wsOpen=True
            appendToLog("websocket open")
            ws.send("!")
        except:
            appendToLog("Errore apertura websocket")
            time.sleep(1)

    while True:
        try:
            result =  ws.recv()
        except:
            appendToLog("error in ws.recv")
            break

        try:
        #    print ("Received '%s'" % result)
            rxJData = json.loads(result)
            if (rxJData.get("Chain2Data")):
                parseDataFrame(rxJData)
        #        print("Data")
            elif (rxJData.get("Chain2State")):
                print("State")
            elif (rxJData.get("Chain2Info")):
                parseInfoFrame(rxJData)
        #        print("Info")
            else:
                appendToLog("unknown frame -> " + str(rxJData))
        except:
            appendToLog("error in parse frame -> " + str(rxJData))

    try:    
        ws.close()
        wsOpen=False
    except:
        appendToLog("Errore closing websocket")
        wsOpen=False