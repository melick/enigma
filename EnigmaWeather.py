import pyowm
import json
import csv
from time import gmtime, strftime

'''
Connect to Open Weather Map (http://bigl.es/using-python-to-get-weather-data/), making sure it's online first
- pull down weather reading for Sunbury, OH - USA
  - pull location name from observation
  - pull reception time of observation
  - break out parts of observation we're interested in
- get current timestamp
- write to csv file
'''


DEFAULT_API_KEY = "cf7844bf5d23112eb26c6feb5cb2d905"
city_id = 5173412


owm = pyowm.OWM(DEFAULT_API_KEY)
online = owm.is_API_online()
if online:

    print "OWM was online (%s)" %(online)

    '''Make the observation'''
    observation = owm.weather_at_id(city_id)
    w = observation.get_weather()

    '''Get the location identification'''
    l = observation.get_location()
    name    = l.get_name()
    # lon     = l.get_lon()
    # lat     = l.get_lat()
    # city_id = l.get_ID()

    '''Determine when was the observation taken'''
    received = observation.get_reception_time(timeformat='iso') 

    '''pull the bits we're interested in'''
    time         = w.get_reference_time(timeformat='iso')             # ...or in ISO8601 => '2013-08-30 14:16:46+00'
    det_status   = w.get_detailed_status()                            # Get detailed weather status => 'Broken clouds'
    clouds       = w.get_clouds()                                     # Get cloud coverage
    speed        = w.get_wind()['speed']                              # wind info.
    direction    = w.get_wind()['deg']                                # "
    pressure     = w.get_pressure()['press']                          # Get atmospheric pressure
    #              w.get_temperature()                                # Get temperature in Kelvin
    #              w.get_temperature(unit='celsius')                  # ... or in Celsius degs
    temperature  = w.get_temperature('fahrenheit')['temp']            # ... or in Fahrenheit degs
    #                                                                 # temp_min, temp, temp_max
    humidity     = w.get_humidity()
    rain         = w.get_rain().get('3h', '')                         # Get rain volume only offers 3h I think
    snow         = w.get_snow().get('3h', '')                         # Get snow volume only offers 3h I think

    '''Pull current system time'''
    ts           = strftime("%Y-%m-%d %H:%M:%S", gmtime())            # Time script was run

    '''Open output file in apend mode, write data'''
    with open('datafile.csv', 'a') as datafile:
        csvwriter = csv.writer(datafile, delimiter=',', dialect='excel',
                               quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
        csvwriter.writerow([name, received, time, det_status, clouds, speed, direction, pressure, temperature, humidity, rain, snow, ts])
    '''put your toys away, little Johnny'''
    datafile.close()

else:
    print "OWM was offline (%s)" %(online)


'''HC SVNT DRACONES'''
