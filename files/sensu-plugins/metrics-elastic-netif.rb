#!/opt/sensu/embedded/bin/ruby
#
#   netif-metrics
#
# DESCRIPTION:
#   Network interface throughput
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
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'
require 'json'

#
# Netif Metrics
#
class NetIFMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: Socket.gethostname.to_s

  def get_client_name

    return Socket.gethostname.split('.')[0]
  end

  def run

     client_name = get_client_name

    `sar -n DEV 1 1 | grep Average | grep -v IFACE`.each_line do |line|
      stats = line.split(/\s+/)
      unless stats.empty?
        stats.shift
        nic = stats.shift
        #output "#{config[:scheme]}.#{nic}.rx_kB_per_sec", stats[2].to_f if stats[3]
        #output "#{config[:scheme]}.#{nic}.tx_kB_per_sec", stats[3].to_f if stats[3]
        
        elastic = {
          metricset: 'netif',
          hostname: client_name,
          data: {
            interface: nic,
            rx_kB_per_sec: stats[2].to_f,
            tx_kB_per_sec: stats[3].to_f
          }
        }

        output elastic.to_json

      end
    end

    ok
  end
end
