#!/usr/bin/env ruby

# script for creating a new ontology submission and uploading an ontology file.

require_relative '../apikey'

#get apikey for admin user
APIKEY = get_apikey('admin')
puts "#{APIKEY}"
# URL of the Ontoportal API
TARGET_API = 'http://localhost:8080'

# The acronym of existing ontology
ONTOLOGY = 'STY'

ONTOLOGY_DETAILS = {
   'name': 'Semantic Types Ontology',
   'administeredBy': ['admin'] }

SUBMISSION_DETAILS = {
  'contact': { 'name': 'admin', 'email': 'admin@example.org' },
  'hasOntologyLanguage': 'UMLS',
  'released': '2023-04-01',
  file: File.new('/opt/ontoportal/virtual_appliance/utils/bootstrap/umls_semantictypes.ttl', 'rb'),
  'description': 'UMLS Semantic Network\\r\\nThe Semantic Network consists of (1) a set of broad subject categories, or Semantic Types, that provide a consistent categorization of all concepts represented in the UMLS Metathesaurus, and (2) a set of useful and important relationships, or Semantic Relations, that exist between Semantic Types. This section of the documentation provides an overview of the Semantic Network, and describes the files of the Semantic Network. Sample records illustrate structure and content of these files.\\r\\n\\r\\nThe Semantic Network is distributed as one of the UMLS Knowledge Sources and as an open source resource available on the Semantic Network Web site, subject to these terms and conditions.',
  'status': 'production',
  'version': '2023AA'
}

# create contact
contact = LinkedData::Models::Contact.where(email: 'admin@example.org').first
unless contact
  contact = LinkedData::Models::Contact.new(name: 'admin', email: 'admin@example.org').save
  puts "created a new contact; #{contact}"
end

begin
  # create ontology
  response = RestClient::Request.execute(
    method: :put,
    url: "#{TARGET_API}/ontologies/#{ONTOLOGY}",
    payload: ONTOLOGY_DETAILS,
    headers: { Authorization: "apikey token=#{APIKEY}" }
  )
  puts "Ontology STY is created\n #{response.code}\n#{response.body}"
  # add new submission
  response = RestClient::Request.execute(
    method: :post,
    url: "#{TARGET_API}/ontologies/#{ONTOLOGY}/submissions",
    payload: SUBMISSION_DETAILS,
    headers: { Authorization: "apikey token=#{APIKEY}" }
  )
  puts "Submission is created\n #{response.code}\n#{response.body}"
rescue RestClient::ExceptionWithResponse => e
  # Handle exceptions for non-2xx responses
  puts "Error: #{e.response.code}\n#{e.response.body}"
rescue RestClient::Exception => e
  puts "RestClient exception: #{e.message}"
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
