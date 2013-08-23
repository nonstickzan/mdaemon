def load do
  hostname = `hostname`.chomp
  loadalert = Hash.new
  cores = `cat /proc/cpuinfo | grep cores | awk -F: '{print $2}'`.to_i
  loadavg = [`cat /proc/loadavg | awk '{print $1,$2,$3}'`.split]
  loadavg = loadavg.flatten.collect {|i| i.to_f }
  loadavg.each do |i|
    if i >= cores 
      loadalert.store("ALERT Load > #{cores} on #{hostname}", "#{i}")
    end
  end
end
