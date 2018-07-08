# Exchangerate

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/exchangerate`. To experiment with that code, run `bin/console` for an interactive prompt.

This gem provides exchange rates between currencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exchangerate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exchangerate

## Usage

ExchangeRate
Currency converter gem
Usage:
ExchangeRate.at(date,base currency, counter currency)
    • date is a Date object between today and today – 89 (see note below about weekends)
    • base currency and counter currency are three letter strings. Case is ignored.
Return value is the exchange rate between the two currencies on the specified date or the nearest preceding weekday if the specified date is a weekend. If the date is invalid or either currency is unknown the return value is 0.
The ECB feed has no data for Saturday or Sunday. If the date supplied is a Saturday or Sunday and there is no stored data available then the last preceding date we have data for is used (generally the Friday before). 
If the date supplied is a Saturday or Sunday but the nearest preceding date with data is out of range (i.e. more than 89 days ago) the return value is 0 as I felt it would not be appropriate to return data for a future date.
The number of decimal places used depends on the number of decimal places in the stored data. If one currency is recorded with more decimal places than the other, the higher number is used. So if the base currency has a rate of 1.32 and the counter currency has a rate of 8.34784 the result will be to 5 decimal places.
ExchangeRate.refresh() 
Forces an update of the stored data from the specified source. If a conversion is requested and the requested date is after the last read (e.g. the gem has not been used before) or the specified source has changed then this method will be called internally.
ExchangeRate.setUrl(url)
Data is taken from "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml" by default, setUrl will change this to the specified url. The new url will not be used until ExchangeRate.refresh() is called.
ExchangeRate.resetUrl() 
Sets the url back to the default one
ExchangeRate.currentUrl() 
Displays the currently set url
ExchangeRate.lastRead() 
Displays the date of the last time fresh data was retrieved from the remote feed.
Notes:
Files
The gem writes to two external files. One, data.txt contains the raw data from the remote source. The other config.txt contains three lines of comma separated values:
    • url: the remote source to use to fetch the date
    • readdate: the last time the data was read
    • readurl: where the last data was retrieved from
Other data sources
The gem should be able to read data in json or XML format provided that:
    • the first part of the date is in the format ‘yyyy-mm-dd’ or ‘yyyy/mm/dd’ 
    • the country codes are ISO alpha 3
    • the rates themselves are in the form x.xxxx i.e. one or more number, a decimal point and then one or more number.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/exchangerate.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
