#!/usr/bin/env ruby

# script for creating a new ontology submission and uploading an ontology file.

require_relative '../apikey.rb'

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
  'released': '2021-11-01',
  file: File.new('/srv/ontoportal/virtual_appliance/utils/bootstrap/umls_semantictypes.ttl', 'rb'),
  'description': 'UMLS Semantic Network\\r\\nThe Semantic Network consists of (1) a set of broad subject categories, or Semantic Types, that provide a consistent categorization of all concepts represented in the UMLS Metathesaurus, and (2) a set of useful and important relationships, or Semantic Relations, that exist between Semantic Types. This section of the documentation provides an overview of the Semantic Network, and describes the files of the Semantic Network. Sample records illustrate structure and content of these files.\\r\\n\\r\\nThe Semantic Network is distributed as one of the UMLS Knowledge Sources and as an open source resource available on the Semantic Network Web site, subject to these terms and conditions.',
  'status': 'production',
  'version': '2021AB'
}

# create ontology
response = RestClient::Request.execute(
  method: :put,
  url: "#{TARGET_API}/ontologies/#{ONTOLOGY}",
  payload: ONTOLOGY_DETAILS,
  headers: { Authorization: "apikey token=#{APIKEY}" }
)

puts response.code
puts response

# create submission
response = RestClient::Request.execute(
  method: :post,
  url: "#{TARGET_API}/ontologies/#{ONTOLOGY}/submissions",
  payload: SUBMISSION_DETAILS,
  headers: { Authorization: "apikey token=#{APIKEY}" }
)

puts response.code
puts response
