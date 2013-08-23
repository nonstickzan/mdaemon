#!/usr/bin/env ruby

### m_daemon: The Informant!
### cbailey 2013

#include twitter configuration for alerting
require 'lib/twitterconf'
require 'lib/config'

#initialize instance vars
@hostname = `hostname`.chomp
@time = Time.now
@options = {}

# Load OptionParser
require 'optparse'

OptionParser.new do |opts|
	executable_name = File.basename($PROGRAM_NAME)
	opts.banner = "Usage"

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
end.parse!

if @options[:load] == true
  cores = `cat /proc/cpuinfo | grep cores | awk -F: '{print $2}'`.to_i
  loadavg = [`cat /proc/loadavg | awk '{print $1,$2,$3}'`.split]
  loadavg = loadavg.flatten.collect {|i| i.to_f }
  loadavg.each do |i|
    if i >= cores
      Twitter.update("ALERT: Load Average #{i} > #{cores} on #{@hostname} @ #{@time}")
    end
  end
end

if @options[:svcs] == true
  @services.each do |i|
     svccheck = `sudo service #{i} status | grep running | wc -l`.chomp
     if svccheck == "0"
       Twitter.update("ALERT: Service #{i} NOT RUNNING on #{@hostname} @ #{@time}")
        if @options[:restart] == true
      	  cmd = `service #{i} restart`
          Twitter.update("WARNING: Service #{i} RESTARTING on #{@hostname} @ #{@time}")
        end
    end
  end
end

if @options[:disk] == true
disks = [`df -Pk | grep /dev/ | awk '{print $1}'`.chomp]
disks.each do |i|
   dskcheck = `df -Pk #{i}| grep -v Capacity | awk '{print $5}'`.chomp.chop.to_i
   if dskcheck > @diskthreshold 
    Twitter.update("ALERT: Disk Usage for #{i} EXCEEDS THRESHOLD (#{@diskthreshold}%) on #{@hostname} @ #{@time}")
   end
  end
end



