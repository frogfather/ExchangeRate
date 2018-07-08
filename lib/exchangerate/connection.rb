require "http"

module Connection

  def Connection.Sendrequest(url)
    @response = HTTP.get(url)
  end

  def Connection.Getresponsecode()
    return @response.code
  end

  def Connection.Getresponsebody()
    return @response.to_s
  end 

end

