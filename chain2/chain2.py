from email import header
from operator import index
from cv2 import sort

import requests
import json
import time
import paho.mqtt.client as mqtt
import pandas as pd
import os

def appendToCsv(line):
    filename="chain.csv"
    answ=os.path.exists(filename)
    with open(filename, "a" if answ else "w") as f:
        if(answ):
            f.write(str(line) + "\n")
        f.write(str(line) + "\n")    


def jprint(obj):
    # create a formatted string of the Python JSON object
    text = json.dumps(obj, sort_keys=True, indent=4)
    print(text)

def getInfo():
    response = requests.get("http://192.168.10.141/info.json")
    # print(response)
    info=response.json()
    # jprint(info)
    return info

def getLastCf():
    response = requests.get("http://192.168.10.141/lastcf.json")
    #print(response)
    lastCf=response.json()
    #jprint(lastCf)
    return lastCf

def getCf1():
    response = requests.get("http://192.168.10.141/getcf.json?type=cf1")
    #print(response)
    cf1=response.json()
    #jprint(cf1)
    return cf1

def sendCf1(msg):
    pl=msg['Chain2Data']['Payload']
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


# CurrQuartActEnergy = cf1['Chain2Data']['Payload']['CurrQuartActEnergy']
# InstantPower  = response.json()['Chain2Data']['Payload']['InstantPower']
# MeasurePosixTimestamp = response.json()['Chain2Data']['Payload']['MeasurePosixTimestamp']
# MessagePosixTimestamp = response.json()['Chain2Data']['Payload']['MessagePosixTimestamp']
# PrevQuartActEnergy = response.json()['Chain2Data']['Payload']['PrevQuartActEnergy']
# QuartAveragePower = response.json()['Chain2Data']['Payload']['QuartAveragePower']
# TariffCode = response.json()['Chain2Data']['Payload']['TariffCode']
# TotalActEnergy = response.json()['Chain2Data']['Payload']['TotalActEnergy']

# client = mqtt.Client()
# client.connect("192.168.10.4",1883,60)
# client.publish("rochouse/ha/sensor/chain2/payload/CurrQuartActEnergy", CurrQuartActEnergy);
# client.publish("rochouse/ha/sensor/chain2/payload/InstantPower", InstantPower);
# #client.publish("rochouse/ha/sensor/chain2/payload/MeasurePosixTimestamp", MeasurePosixTimestamp);
# #client.publish("rochouse/ha/sensor/chain2/payload/MessagePosixTimestamp", MessagePosixTimestamp);
# client.publish("rochouse/ha/sensor/chain2/payload/PrevQuartActEnergy", PrevQuartActEnergy);
# client.publish("rochouse/ha/sensor/chain2/payload/QuartAveragePower", QuartAveragePower);
# client.publish("rochouse/ha/sensor/chain2/payload/TariffCode", TariffCode);
# client.publish("rochouse/ha/sensor/chain2/payload/TotalActEnergy", TotalActEnergy);
# client.disconnect();

prevInfo=getInfo()
infoDF=pd.json_normalize(prevInfo)
csvInfo=infoDF.to_csv(index=False,header=True)

prevLastCF=getLastCf()
lastCfDF=pd.json_normalize(prevLastCF)
csvLastCf=lastCfDF.to_csv(index=False,header=True)

prevCF1=getCf1()
Cf1DF=pd.json_normalize(prevCF1)
csvCf1=Cf1DF.to_csv(index=False,header=True)

headers=str(infoDF.columns.values.tolist()) + "," + str(lastCfDF.columns.values.tolist()) + "," + str(Cf1DF.columns.values.tolist())
headers=headers.replace('[','')
headers=headers.replace(']','')
headers=headers.replace(',',';')
print(headers)
appendToCsv(headers)

#for x in range(100):
while True:
    info=getInfo()
    lastCF=getLastCf()
    Cf1=getCf1()
    if ( (json.dumps(prevInfo, sort_keys=True) != json.dumps(info, sort_keys=True)) or (json.dumps(prevLastCF, sort_keys=True) != json.dumps(lastCF, sort_keys=True) ) or (json.dumps(prevCF1, sort_keys=True) != json.dumps(Cf1, sort_keys=True) )):
        infoDF=pd.json_normalize(info)
        csvInfo=infoDF.to_csv(index=False,header=False,line_terminator=' ', sep=';')

        lastCfDF=pd.json_normalize(lastCF)
        csvLastCF=lastCfDF.to_csv(index=False,header=False,line_terminator=' ', sep=';')

        Cf1DF=pd.json_normalize(Cf1)
        csvCf1=Cf1DF.to_csv(index=False,header=False,line_terminator=' ', sep=';')

        line=csvInfo + ";" + csvLastCF + ";" + csvCf1
        print(line)
        appendToCsv(line)

        prevInfo=info
        prevLastCF=lastCF
        prevCF1 = Cf1
    time.sleep(1)


# cf1= getCf1()
# sendCf1(cf1)

# print("CurrQuartActEnergy,InstantPower,MeasurePosixTimestamp,MessagePosixTimestamp,PrevQuartActEnergy,QuartAveragePower,TariffCode,TotalActEnergy")
# print(str(CurrQuartActEnergy) + "," + str(InstantPower) + "," + str(MeasurePosixTimestamp) + "," + str(MessagePosixTimestamp) + "," + str(PrevQuartActEnergy) + "," + str(QuartAveragePower) + "," + str(TariffCode) + "," + str(TotalActEnergy))
