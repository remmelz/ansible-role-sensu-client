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

  def cpuStats

    result = `sar | tail -2 | head -1`.split(' ')

    stats_user   = result[3].to_f
    stats_nice   = result[4].to_f
    stats_system = result[5].to_f
    stats_iowait = result[6].to_f
    stats_steal  = result[7].to_f
    stats_idle   = result[8].to_f

    #output "#{config[:scheme]}.sar.cpu.user_percentage", stats_user, @timestamp
    #output "#{config[:scheme]}.sar.cpu.nice_percentage", stats_nice, @timestamp
    #output "#{config[:scheme]}.sar.cpu.system_percentage", stats_system, @timestamp
    #output "#{config[:scheme]}.sar.cpu.iowait_percentage", stats_iowait, @timestamp
    #output "#{config[:scheme]}.sar.cpu.steal_percentage", stats_steal, @timestamp
    #output "#{config[:scheme]}.sar.cpu.idle_percentage", stats_idle, @timestamp

    elastic = {
      metricset: 'sar-cpu',
      hostname: @client_name,
      data: {
        user: stats_user,
        nice: stats_nice,
        system: stats_system,
        iowait: stats_iowait,
        steal: stats_steal,
        idle: stats_idle
      }
    }
    output elastic.to_json

  end

  def run

    @timestamp = Time.now.to_i
    @client_name = get_client_name

    cpuStats

    ok
  end
end

