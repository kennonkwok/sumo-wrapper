require 'spec_helper'
require 'sumo_helper'

case os[:family]
when /redhat|debian|ubuntu/
  require 'syslog/logger'
  describe file('/etc/sumo.conf') do
    it { should exist }
  end

  describe file('/etc/sumo.json') do
    it { should exist }
  end

  describe file('/opt/SumoCollector') do
    it { should be_directory }
  end

  describe service('collector'), if: os[:family] == 'ubuntu' do
    it { should be_running }
    it { should be_enabled }
  end

  describe host('service.sumologic.com'), if: os[:family] == 'ubuntu' do
    it { should be_reachable.with(port: 443, proto: 'tcp') }
  end

  describe 'End to end API test' do
    it 'should receive data' do
      node = load_properties('/etc/sumo.conf')
      random = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      key = (0...50).map { random[rand(random.length)] }.join
      log = Syslog::Logger.new 'Sumologic'
      log.info "this line will be sent to SumoLogic: #{key}"
      sleep(180)
      collector = Sumologic::Collector.new({ name: 'pd', api_username: node['accessid'], api_password: node['accesskey'] })
      response = collector.search(key)
      expect(!response[0]['_raw'].nil?)
    end
  end

when /windows/
  require 'win32/eventlog'
  require "win32/mc"
  include Win32
  describe file('c:/sumo') do
    it { should be_directory }
  end

  describe file('c:/sumo/sumo.conf') do
    it { should exist }
  end

  describe file('c:/sumo/sumo.json') do
    it { should exist }
  end

  describe 'End to end API test' do
    it "should receive data" do
      node = load_properties('c:/sumo/sumo.conf')
      random = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      key = (0...50).map { random[rand(random.length)] }.join
      e1 = EventLog.open("Application")
      e1.report_event(
        :source      => "serverspec",
        :event_type  => 2,
        :category    => "0x00000002L".hex,
        :event_id    => "0xC0000003L".hex,
        :data        => "this line will be sent to SumoLogic: #{key}"
      )

      sleep(180)
      collector = Sumologic::Collector.new({ name: 'pd', api_username: node['accessid'], api_password: node['accesskey'] })
      response = collector.search(key)
      expect(!response[0]['_raw'].nil?)
    end
  end
end
