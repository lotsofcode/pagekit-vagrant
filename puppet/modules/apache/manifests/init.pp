class apache 
{      
    package 
    { 
        "apache2":
            ensure  => present,
            require => [Exec['apt-get update'], Package['php5'], Package['php5-dev'], Package['php5-cli']]
    }
    
    service 
    { 
        "apache2":
            ensure      => running,
            enable      => true,
            require     => Package['apache2'],
            subscribe   => [
                File["/etc/apache2/mods-enabled/rewrite.load"],
                File["/etc/apache2/sites-available/000-default.conf"],
                File["/etc/apache2/conf-enabled/phpmyadmin.conf"]
            ],
    }

    file 
    { 
        "/etc/apache2/mods-enabled/rewrite.load":
            ensure  => link,
            target  => "/etc/apache2/mods-available/rewrite.load",
            require => Package['apache2'],
    }

    file 
    { 
        "/etc/apache2/sites-available/000-default.conf":
            ensure  => present,
            owner => root, group => root,
            source  => "/vagrant/puppet/templates/vhost",
            require => Package['apache2'],
    }

    exec 
    { 
        'echo "ServerName localhost" | sudo tee /etc/apache2/conf-enabled/fqdn.conf':
            require => Package['apache2'],
    }

    # Change user
    exec { "ApacheUserChange" :
        command => "sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars",
        onlyif  => "grep -c 'APACHE_RUN_USER=www-data' /etc/apache2/envvars",
        require => Package["apache2"],
        notify  => Service["apache2"],
    }

    # Change group
    exec { "ApacheGroupChange" :
        command => "sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars",
        onlyif  => "grep -c 'APACHE_RUN_GROUP=www-data' /etc/apache2/envvars",
        require => Package["apache2"],
        notify  => Service["apache2"],
    }

    exec { "apache_lockfile_permissions" :
        command => "chown -R vagrant:www-data /var/lock/apache2",
        require => Package["apache2"],
        notify  => Service["apache2"],
    }
}
