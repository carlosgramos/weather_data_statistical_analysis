require 'readline'
require 'date'
require 'open-uri'

#The earliest start date for which there is consistent data
DATA_START_DATE = "2006-09-20"

#Max days limits the queries to the remote server
MAX_DAYS = 7

#The supported reading types as a hash
READING_TYPES = {
  "Wind_Speed" => "Wind Speed",
  "Air_Temp" => "Air Temp",
  "Barometic_Pressure" => "Pressure"
}

# Ask the user (via the command line) to provide valid start and end date.
# We call query_user_for_date twice (keeping the code dry).
# start_date and end_date are loaded into an Array.
# Only one value can be returned from a method or function.
def query_user_for_date_range
  start_date = nil
  end_date = nil

  until start_date && end_date
    puts "\n First, we need a start date."
    start_date = query_user_for_date

    puts "\n Next, we need an end date."
    end_date = query_user_for_date

    #until date_range_valid returns true
    unless !date_range_valid?(start_date, end_date)
      puts "Let's try again."
      start_date = end_date = nil
    end
  end #end outer until loop

  return start_date, end_date
end

# Ask the user for a single valid date, via the command line.
# Used for both start and end dates.

# Readline is a module, which defines a number of methods to
# facilitate completion and accesses input history from the Ruby interpreter.
# The readline method shows the prompt and reads the inputted line with
# line editing. The inputted line is added to the history if add_hist is true.
# We give the user the option to quit at anytime.
# The .parse method parses the given representation of date and time, and creates a date object.
def query_user_for_date
  date = nil
  until date.is_a? Date
    prompt = "\nPlease enter a date as YYYY-MM-DD: "
    response = Readline.readline(prompt, true)

    exit if ["quit", "enter", "q", "x"].include?(response)

    begin
      date = Date.parse(response)
    rescue ArgumentError
      puts "\nInvalid date format."
    end

    date = nil unless date_valid?(date)
  end #end until
  return date
end

# Test is a single date is valid
def date_valid?(date)
  #We specify a valid date range
  valid_dates = Date.parse(DATA_START_DATE)..Date.today
  #compare date entered by user, to valid_date range
  if valid_dates.cover?(date)
    return true
  else
    puts "\nDate must be after #{DATA_START_DATE} and before today."
    return false
  end
end

#Test if a range of dates is valid (i.e. spans a total of seven days), and it makes sense
def date_range_valid?(start_date, end_date)
  #start date can not be in the future
  if start_date > end_date
    puts "\nStart date must be before end date."
    return false
  #the end_date cannot be more than seven days from now
  elsif start_date + MAX_DAYS < end_date
    puts "\nNo more than #{MAX_DAYS} days. Be kind to the remote server!"
    return false
  end
  return true
end

###RETRIEVE REMOTE DATA###

#Retrieves readings for a paticular reading type between the dates specified
def get_readings_from_remote_for_dates(type, start_date, end_date)
  readings = []
  start_date.upto(end_date) do |date|
    readings += get_readings_from_remote(type, date)
  end
  return readings
end

def get_readings_from_remote(type, date)
  raise "Invalid Reading Type" unless
  READING_TYPES.keys.include?(type)

  #read the remote file, split readings into an array
  base_url = "https://lpo.dt.navy.mil/data/DM"
  url =
  "#{base_url}/Environmental_Data_Deep_Moor_#{date.year}.txt"
  puts "Retrieving: #{url}"
  data = open(url).readlines

  #Extract the reading from each line
  readings = data.map do |line|
    line_items = line.chomp.split(" ")
    reading = line_items[2].to_f
  end
  return readings
end
