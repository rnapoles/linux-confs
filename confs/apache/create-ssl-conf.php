<?php

$conf = file_get_contents('base-vhost.conf');

$domains = [
  'app1.example.com',
  'app2.example.com',
  'app3.example.com',
  'app4.example.com',
  'app5.example.com',
  'app6.example.com',
];

$cutNames = [];
foreach($domains as $domain){
  $names = explode('.',$domain);
  $name = $names[0];
  $cutNames[] = $name;
  $newConf = str_replace('www.example.com',$domain,$conf);
  $newConf = str_replace('home',$name,$newConf);
  file_put_contents("vhost/$name.conf",$newConf);
}

$names = implode(',',$cutNames);

echo "mkdir -p /var/www/{$names}\n";
