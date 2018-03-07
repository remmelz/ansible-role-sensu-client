#!/opt/sensu/embedded/bin/ruby
#
#   metrics-net
#
# DESCRIPTION:
#   Simple plugin that fetchs metrics from /proc/net/netstat
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   $ ./metrics-netstat.rb --scheme webserver1
#     webserver1.TCPLoss 2260598 1458303623
#     webserver1.TCPLostRetransmit 0 1458303623
#     webserver1.TCPFastRetrans 1273056 1458303623
#     webserver1.TCPForwardRetrans 13723 1458303623
#     webserver1.TCPSlowStartRetrans 42570 1458303623
#     webserver1.TCPTimeouts 400828 1458303623
#
# NOTES:
#   Does it behave differently on specific platforms, specific use cases, etc
#
# LICENSE:
#   Copyright 2016 Kees Remmelzwaal <kees@fastmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'
require 'json'

#
# Linux Netstat Metrics
#
class LinuxNetstatMetrics < Sensu::Plugin::Metric::CLI::Graphite

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.netstat"

  def get_client_name

    return Socket.gethostname.split('.')[0]
  end

  def run

    $netstat = `netstat -s`
    client_name = get_client_name

    tcp_timeouts    = $netstat.scan(/(\d+) other TCP timeouts/i)[0]
    tcp_connections = $netstat.scan(/(\d+) connections established/i)[0]

    tcp_timeouts = 0 if not tcp_timeouts
    tcp_timeouts = tcp_timeouts[0].to_i if tcp_timeouts

    tcp_connections = 0 if not tcp_connections
    tcp_connections = tcp_connections[0].to_i if tcp_connections


    elastic = {
      metricset: 'netstat',
      hostname: client_name,
      data: {
        TCPTimeouts:    tcp_timeouts,
        TCPConnections: tcp_connections
      }
    }

    output elastic.to_json

    ok

  end
end

