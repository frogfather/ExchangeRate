require "exchangerate/version"
require "exchangerate/config"
require "exchangerate/rates"

class ExchangeRate

include Exchangerate
include Config  
include Rates
 
  def self.at(date,base="",counter="")
    base = base.upcase
    counter = counter.upcase
    #Validate date, base and counter currencies.
    return 0 if (!Rates::DateValid(date) || !Rates::CurrencyValid(base) || !Rates::CurrencyValid(counter))
    Config::ReadConfig()
    #If the local data is out of date, from the wrong source or doesn't exist, request it
    Rates::Request(Config::GetConfig("url")) if (!Config::CheckConfigData(date) || !Rates::LocalDataFileExists())
    #Always obtain the data from the local file
    Rates::ReadFromFile()
    #Data is not available for weekends - if the supplied date's a weekend we want to return data for the nearest previous date
    date = Rates::AdjustDate(date) if (!Rates::DataExistsForDate(date))      
    return 0 if (!Rates::DateValid(date))
    #We should have valid currency, countercurrency and a date for which data exists - we can get the conversion.    
    return Rates::GetConversion(date,base,counter) 
  end

  def self.refresh()
    Config::ReadConfig()
    Rates::Request(Config::GetConfig("url"))
  end

  #Methods to change/reset/view the data source
  def self.setUrl(url)
    Rates::SetDataSource(url)    
  end
  
  def self.resetUrl()
    Rates::ResetDataSource()
  end

  def self.currentUrl()
    return Rates::CurrentDataSource()
  end

  def self.lastRead()
    return Config::GetConfig("readdate")
  end
  
end






