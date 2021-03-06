# == Class: role::mediawiki
# Provisions a MediaWiki instance powered by HHVM, MySQL, and redis.
#
# === Parameters
# [+hostname+]
#   Hostname for the main wiki.
#
class role::mediawiki(
    $hostname,
){
    include ::arcanist
    include ::mediawiki
    require ::misc
    require ::mwv
    require ::mysql
    require ::redis

    require_package('php5-tidy')
    require_package('tidy')
}
