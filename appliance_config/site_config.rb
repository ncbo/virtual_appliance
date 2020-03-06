# coding: utf-8
require 'socket'
require 'net/http'
require 'uri'
require 'ipaddr'

# Simple IP address lookup. This doesn't make connection to external hosts
def local_ip_simple
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

  UDPSocket.open do |s|
    s.connect '8.8.8.8', 1 #google
    s.addr.last
  end
ensure
  Socket.do_not_reverse_lookup = orig
end

# Determine public IP address from AWS metadata if its available
def aws_metadata_public_ipv4
  uri = URI.parse("http://169.254.169.254/latest/meta-data/public-ipv4")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 2
  http.open_timeout = 2

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    case response
    #read AWS meta-data/public-ipv4
    when Net::HTTPSuccess then
     #return IP address if its valid ip address
     (IPAddr.new(response) rescue nil).nil? ? response.body : false
    else
      #metadata is off so falling back
      return false
    end
  rescue Exception => e
    #metadata is probably not availalbe
    puts "exception #{e.message}"
    return false
  end
end

def azure_metadata_public_ipv4
  #https://github.com/cloudbooster/Azure-Instance-Metadata/blob/master/Instance-Metadata.md#retrieving-public-ip-address
  uri = URI.parse("http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 2
  http.open_timeout = 2

  begin
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Metadata'] = true
    response = http.request(request)

    case response
    #read AWS meta-data/public-ipv4
    when Net::HTTPSuccess then
     (IPAddr.new(response) rescue nil).nil? ? response.body : false
    else
      #metadata is off so falling back
      return false
    end
  rescue Exception => e
    #metadata is not availalbe
    puts "exception #{e.message}"
    return false
  end
end

# local IP address lookup.
def local_ip
  #first try AWS metadata lookup
  ip_addres = aws_metadata_public_ipv4
  unless ip_address
    #check azure metadata lookup
    ip_address =  azure_metadata_public_ipv4
    unless ip_address
      #if AWS metadata is not avaiable fall back
      ip_address = local_ip_simple
    end
  end
  ip_address
end

#$REST_HOSTNAME = 'data.ontoportal.example.org'
#$REST_PORT = '8080'
#$REST_URL_PREFIX = 'http://data.ontoportal.example.org'
#$UI_HOSTNAME = 'ontoportal.example.org'

# Organization info
#$ORG = "NCBO"
#$ORG_URL = "http://ontoportal.org"

# Site name (required)
#$SITE = "OntoPortal Appliance"

# Unique string representing the UI's id for use with the BioPortal Core
# This api key is automatically generated on first boot and updated here
$API_KEY = "4f804d33-0784-4201-afcf-51ec3cb7e9c8"

# REST core service address
#$REST_URL = "http://#{$REST_HOSTNAME}:#{$REST_PORT}"

# Help page, launched from Support -> Help menu item in top navigation bar.
#$WIKI_HELP_PAGE = "https://www.bioontology.org/wiki/index.php/BioPortal_Help"

# Google Analytics ID (optional)
#$ANALYTICS_ID = ""

# Announcements mailman mailing list REQUEST address, EX: list-request@lists.example.org
# NOTE: You must use the REQUEST address for the mailing list. ONLY WORKS WITH MAILMAN LISTS.
#$ANNOUNCE_LIST = "appliance-users-request@example.org"

# Email addresses used for sending notifications (errors, feedback, support)
#$SUPPORT_EMAIL = "support@example.org"
#$ADMIN_EMAIL = "admin@example.org"
#$ERROR_EMAIL = "errors@example.org"

# reCAPTCHA
# In order to use reCAPTCHA on the user account creation page:
#    1. Obtain a key from reCAPTCHA: http://recaptcha.net
#    2. Include the corresponding keys below (between the single quotes)
#    3. Set the USE_RECAPTCHA option to 'true'
#ENV['USE_RECAPTCHA'] = 'false'
#ENV['RECAPTCHA_PUBLIC_KEY']  = ''
#ENV['RECAPTCHA_PRIVATE_KEY'] = ''

