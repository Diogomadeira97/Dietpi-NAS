<?php
$CONFIG = array (
  'passwordsalt' => 'KF4zuQRiQ3GzEupPvjzmhzRA6zfsPk',
  'secret' => 'BhUKqjpBwgUX6PQHPlb1UmztF8N6YAnHwTZP6SWvy4bfAxRb',
  'trusted_domains' =>
  array (
    0 => 'localhost',
1 => '*',
  ),
  'datadirectory' => '/mnt/dietpi_userdata/nextcloud_data',
  'dbtype' => 'mysql',
  'version' => '30.0.5.1',
'hashingThreads' => 4,
'memcache.local' => '\\OC\\Memcache\\APCu',
'filelocking.enabled' => true,
'memcache.locking' => '\\OC\\Memcache\\Redis',
'redis' => array ('host' => '/run/redis/redis-server.sock', 'port' => 0,),
  'overwrite.cli.url' => 'http://localhost/nextcloud',
  'dbname' => 'nextcloud',
  'dbhost' => 'localhost',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'oc_admin',
  'dbpassword' => 'Iu<LOy[-z>as;Ab0_b^V]@}t8gPQ?.',
  'installed' => true,
  'instanceid' => 'oc3q5bhneobq',
  ##Icnlude this 'maintenance_window_start' => 1,
);

##Use this command "sudo -u www-data php8.2 /var/www/nextcloud/occ maintenance:repair --include-expensive"

##Use this command "sudo rm -rf dietpi-dav_redirect.conf dietpi-nextcloud.conf"