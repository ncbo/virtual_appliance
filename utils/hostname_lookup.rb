# coding: utf-8
require 'socket'
require 'net/http'
require 'uri'
require 'ipaddr'

# Functions for determine the external IP address of the appliance in the
# initial/default deployment case. Domain name/URL of the ontoportal can be set
# in the Ontoportal Customization section after these functions.

# Simple IP address lookup. This doesn't make connection to external hosts
def local_ip_simple
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

  UDPSocket.open do |s|
    s.connect '8.8.8.8', 1 # google dns
    s.addr.last
  end
ensure
  Socket.do_not_reverse_lookup = orig
end

# Determine public IP address from AWS metadata if its available
def aws_metadata_public_ipv4
  uri = URI.parse('http://169.254.169.254/latest/meta-data/public-ipv4')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 2
  http.open_timeout = 2

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    case response
    # read AWS meta-data/public-ipv4
    when Net::HTTPSuccess
      # return IP address if its valid ip address
      (IPAddr.new(response) rescue nil).nil? ? response.body : false
    else
      # metadata is off so falling back
      false
    end
  rescue Exception => e
    # metadata is probably not availalbe
    puts "exception #{e.message}"
    false
  end
end

def aws_metadata_public_hostname
  uri = URI.parse('http://169.254.169.254/latest/meta-data/public-hostname')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 2
  http.open_timeout = 2

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    case response
    # read AWS meta-data/public-hostname
    when Net::HTTPSuccess
      # FIXME: check for valid FQDN before returning it
      response.body
    else
      # metadata is off so falling back
      false
    end
  rescue Exception => e
    # metadata is probably not availalbe
    # puts "exception #{e.message}"
    false
  end
end

def azure_metadata_public_ipv4
  # https://github.com/cloudbooster/Azure-Instance-Metadata/blob/master/Instance-Metadata.md#retrieving-public-ip-address
  uri = URI.parse('http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 2
  http.open_timeout = 2

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Metadata'] = true
    response = http.request(request)

    case response
    # read AWS meta-data/public-ipv4
    when Net::HTTPSuccess
     (IPAddr.new(response) rescue nil).nil? ? response.body : false
    else
      # metadata is off so falling back
      false
    end
  rescue Exception => e
    # metadata is not availalbe
    # puts "exception #{e.message}"
    false
  end
end

# local IP address lookup.
def ip_address
  # first try AWS metadata lookup
  ip_address ||= aws_metadata_public_ipv4
  # then check azure metadata lookup
  ip_address ||= azure_metadata_public_ipv4
  # fall back to local ip address if AWS/azure metadata is not avaiable
  ip_address ||= local_ip_simple
  ip_address
end

def hostname
  hostname = nil
  case $CLOUD_PROVIDER
  when 'AWS'
    aws_metadata_public_hostname
  when 'azure'
    azure_metadata_public_ipv4
  else
    local_ip_simple
  end
  hostname
end
