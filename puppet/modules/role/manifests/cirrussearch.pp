# == Class: role::cirrussearch
# The CirrusSearch extension implements searching for MediaWiki using
# Elasticsearch.
class role::cirrussearch {
    include ::role::timedmediahandler
    include ::role::pdfhandler
    include ::role::cite
    include ::elasticsearch

    require_package('jq')

    # Elasticsearch plugins
    ## Analysis
    elasticsearch::plugin { 'icu':
        name    => 'elasticsearch-analysis-icu',
        version => '2.3.0',
    }
    elasticsearch::plugin { 'kuromoji':
        name    => 'elasticsearch-analysis-kuromoji',
        version => '2.3.0',
    }
    elasticsearch::plugin { 'stempel':
        name    => 'elasticsearch-analysis-stempel',
        version => '2.3.0',
    }
    elasticsearch::plugin { 'smartcn':
        name    => 'elasticsearch-analysis-smartcn',
        version => '2.3.0',
    }
    elasticsearch::plugin { 'hebrew':
        # Less stable then icu plugin
        ensure => 'absent',
        name   => 'elasticsearch-analysis-hebrew',
    }
    ## Highlighter
    elasticsearch::plugin { 'highlighter':
        group   => 'org.wikimedia.search.highlighter',
        name    => 'experimental-highlighter-elasticsearch-plugin',
        version => '0.0.13',
    }
    ## Trigram accelerated regular expressions and "safer" query
    elasticsearch::plugin { 'extra':
        group   => 'org.wikimedia.search',
        name    => 'extra',
        version => '1.3.0',
    }

    mediawiki::wiki { 'cirrustest': }

    mediawiki::extension { 'Elastica':
        composer => true,
    }

    mediawiki::extension { 'CirrusSearch':
        require       => Service['elasticsearch'],
        browser_tests => 'tests/browser',
    }

    mediawiki::settings { 'cirrustest:cirrussearch test suite':
        values => template('elasticsearch/CirrusSearch.php.erb'),
    }

    # By default vagrant sets up firefox as the global browsertest runner, we want
    # to ensure phantomjs is available for running the cirrussearch tests in a 
    # headless and parallelized maner
    package { 'phantomjs':
        ensure => present
    }

    exec { 'build_search_index':
        command => 'foreachwiki extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php --startOver && foreachwiki extensions/CirrusSearch/maintenance/forceSearchIndex.php',
        onlyif  => 'mwscript extensions/CirrusSearch/maintenance/cirrusNeedsToBeBuilt.php --quiet',
        user    => 'www-data',
        require => [
            Class['::mediawiki::multiwiki'],
            Mediawiki::Extension['CirrusSearch'],
            Exec['update_all_databases'],
        ]
    }
}
