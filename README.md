mdaemon
=======

m_daemon (The Informant!) is a monitoring and alerting tool developed to bridge the gap until an enterprise-level solution can be approved, configured and deployed.

m_daemon assumes a *nix environment.  m_daemon has been tested on Ubuntu 12.04 LTS.

Logic would need to be written for Windows.

m_daemon utilizes Twitter for alerting: ( https://twitter.com/m_daemon )

Two reasons:

_1. All the cool kids do it_

_2. It's the easiest way to 'show-off' the alerting capabilities_

m_daemon monitors three system areas:

**Services**

m_daemon reads from an array of services configured in _lib/config.rb_. It looks for a status of '_running_'. Any other return causes an alert. 

If the -r (restart) flag is passed to m_daemon, it attempts to restart the process using 
_service #{name} restart_
and generates a warning alert.

**Disk Usage**

m_daemon populates a list of physical devices and checks utilized disk space using the _df_ command. It then compares this to a threshold set in _lib/config.rb_.
If the usage is higher, an alert is generated.

**System Load**

m_daemon finds the number of cores from _/proc/cpuinfo_, then skedaddles over to _/proc/loadavg_ and grabs the 1,5, and 15 minute load averages into an array. It then compares these load averages against the number of cores - if it is greater, it alerts, as processes are waiting for  CPU.

**Deployment**
=====
The ideal deployment for m_daemon would utilize a configuration manager or rsync to manage config.rb across multiple nodes - and cronjobs with a specific 'm_daemon' priv'd user. Currently m_daemon runs as 'root' which is a no-good, bad thing.

**Musings** (Shoulda, coulda, woulda)
======
At the end of the day, this implementation is definitely a bandaid for something more robust.

A server/agent architecture with a centrally-managed JSON configuration scheme would definitely be the 'future' of m_daemon. The m_daemon agent would run on-demand from the server and report back. NTP synchronization would be a must. 

Additionally, growing out the amount of 'stuff' that m_daemon can monitor, including log-parsing, more in-depth service control, and network monitoring.

m_daemon could also benefit from robust logging of errors, but again, in the current setup this would create a ton of cleanup and files on every node - a centralized logging system on the server would take care of these concerns.


