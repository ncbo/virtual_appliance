#!/usr/bin/env ruby
# frozen_string_literal: true

# -----------------------------------------------------------------------------
# Part of the OntoPortal Virtual Appliance Project
# https://ontoportal.org
#
# Author: Alex Skrenchuk (@alexskr)
# Copyright (c) 2025 Stanford University and the OntoPortal Alliance
# SPDX-License-Identifier: Apache-2.0
#
# Description
#
# Introspective utility to determine hostname, IP, cloud provider, and cloud
# instance metadata. Designed for use during initial provisioning, quickstarts,
# or diagnostic tooling.
#
# CLI Usage:
#   ./infra_discovery.rb             → prints resolved hostname
#   ./infra_discovery.rb --cloud     → prints cloud provider
#
# Ruby Usage:
#   require_relative 'infra_discovery'
#   InfraDiscovery.resolve_hostname
#   InfraDiscovery.cloud_provider
#   InfraDiscovery.aws_instance_id
#   InfraDiscovery.summary
# -----------------------------------------------------------------------------

require 'socket'
require 'net/http'
require 'uri'
require 'ipaddr'
require 'resolv'
require 'open3'

module InfraDiscovery
  module_function

  def local_ipv4
    Socket.ip_address_list.detect { |intf| intf.ipv4? && !intf.ipv4_loopback? }&.ip_address
  end

  def valid_fqdn?(str)
    !!(str =~ /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/i)
  end

  def reverse_dns_hostname
    ip = local_ipv4
    return nil unless ip
    Resolv.getname(ip) rescue nil
  end

  def fetch_metadata(url, headers = {})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 2
    http.open_timeout = 2

    # IMDSv2 token for AWS
    if uri.host == '169.254.169.254' && url.include?('/latest/')
      token = fetch_aws_imds_v2_token
      headers['X-aws-ec2-metadata-token'] = token if token
    end

    request = Net::HTTP::Get.new(uri.request_uri)
    headers.each { |k, v| request[k] = v }

    response = http.request(request)
    response.is_a?(Net::HTTPSuccess) ? response.body.strip : nil
  rescue
    nil
  end

  def fetch_aws_imds_v2_token
    uri = URI('http://169.254.169.254/latest/api/token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 1
    http.open_timeout = 1

    req = Net::HTTP::Put.new(uri)
    req['X-aws-ec2-metadata-token-ttl-seconds'] = '60'

    response = http.request(req)
    response.is_a?(Net::HTTPSuccess) ? response.body : nil
  rescue
    nil
  end

  def aws_public_hostname
    fetch_metadata('http://169.254.169.254/latest/meta-data/public-hostname')&.then { |h| valid_fqdn?(h) ? h : nil }
  end

  def aws_private_hostname
    fetch_metadata('http://169.254.169.254/latest/meta-data/local-hostname')&.then { |h| valid_fqdn?(h) ? h : nil }
  end

  def aws_instance_id
    fetch_metadata('http://169.254.169.254/latest/meta-data/instance-id')
  end

  def azure_public_ip
    fetch_metadata(
      'http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text',
      { 'Metadata' => 'true' }
    )
  end

  def gcp_public_ip
    fetch_metadata(
      'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip',
      { 'Metadata-Flavor' => 'Google' }
    )
  end

  def ec2meta(key)
    return nil unless system('which ec2meta > /dev/null 2>&1')
    stdout, status = Open3.capture2("ec2meta #{key}")
    status.success? ? stdout.strip : nil
  rescue
    nil
  end

  def resolve_hostname
    ec2meta('public-hostname') ||
    ec2meta('local-hostname')  ||
    aws_public_hostname        ||
    aws_private_hostname       ||
    azure_public_ip            ||
    gcp_public_ip              ||
    reverse_dns_hostname       ||
    local_ipv4                 ||
    'localhost'
  end

  def cloud_provider
    return 'AWS'   if aws_private_hostname
    return 'Azure' if azure_public_ip
    return 'GCP'   if gcp_public_ip
    'LOCAL'
  end

  def summary
    {
      hostname: resolve_hostname,
      cloud: cloud_provider,
      instance_id: aws_instance_id,
      local_ip: local_ipv4
    }
  end

  def call
    resolve_hostname
  end

  def to_s
    resolve_hostname
  end
end

# --- CLI Entrypoint ---
if $PROGRAM_NAME == __FILE__
  if ARGV.first == '--cloud'
    puts InfraDiscovery.cloud_provider
  else
    puts InfraDiscovery.resolve_hostname
  end
end

