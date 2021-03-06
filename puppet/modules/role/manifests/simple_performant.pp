# == Class: role::simple_performant
# This class configures MediaWiki to be slightly more performant,
# with simple enough things and without sacrificing functionality,
# except that it caches almost everything for 30 days.
# It's designed for smallish wikis: if you receive consistent traffic,
# do your homework.
# See https://www.mediawiki.org/wiki/Manual:Performance_tuning
class role::simple_performant {
    require ::role::mediawiki
    include ::role::fss
    include ::role::thumb_on_404
    include ::role::wikidiff2
    include ::apache::mod::expires

    require_package('unzip')

    $DAY         = 24 * 60 * 60
    $CACHE_ACCEL = 3
    $CACHE_DB    = 1

    php::ini { 'simple_performant':
        settings => { realpath_cache_size => '512K' },
    }

    mediawiki::settings { 'simple_performant':
        values => {
            wgCacheDirectory        => '/var/cache/mediawiki',
            wgMainCacheType         => $CACHE_ACCEL,
            wgParserCacheType       => $CACHE_DB,
            wgJobRunRate            => 0,
            wgEnableSidebarCache    => true,
            wgParserCacheExpireTime => 30 * $DAY,
            wgResourceLoaderMaxage  => {
                'unversioned' => {
                    'server' => $DAY,
                    'client' => $DAY,
                },
                'versioned'   => {
                    'server' => 30 * $DAY,
                    'client' => 30 * $DAY,
                },
            },
        },
        notify => Exec['rebuild_localisation_cache'],
    }

    exec { 'rebuild_localisation_cache':
        command     => 'mwscript rebuildLocalisationCache.php --force',
        user        => 'www-data',
        refreshonly => true,
        require     => Class['::mediawiki::multiwiki'],
    }

    $expires_active  = 'ExpiresActive On'
    $expires_default = 'ExpiresDefault "access plus 1 month"'

    apache::site_conf { 'expires':
        site    => $::mediawiki::wiki_name,
        content => "${expires_active}\n${expires_default}\n",
        require => Class['::apache::mod::expires'],
    }

    file { "${::mediawiki::apache::docroot}/robots.txt":
        ensure => present,
        mode   => '0444',
        source => 'puppet:///modules/role/simple_performant/robots.txt',
    }

    file { '/vagrant/mediawiki/skins/.htaccess':
        ensure  => present,
        source  => 'puppet:///modules/role/simple_performant/skins-htaccess',
        require => Class['::apache::mod::expires'],
    }
}
