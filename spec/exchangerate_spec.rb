RSpec.describe Exchangerate do

  it "has a version number" do
    expect(Exchangerate::VERSION).not_to be nil
  end

  it "accepts an input and returns an output" do
    expect(ExchangeRate.at(Date.today,'GBP','GBP')).to eq(1)
  end

  it "returns 0 if the date is > 89 days before the current date" do
    ExchangeRate.at(Date.today,'GBP','GBP')
    expect(ExchangeRate.at(Date.today-90,'GBP','GBP')).to eq(0)
  end

  it "returns 0 if the date is > today" do
    ExchangeRate.at(Date.today,'GBP','GBP')
    expect(ExchangeRate.at(Date.today+1,'GBP','GBP')).to eq(0)    
  end
 
  it "returns 0 if the country code doesn't exist" do
    expect(ExchangeRate.at(Date.today,'GBP','ZZZ')).to eq(0)    
  end
  

  it "returns data from the nearest preceding weekday if the supplied date is on a weekend" do
    saturday = Date.today
    while (!saturday.saturday?)
      saturday -=1
    end    
    fridayconv = ExchangeRate.at(saturday-1,'GBP','KRW')
    thursdayconv = ExchangeRate.at(saturday-2,'GBP','KRW')
    expect(ExchangeRate.at(saturday,'GBP','KRW')).not_to eq(thursdayconv)    
    expect(ExchangeRate.at(saturday,'GBP','KRW')).to eq(fridayconv)
  end
  
  it "returns stored data if there is no connection to the remote data" do
     ExchangeRate.setUrl("http://www.example.com")
     expect(ExchangeRate.at(Date.today,'GBP','GBP')).to eq(1)
     ExchangeRate.resetUrl
  end

  it "updates the stored url correctly" do
     ExchangeRate.setUrl("http://www.example.com")
     expect(ExchangeRate.currentUrl).to eq("http://www.example.com")
  end

  it "will accept currencies in lowercase" do
    expect(ExchangeRate.at(Date.today,'GbP','kRW')).to eq(ExchangeRate.at(Date.today,'GBP','KRW'))
  end

end
