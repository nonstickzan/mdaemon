#!/usr/bin/env ruby

### m_daemon: The Informant!
### cbailey 2013

#include twitter configuration for alerting
require 'lib/twitterconf'

#include config file for all alerting options
require 'lib/config'

#initialize instance vars
@hostname = `hostname`.chomp
@time = Time.now
@options = {}

# Load OptionParser
require 'optparse'

OptionParser.new do |opts|
executable_name = File.basename($PROGRAM_NAME)

#Show a banner to the user when passed -h,including usage information
opts.banner = "Matt Daemon is The Informant!

Usage: #{executable_name} -options"

opts.on('-l','--load','Check system load') do |load|
	@options[:load] = true
end

opts.on('-d','--disk','Check disk usage') do |disk|
	@options[:disk] = true
end

opts.on('-s','--services','Check running services') do |svcs|
	@options[:svcs] = true
end

opts.on('-r','--restart','Restart the service if it is not running') do
	@options[:restart] = true
end
#Parse the CLI options
end.parse!

#After parsing, check to see if any arguments remain, if so, show the banner and alert the user
if ARGV.empty?
  puts "You must provide a switch."
  puts opts.banner
end


if @options[:load] == true
#Grab the number of processor cores
  cores = `cat /proc/cpuinfo | grep cores | awk -F: '{print $2}'`.to_i
#Grab the 1,5,15 minute load averages from /proc/loadavg and split into an array 
 loadavg = [`cat /proc/loadavg | awk '{print $1,$2,$3}'`.split]
#flatten the array and convert all elements to floats
  loadavg = loadavg.flatten.collect {|i| i.to_f }
  loadavg.each do |i|
# If the system load average is > # of cores, alert.
    if i >= cores
      Twitter.update("ALERT: Load Average #{i} > #{cores} on #{@hostname} @ #{@time}")
    end
  end
end

if @options[:svcs] == true
#Pull services list from config.rb
  @services.each do |i|
#Check the status of the service, if not running, wc-l will == 0
     svccheck = `sudo service #{i} status | grep running | wc -l`.chomp
     if svccheck == "0"
       Twitter.update("ALERT: Service #{i} NOT RUNNING on #{@hostname} @ #{@time}")
#if the restart flag has been passed, attempt to restart the service
        if @options[:restart] == true
      	  cmd = `service #{i} restart`
          Twitter.update("WARNING: Service #{i} RESTARTING on #{@hostname} @ #{@time}")
        end
    end
  end
end

if @options[:disk] == true
#grab a list of 'physical' disks and store them to an array
disks = [`df -Pk | grep /dev/ | awk '{print $1}'`.chomp]
disks.each do |i|
#awk out disk usage % column, strip the % and convert to an integer
   dskcheck = `df -Pk #{i}| grep -v Capacity | awk '{print $5}'`.chomp.chop.to_i
#compare to threshold set in config.rb, if greater, alert
   if dskcheck > @diskthreshold 
    Twitter.update("ALERT: Disk Usage for #{i} EXCEEDS THRESHOLD (#{@diskthreshold}%) on #{@hostname} @ #{@time}")
   end
  end
end



