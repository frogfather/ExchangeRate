require "exchangerate/fileutils"
$ASSETS_FILE_PATH = File.expand_path("..", File.dirname(__FILE__))

module Config

@defaultConfigFilename = $ASSETS_FILE_PATH+"/assets/config.txt"
@configData = {}

  def Config.WriteConfigData()
    dataToWrite = ''
    @configData.each {|key,value| dataToWrite += key + "," + value + "\n"}
    Fileutils::Writefile(dataToWrite,@defaultConfigFilename)
  end

  def Config.CheckConfigData(date)    
    #if the date of the last read is before the requested date we need to update our data
    return false if GetConfig('readdate') == ""
    return false if (date > Date.parse(GetConfig('readdate')))          
    return false if (GetConfig('url') != GetConfig('readurl'))
    return true
  end

  def Config.ReadConfig()
    if (Fileutils::Fileexist(@defaultConfigFilename))
      data =  Fileutils::Readfile(@defaultConfigFilename)
      #convert the supplied csv data to a hash    
      seplines = data.split(/\n+/)
      seplines.each{|x| @configData[x.split(',')[0]] = x.split(',')[1]}
    end
    #set defaults if the values from file don't make sense
    UpdateConfig('url', @defaultUrl) if GetConfig('url') == nil
    #if there's no date for the last read, set it to 1st Jan which will force a re-read
    UpdateConfig('readdate','2018-01-01') if GetConfig('readdate') == nil     
  end

  def Config.GetConfig(key)
    return @configData[key]
  end

  def Config.UpdateConfig(key, value)
    @configData[key] = value
    WriteConfigData()
  end



end
