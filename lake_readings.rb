#!/usr/bin/env ruby
require_relative('functions')

puts "\n*** LAKE PEND OREILLE READINGS ***"
puts "Calculates the mean and median of the wind speed, air temperature,"
puts "and barometric pressure recorded at the Deep Moor station"
puts "on Lake Pend Oreille for a given range of dates."

#call query_user_for_date_range from function.rb, and do a double assingment to start_date and end_date
start_date, end_date = query_user_for_date_range

#strftime: Formats date according to the directives in the given format string.
#The directives begins with a percent (%) character.  %B(full month), %d(day of the month), %Y(year)
# puts start_date.strftime('%B %d, %Y')
# puts end_date.strftime('%B %d, %Y')

READING_TYPES.each do |type, label|
  readings = get_readings_from_remote_for_dates(type, start_date, end_date)
  puts "#{label}: " + readings.join(", ")
end
