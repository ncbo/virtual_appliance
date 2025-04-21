#!/usr/bin/env ruby
# coding: utf-8
require 'socket'
require 'net/http'
require 'uri'
require 'ipaddr'
require 'resolv'

# Functions for determine the external IP address of the appliance in the
# initial/default deployment case.
# It is recomened to set the Domain name/URL of the ontoportal appliance
# in the Ontoportal Customization section instead of relying on this functions.

# Simple IP address lookup.
def local_ip_simple
  Socket.ip_address_list.detect { |intf| intf.ipv4? && !intf.ipv4_loopback? }&.ip_address || false
end

# validate FQDN
def fqdn?(str)
  !!(str =~ /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/)
end

# Aempt reverse DNS on local IP
def reverse_dns_lookup
  ip = local_ip_simple
  return false unless ip

  begin
    # Attempt to resolve IP to hostname
    host = Resolv.getname(ip)
  rescue Resolv::ResolvError
    host = false
  end

  host
end

# Determine public IP address from AWS metadata if its available
def aws_metadata_public_ipv4
  uri = URI.parse('http://169.254.169.254/latest/meta-data/public-ipv4')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 1
  http.open_timeout = 1

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    case response
    # read AWS meta-data/public-ipv4
    when Net::HTTPSuccess
      # return IP address if its valid ip address
      (IPAddr.new(response.body) rescue nil).nil? ? false : response.body
    else
      # metadata is off so falling back
      false
    end
  rescue StandardError => e
    # metadata is probably not availabe
    # puts "exception #{e.message}"
    false
  end
end

def aws_metadata_public_hostname
  uri = URI.parse('http://169.254.169.254/latest/meta-data/public-hostname')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 1
  http.open_timeout = 1

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    case response
    # read AWS meta-data/public-hostname
    when Net::HTTPSuccess
      fqdn?(response.body) ? response.body : false
    else
      false
    end
  rescue StandardError => e
    # metadata is not availalbe
    # puts "exception for aws #{e.message}"
    false
  end
end

def azure_metadata_public_ipv4
  # https://github.com/cloudbooster/Azure-Instance-Metadata/blob/master/Instance-Metadata.md#retrieving-public-ip-address
  uri = URI.parse('http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 1
  http.open_timeout = 1

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Metadata'] = true
    response = http.request(request)

    case response
    when Net::HTTPSuccess
      (IPAddr.new(response.body) rescue nil).nil? ? false : response.body
    else
      # metadata is off so falling back
      false
    end
  rescue StandardError => e
    # metadata is not availalbe
    # puts "exception for azure #{e.message}"
    false
  end
end

def gcp_metadata_public_ipv4
  uri = URI.parse('http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip')
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 2
  http.open_timeout = 2

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Metadata-Flavor'] = 'Google'
    response = http.request(request)
    case response
    # read GCP external-ip
    when Net::HTTPSuccess
      (IPAddr.new(response.body) rescue nil).nil? ? false : response.body
    else
      # metadata is off so falling back
      false
    end
  rescue StandardError => e
    # metadata is probably not availalbe
    # puts "exception for gcp #{e.message}"
    false
  end
end

# hostname/fqdn lookup.
# ontoportal needs to know its own hostname/fqdn so that it can properly constract ajax calls to the backend
# ideally it should be hardcoded in the site_config
def my_hostname
  # first try AWS metadata lookup
  ip_address ||= aws_metadata_public_hostname
  # then check azure metadata lookup
  ip_address ||= azure_metadata_public_ipv4
  # then check GCP metadata lookup
  ip_address ||= gcp_metadata_public_ipv4
  # then attempt to get hostname form reverse_dns
  ip_address ||= reverse_dns_lookup
  # fall back to local ip address if AWS/azure metadata is not avaiable
  ip_address ||= local_ip_simple
  # use localhost if everything fails
  ip_address || 'localhost'
end

def dontuse_hostname
  hostname = nil
  case $CLOUD_PROVIDER
  when 'AWS'
    aws_metadata_public_hostname
  when 'azure'
    azure_metadata_public_ipv4
  when 'GCP'
    gcp_metadata_public_ipv4
  else
    local_ip_simple
  end
  hostname
end
