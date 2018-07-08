require "xmlsimple"
require "crack"
require "crack/xml"

module ProcessData

  @rateHash = Hash.new #Holds rate data for a given day
  @dataHash = Hash.new #Holds data in the format {date=>{currency=>rate}}
  @country
  @rate
  @date
  
  def ProcessData.ProcessDataFromFile(data)    
    dataStructure = DetermineDataStructure(data[0..4])
    if (dataStructure== 'xml')
      convertedData = Crack::XML.parse(data)    
    elsif (dataStructure == 'json')
      convertedData = Crack::JSON.parse(data)
    else 
      convertedData = nil
    end
    @country = ""
    @rate = ""
    @date = ""
    ExtractInformation(convertedData) #populates the @dataHash in a format that makes lookup easier
    return @dataHash
  end  

  def ProcessData.DetermineDataStructure(data)
    #We need to know the data type so we use the correct method in Crack
    #Valid JSON starts always with '{' or '['
    #Valid XML starts always with '<'
    return 'xml' if (data.index('<')==0)
    return 'json' if (data.index('{')==0 || data.index('[')==0)
    return '?' #unknown
  end

  def ProcessData.ExtractInformation(data)
    if (data.class == Hash)
      data.keys.each do
      |key|         
      if (data[key].class != String)
        ExtractInformation(data[key])
      else
        dataElement = IdentifyData(data[key])
	case dataElement
	when "date"
	  @date = data[key]
	  #if the rate hash is populated we can add the date(key) and rate hash(value) to the data hash
	  if (!@rateHash.empty?)
 	    AddToDataHash(@date,@rateHash)
            @date = ""
            @rateHash.clear
	  end
        when "country"
 	  @country = data[key]
	  if (@rate.length > 0)
	    AddToRateHash(@country,@rate)
	    @country = ""
            @rate = ""
	  end
        when "rate"
	  @rate = data[key]
	  if (@country.length > 0)
	    AddToRateHash(@country,@rate)
	    @country = ""
            @rate = ""
          end	  
	end	
      end 
    end   
    elsif (data.class == Array)
      data.each {|element|ExtractInformation(element) if (element.class != String)}                           
    end
  end

  def ProcessData.IdentifyData(data)
    #we're looking for country codes, rates or dates
    return "date" if ((/^[0-9]{4}[-\/][0-9]{2}[-\/][0-9]{2}/ =~ data) == 0) 
    return "country" if ((/^[A-Z]{3}$/ =~ data) == 0)
    return "rate" if ((/\d+\.\d+/ =~ data) == 0)
    return "unknown"
  end

  def ProcessData.AddToRateHash(key,value)
    #key should be country code, value should be rate. Both strings
    return if (key == "" || value == "")
    @rateHash[key] = value    
  end

  def ProcessData.AddToDataHash(key,value)
    #here the value should be a hash. Check if it's empty
    return if (key == "" || value.empty?)
    #EUR doesn't appear in the data because everything's referenced to it. 
    #To make the conversion logic simpler we add it here with rate of 1.000
    value['EUR'] = "1.000"
    @dataHash[key] = value.clone
  end

end


