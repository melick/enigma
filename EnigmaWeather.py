import pyowm
import json

owm = pyowm.OWM('cf7844bf5d23112eb26c6feb5cb2d905')

# http://bigl.es/using-python-to-get-weather-data/
online = owm.is_API_online()
if online:

  # print "OWM was online (%s)" %(online)

    # ----- make the observation
    observation = owm.weather_at_place("Sunbury,OH")
    w = observation.get_weather()


    # ----- pull the bits we're interested in
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


    # ----- print them out to the console
  # print(w)
    print(det_status)
    print "%s%% cloud cov" %(clouds)
    print "wind %s" %(speed)
    print "dir %s" %(direction)
    print "pressure %s" %(pressure)
    print "temperature %s" %(temperature)
    print "%s%%rh" %(humidity)
    if rain == "":
        pass
    else:
        print "%s rain volume last 3h" %(rain)
    if snow == "":
        pass
    else:
        print "%s snow volumen last 3h" %(snow)


    # ----- get the location identification
    l = observation.get_location()
  # name = l.get_name()
  # lon  = l.get_lon()
  # lat  = l.get_lat()
    id   = l.get_ID()


    # ----- when was the observation taken?
    received = observation.get_reception_time(timeformat='iso') 


    # ----- print it out as well
    print "for %s at %s, received %s." # id time received

else:
    print "OWM was offline (%s)" %(online)
