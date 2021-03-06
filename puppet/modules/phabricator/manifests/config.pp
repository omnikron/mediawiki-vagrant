# vim:set sw=4 ts=4 sts=4 et:

# == Class: phabricator::config
#
# This class sets a phabricator config value
#
define phabricator::config(
    $deploy_dir,
    $value,
){
    include ::phabricator

    exec { "phab_set_${title}":
        command => "${deploy_dir}/phabricator/bin/config set ${title} '${value}'",
        require => Git::Clone['https://github.com/phacility/phabricator'],
        unless  => "grep '${title}' ${deploy_dir}/phabricator/conf/local/local.json | grep '${value}'",
    }
}
