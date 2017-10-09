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
/usr/bin/python /home/melick/enigma/EnigmaWeather.py
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

    '''
    pull the bits we're interested in
    https://pyowm.readthedocs.io/en/latest/pyowm.webapi25.html#
    '''
    time         = w.get_reference_time(timeformat='iso')             # ...or in ISO8601 => '2013-08-30 14:16:46+00'
    sunset       = w.get_sunset_time()                                # (int or None) – GMT UNIX time of sunset or None on polar days
    sunrise      = w.get_sunrise_time()                               # (int or None) – GMT UNIX time of sunrise or None on polar nights
    clouds       = w.get_clouds()                                     # Get cloud coverage percentage
    rain         = w.get_rain().get('3h', '')                         # Get rain volume only offers 3h I think
    snow         = w.get_snow().get('3h', '')                         # Get snow volume only offers 3h I think
    speed        = w.get_wind()['speed']                              # wind info.
    direction    = w.get_wind()['deg']                                # "
    humidity     = w.get_humidity()
    pressure     = w.get_pressure()['press']                          # Get atmospheric pressure
    #              w.get_temperature()                                # Get temperature in Kelvin
    #              w.get_temperature(unit='celsius')                  # ... or in Celsius degs
    temperature  = w.get_temperature('fahrenheit')['temp']            # ... or in Fahrenheit degs
    #                                                                 # temp_min, temp, temp_max
    status       = w.get_status                                       # (Unicode) – short weather status
    det_status   = w.get_detailed_status()                            # Get detailed weather status => 'Broken clouds'
    code         = w.get_weather_code                                 # (int) – OWM weather condition code    - https://openweathermap.org/weather-conditions
    icon         = w.get_weather_icon_name                            # (Unicode) – weather-related icon name - https://openweathermap.org/weather-conditions
    viz          = w.get_visibility_distance                          # (float) – visibility distance
    dew          = w.get_dewpoint                                     # (float) – dewpoint
    humidex      = w.get_humidex                                      # (float) – Canadian humidex
    heat         = w.get_heat_index                                   # (float) – heat index

    '''Pull current system time'''
    ts           = strftime("%Y-%m-%d %H:%M:%S", gmtime())            # Time script was run

    '''Open output file in apend mode, write data'''
    with open('datafile.csv', 'a') as datafile:
        csvwriter = csv.writer(datafile, delimiter=',', dialect='excel',
                               quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
        csvwriter.writerow([city_id, name, received, time, sunset, sunrise, clouds, rain, snow, speed, direction, humidity, pressure, temperature, status, det_status, code, icon, viz, dew, humidex, heat, ts])
    '''put your toys away, little Johnny'''
    datafile.close()

else:
    print "OWM was offline (%s)" %(online)


'''HC SVNT DRACONES'''
