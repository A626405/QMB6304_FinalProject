import geoip2
import geoip2.database
import pandas as pd

reader = geoip2.database.Reader('data/external/GeoLite2-Country.mmdb')

def get_country(ip):
    try:
        response = reader.country(ip)
        return pd.DataFrame({'country':[response.country.name]})
    except:
        return pd.DataFrame({'country':[pd.NA]})
  
      
