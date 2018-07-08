require "exchangerate/fileutils"
require "exchangerate/config"
require "exchangerate/connection"
require "exchangerate/processdata"

module Rates

@defaultDataFilename = $ASSETS_FILE_PATH+"/assets/data.txt"
@fxData = {}
@DataFromFile = ""

  def Rates.Request(url = $DEFAULT_URL)    
    done = false 
    loopCount = 0
    #try three times to get the data
    while !done do      
      Connection::Sendrequest($DEFAULT_URL)
      if (Connection::Getresponsecode() == 200)      
        #only updates the stored data if a valid response is received   
        Fileutils::Writefile(Connection::Getresponsebody(),@defaultDataFilename)
        Config::UpdateConfig("readdate", Date.today.strftime("%Y-%m-%d"))
        Config::UpdateConfig("url",url)
        Config::UpdateConfig("readurl",url)        
        done = true
      end
      if (!done)
        sleep 2
        loopCount += 1
        done = true if loopCount == 3
      end
    end    
  end  

  def Rates.ReadFromFile()
    @DataFromFile = Fileutils::Readfile(@defaultDataFilename) 
    @fxData = ProcessData::ProcessDataFromFile(@DataFromFile)
  end

  def Rates.GetConversion(date,base,counter)
    baseRate = GetRate(date, base)
    counterRate = GetRate(date, counter) 
    return 0 if (baseRate == nil || counterRate == nil)
    dp = GetMaxDp(baseRate,counterRate)
    return (baseRate.to_f / counterRate.to_f).round(dp)    
  end

  def Rates.GetMaxDp(base,counter)
    return 0 if base == nil || counter == nil
    baseDp = base.length - (base.index('.')+1)
    counterDp = counter.length - (counter.index('.')+1)
    max = (baseDp > counterDp)? baseDp : counterDp
    return max
  end

  def Rates.GetRate(date, currency)
    dateKey = date.strftime("%Y-%m-%d")
    return nil if (!@fxData.has_key?(dateKey))
    return @fxData[dateKey][currency]
  end

  def Rates.DataExistsForDate(date)
    dateKey = date.strftime("%Y-%m-%d")
    return (@fxData.has_key?(dateKey))
  end

  def Rates.SetDataSource(url)
    Config::UpdateConfig("url",url)
  end
 
  def Rates.ResetDataSource()
    SetDataSource($DEFAULT_URL)
  end

  def Rates.CurrentDataSource()
    return Config::GetConfig("url")
  end

  def Rates.LocalDataFileExists()
    return Fileutils::Fileexist(@defaultDataFilename)
  end

  def Rates.CurrencyValid(currency)
    return ((/^[A-Z]{3}$/ =~ currency) == 0)
  end

  def Rates.DateValid(date)
    return (date <= Date.today && date >= Date.today-89)    
  end

  def Rates.AdjustDate(date)
    #finds nearest preceding date that has valid data
    done = false
    while (!done) do     
      date -= 1
      done = DataExistsForDate(date) || !DateValid(date) 
    end
  return date
  end

end
