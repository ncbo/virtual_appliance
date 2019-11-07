# coding: utf-8
#
#Appliance bioportal_web_ui config
# This file should not be modified.  Most of the site related settings should be done in
# site_config.rb

# bioportal_web_ui config file for default OntoPortal appliance.
if File.exist?('config/site_config.rb')
  require_relative 'site_config.rb'
end

# Appliance needs to know its own address to display proper URLs
# Ideally it should be set to FQDN but we fall back to using IP address if FQDN is not manually set.
$REST_HOSTNAME ||= local_ip
$REST_PORT ||= '8080'
$UI_HOSTNAME ||= local_ip
$REST_URL_PREFIX ||= "#{$REST_HOSTNAME}:#{$REST_PORT}"

# Organization info
$ORG ||= "NCBO"
$ORG_URL ||= "http://appliance.ontoportal.org"

# Site name (required)
$SITE ||= "OntoPortal Appliance"

# The URL for the BioPortal Rails UI (this application)
$UI_URL = "http://#{$UI_HOSTNAME}"

# REST core service address
$REST_URL ||= "http://#{$REST_HOSTNAME}:#{$REST_PORT}"

# URL where BioMixer GWT app is located
$BIOMIXER_URL = "//#{$UI_HOSTNAME}/BioMixer"

# annotator proxy location.  https://github.com/sifrproject/annotators/
# annotator proxy is running on tomcat which is reverse proxied by nginx
$PROXY_URL = "#{$REST_URL}"

# If you are running a PURL server to provide URLs for ontologies in your BioPortal instance, enable this option
$PURL_ENABLED = false

# The PURL URL is generated using this prefix + the abbreviation for an ontology.
# The PURL URL generation algorithm can be altered in app/models/ontology_wrapper.rb
$PURL_PREFIX = "http://purl.bioontology.org/ontology"

# If your BioPortal installation includes Annotator set this to false
$ANNOTATOR_DISABLED = false

# If your BioPortal installation includes Resource Index set this to false
$RESOURCE_INDEX_DISABLED = true

# Unique string representing the UI's id for use with the BioPortal Core
$API_KEY ||= "1de0a270-29c5-4dda-b043-7c3580628cd5"

# REST core service address
$REST_URL ||= "http://#{$REST_HOSTNAME}:#{$REST_PORT}"

# Max number of children to return when rendering a tree view
$MAX_CHILDREN = 2500

# Max number of children that it's possible to display (more than this is either too slow or not helpful to users)
$MAX_POSSIBLE_DISPLAY = 10000

# Max size allowed for uploaded files
$MAX_UPLOAD_SIZE = 1073741824

# Release version (appears in the footer)
$RELEASE_VERSION = "OntoPortal Appliance 3.0.rc1"

# URL for release notes (see top-right menu item Support -> Release Notes)
$RELEASE_NOTES = "https://www.bioontology.org/wiki/BioPortal_Virtual_Appliance_Release_Notes"

# Pairing a name with an array of ontology virtual ids will allow you to filter ontologies based on a subdomain.
# If your main UI is hosted at example.org and you add custom.example.org pointing to the same Rails installation
# you could filter the ontologies visible at custom.example.org by adding this to the hash: "custom" => { :name => "Custom Slice", :ontologies => [1032, 1054, 1099] }
# Any number of slices can be added. Groups are added automatically using the group acronym as the subdomain.
$ENABLE_SLICES = false
$ONTOLOGY_SLICES = {}

# Help page, launched from Support -> Help menu item in top navigation bar.
$WIKI_HELP_PAGE = "https://www.bioontology.org/wiki/BioPortal_Help"

# Google Analytics ID (optional)
$ANALYTICS_ID ||= ""

# A user id for user 'anonymous' for use when a user is required for an action on the REST service but you don't want to require a user to login
$ANONYMOUS_USER = 0

# Cube metrics reporting
$ENABLE_CUBE = false

$NOT_DOWNLOADABLE = {}
# Enable client request caching
$CLIENT_REQUEST_CACHING = true

# If you don't use Airbrake you can have exceptions emailed to the $ERROR_EMAIL address by setting this to 'true'
$EMAIL_EXCEPTIONS = false

# Email settings
ActionMailer::Base.smtp_settings = {
  :address  => "", # smtp server address, ex: smtp.example.org
  :port  => 25, # smtp server port
  :domain  => "", # fqdn of rails server, ex: rails.example.org
}

# Announcements mailman mailing list REQUEST address, EX: list-request@lists.example.org
# NOTE: You must use the REQUEST address for the mailing list. ONLY WORKS WITH MAILMAN LISTS.
$ANNOUNCE_LIST ||= "appliance-users-request@example.org"

# Email addresses used for sending notifications (errors, feedback, support)
$SUPPORT_EMAIL ||= "support@example.org"
$ADMIN_EMAIL ||= "admin@example.org"
$ERROR_EMAIL ||= "errors@example.org"

# reCAPTCHA
# In order to use reCAPTCHA on the user account creation page:
#    1. Obtain a key from reCAPTCHA: http://recaptcha.net
#    2. Include the corresponding keys below (between the single quotes)
#    3. Set the USE_RECAPTCHA option to 'true'
ENV['USE_RECAPTCHA'] ||= 'false'
ENV['RECAPTCHA_PUBLIC_KEY']  ||= ''
ENV['RECAPTCHA_PRIVATE_KEY'] ||= ''

# Custom BioPortal logging
require 'log'
$REMOTE_LOGGING = false

##
# Custom Ontology Details
# Custom details can be added on a per ontology basis using a key/value pair as columns of the details table
#
# Example:
# $ADDITIONAL_ONTOLOGY_DETAILS = { 1000 => { "Additional Detail" => "Text to be shown in the right-hand column." } }
##
$ADDITIONAL_ONTOLOGY_DETAILS = {}

#Front notice appears on the front page only and is closable by the user. It remains closed for seven days (stored
$FRONT_NOTICE = ''

# Site notice appears on all pages and remains closed indefinitely. Stored below as a hash with a unique key and a
#  EX: $SITE_NOTICE = { :unique_key => 'Put your message here (can include <a href="/link">html</a> if you use
$SITE_NOTICE = { } 
################################
## AUTO-GENERATED DO NOT MODIFY
#################################

# Full string for site, EX: "NCBO BioPortal"
$ORG_SITE = ($ORG.nil? || $ORG.empty?) ? $SITE : "#{$ORG} #{$SITE}"

# Email address to mail when exceptions are raised
#ExceptionNotifier.exception_recipients = [$ERROR_EMAIL]
