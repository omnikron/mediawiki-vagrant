# == Class: role::parsoid
# Configures Parsoid, a wikitext parsing service
class role::parsoid {
    include ::mediawiki::parsoid
}
