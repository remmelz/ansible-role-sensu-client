#!/opt/sensu/embedded/bin/ruby
#  encoding: UTF-8
#   <script name>
#
# DESCRIPTION:
#   This plugin uses SAR information
#
#  SAR
#  ----
# In computing, sar (System Activity Report) is a Unix System V-derived system monitor
# command used to report on various system loads, including CPU activity, memory/paging,
# device load, network. Linux distributions provide sar through the sysstat package.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux, Windows, BSD, Solaris, etc
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: socket
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 Kees Remmelzwaal <kees@fastmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'

class SARstats < Sensu::Plugin::Metric::CLI::Graphite

  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}"

  def get_client_name

    return Socket.gethostname.split('.')[0]
  end


  def diskStats

    result = `sar -b | tail -2 | head -1`.split(' ')

    stats_tps     = result[2].to_f
    stats_rtps    = result[3].to_f
    stats_wtps    = result[4].to_f
    stats_breadps = result[5].to_f
    stats_bwrtnps = result[6].to_f

    #output "#{config[:scheme]}.sar.disk.transfers_per_sec", stats_tps, @timestamp
    #output "#{config[:scheme]}.sar.disk.read_req_per_sec", stats_rtps, @timestamp
    #output "#{config[:scheme]}.sar.disk.writes_req_per_sec", stats_wtps, @timestamp
    #output "#{config[:scheme]}.sar.disk.blocks_read_per_sec", stats_breadps, @timestamp
    #output "#{config[:scheme]}.sar.disk.blocks_writes_per_sec", stats_bwrtnps, @timestamp

    elastic = {
      metricset: 'sar-disk',
      hostname: @client_name,
      data: {
        tps: stats_tps,
        rtps: stats_rtps,
        wtps: stats_wtps,
        breadps: stats_breadps,
        bwrtnps: stats_bwrtnps,
      }
    }
    output elastic.to_json

  end

  def run

    @timestamp = Time.now.to_i
    @client_name = get_client_name

    diskStats

    ok
  end
end

