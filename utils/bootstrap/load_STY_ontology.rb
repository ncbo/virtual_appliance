#!/usr/bin/env ruby

# Script to create a new ontology submission and upload an ontology file

NCBO_CRON_PATH = '/opt/ontoportal/ncbo_cron'

ENV['BUNDLE_GEMFILE'] = File.join(NCBO_CRON_PATH, "Gemfile")
require 'bundler/setup'
require 'rest-client'
require 'json'

APIKEY_SCRIPT = '/opt/ontoportal/virtual_appliance/utils/apikey.rb'
APIKEY = `ruby #{APIKEY_SCRIPT} get admin`.lines.last&.strip
TARGET_API = 'https://localhost:8443'
ONTOLOGY = 'STY'
ONTOLOGY_FILE_PATH = '/opt/ontoportal/virtual_appliance/deployment/artifacts/umls_semantictypes.ttl'

# Check if the ontology file exists
unless File.exist?(ONTOLOGY_FILE_PATH)
  abort("Ontology file not found at #{ONTOLOGY_FILE_PATH}")
end

# Ontology details
ONTOLOGY_DETAILS = {
  name: 'Semantic Types Ontology',
  administeredBy: ['admin']
}

# Submission details (for multipart upload)
SUBMISSION_DETAILS = {
  contact: [{ name: 'admin', email: 'admin@example.org' }],
  hasOntologyLanguage: 'UMLS',
  released: '2023-04-01',
  description: <<~DESC.strip,
    UMLS Semantic Network

    The Semantic Network consists of (1) a set of broad subject categories, or Semantic Types, that provide a consistent categorization of all concepts represented in the UMLS Metathesaurus, and (2) a set of useful and important relationships, or Semantic Relations, that exist between Semantic Types. This section of the documentation provides an overview of the Semantic Network, and describes the files of the Semantic Network. Sample records illustrate structure and content of these files.

    The Semantic Network is distributed as one of the UMLS Knowledge Sources and as an open source resource available on the Semantic Network Web site, subject to these terms and conditions.
  DESC
  status: 'production',
  version: '2023AA',
  file: File.new(ONTOLOGY_FILE_PATH, 'rb')
}

begin
  # Create ontology (idempotent if it already exists)
  response = RestClient::Request.execute(
    method: :put,
    url: "#{TARGET_API}/ontologies/#{ONTOLOGY}",
    payload: ONTOLOGY_DETAILS.to_json,
    headers: {
      Authorization: "apikey token=#{APIKEY}",
      content_type: :json,
      accept: :json
    },
    verify_ssl: OpenSSL::SSL::VERIFY_NONE
  )
  puts "Ontology #{ONTOLOGY} created:\n#{response.code} - #{response.body}"

  # Submit the ontology file
  submission_payload = RestClient::Payload::Multipart.new(SUBMISSION_DETAILS)

  response = RestClient::Request.execute(
    method: :post,
    url: "#{TARGET_API}/ontologies/#{ONTOLOGY}/submissions",
    payload: submission_payload,
    headers: {
      Authorization: "apikey token=#{APIKEY}"
    },
    verify_ssl: OpenSSL::SSL::VERIFY_NONE
  )
  puts "Submission created:\n#{response.code} - #{response.body}"
rescue RestClient::ExceptionWithResponse => e
  puts "HTTP error: #{e.response.code}\n#{e.response.body}"
rescue RestClient::Exception => e
  puts "RestClient exception: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
end
