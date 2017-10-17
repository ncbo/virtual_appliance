# coding: utf-8

{
  :en => {
    home: {
      welcome: 'Welcome to ' + $SITE,
      tagline: ""
    },

    annotator: {
      intro: 'Get annotations for biomedical text with classes from the ontologies'
    },

    recommender: {
      intro: 'Get recommendations for the most relevant ontologies based on an excerpt from a biomedical text or a list of keywords' 
    },

    search: {
      intro: 'Search for a class in multiple ontologies'
    },

    projects: {
      intro: 'Browse a selection of projects that use ' + $SITE + ' resources'
    },

    ontologies: {
      intro: 'Browse the library of ontologies',

      metrics: {
        intro: $SITE + ' calculates the metrics on the salient properties of the ontology, including statistics and quality-control
          and quality-assurance metrics. Each ontology may have all, some, or no values filled in for its metrics and only metrics
          for the most recent version are reflected. The metrics currently do not distinguish between the terms defined directly in
          this ontology and imported terms (for OWL) or referenced terms (for OBO).
          <a target="_blank" href="http://www.bioontology.org/wiki/index.php/Ontology_Metrics">See metrics descriptions</a>.'
      }
    },

    mappings: {
      intro: 'Browse mappings between classes in different ontologies'
    },

    resource_index: {
      intro: 'Search biomedical resources'
    },

    about: {
      welcome: 'Welcome to the National Center for Biomedical Ontology’s ' + $SITE + '. ' + $SITE + ' is a web-based application 
        for accessing and sharing biomedical ontologies.',
      
      getting_started: $SITE + ' allows users to browse, upload, download, search, comment on, and create mappings for ontologies.',
      
      browse: 'Users can browse and explore individual ontologies by navigating either a tree structure or an animated graphical view. 
        Users can also view mappings and ontology metadata, and download ontologies. Additionally, users who are signed in may submit 
        a new ontology to the library.',

      rest_examples_html: 'View documentation and examples of the <a href="http://data.bioontology.org/documentation" target="_blank">' + $SITE + ' REST API.</a>',
      
      announce_list_html: 'To receive notices of new releases or site outages, please subscribe to the 
        <a href="https://mailman.stanford.edu/mailman/listinfo/bioportal-announce" target="_blank">bioportal-announce list</a>.'
    },

    most_viewed_date: '',

    most_viewed: '',

    stats: ''
  }
}
