# coding: utf-8

{
  en: {
    date: {
      formats: {
        year_month_day_concise: '%Y-%m-%d', # 2017-03-01
        month_day_year: '%b %-d, %Y', # Mar 1, 2017
        monthfull_day_year: '%B %-d, %Y' # March 1, 2017
      }
    },

    layouts: {
      footer: {
        copyright_html: 'Copyright &copy; 2005‑2018, The Board of Trustees of Leland Stanford Junior University. All rights reserved.',
        grant_html: 'The <strong>National Center for Biomedical Ontology</strong> was founded as one of the National Centers for Biomedical Computing, supported by the NHGRI, the NHLBI, and the NIH Common Fund under grant U54-HG004028.'
      }
    },

    home: {
      index: {
        find_ontology_placeholder: 'Start typing ontology name, then choose from list',
        query_placeholder: 'Enter a class, e.g. Melanoma',
        tagline: '',
        title: 'Welcome to the ' + $ORG_SITE,
        welcome: 'Welcome to ' + $SITE + ' '
      }
    },

    annotator: {
      index: {
        intro: 'Get annotations for biomedical text with classes from the ontologies',
        annotatorplus_html: '<em>Check out <a href="%{annotatorplus_href}">AnnotatorPlus</a> beta; a new version of the Annotator with added support for negation, and more!</em>'
      }
    },

    recommender: {
      intro: 'Get recommendations for the most relevant ontologies based on an excerpt from a biomedical text or a list of keywords'
    },

    search: {
      index: {
        intro: 'Search for a class in multiple ontologies',
        search_keywords_placeholder: 'Enter a class, e.g. Melanoma',
        categories_placeholder: 'Start typing to select categories or leave blank to use all',
        property_definition: 'Named association between two entities. Examples are "definition" (a relation between a class and some text) and "part-of" (a relation between two classes).',
        obsolete_definition: 'A class that the authors of the ontology have flagged as being obsolete and which they recommend that people not use.' +
          ' These classes are often left in ontologies (rather than removing them entirely) so that existing systems that depend on them will continue to function.'
      }
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
