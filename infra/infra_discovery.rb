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
# Description:
# Introspective utility to determine hostname, IP, cloud provider, and cloud
# instance metadata. Designed for use during initial provisioning, quickstarts,
# or diagnostic tooling.
# -----------------------------------------------------------------------------

require 'socket'
require 'resolv'
require 'open3'

module InfraDiscovery
  module_function

  def cloudmeta(key)
    return nil unless system('which cloudmeta > /dev/null 2>&1')
    stdout, status = Open3.capture2("cloudmeta #{key}")
    status.success? ? stdout.strip : nil
  rescue
    nil
  end

  def local_ipv4
    Socket.ip_address_list.detect { |intf| intf.ipv4? && !intf.ipv4_loopback? }&.ip_address
  end

  def reverse_dns_hostname
    ip = local_ipv4
    return nil unless ip
    Resolv.getname(ip) rescue nil
  end

  def cloud_provider
    cloudmeta('cloud-provider') || 'LOCAL'
  end

  def aws_instance_id
    cloudmeta('instance-id')
  end

  def resolve_hostname
    # Fast path first
    hostname =
      cloudmeta('public-hostname') ||
      cloudmeta('local-hostname')  ||
      reverse_dns_hostname         ||
      local_ipv4

    hostname || 'localhost'
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

