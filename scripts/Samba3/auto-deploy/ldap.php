<?PHP
/*
 echo  sha1("administrator");

 
 '1', 'admin', 'b3aca92c793ee0e9b1a9b0a5f5fc044e05140df3', 'Ginisleisy', 'Morales', 'gmorales@hlg.uci.cu', '1', '1', '1', '2010-11-29 08:49:10', 'es', NULL, '2010-11-18 11:02:12', '2010-11-29 08:49:10', 'User', NULL



CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(30) NOT NULL default '',
  `hashed_password` varchar(40) NOT NULL default '',
  `firstname` varchar(30) NOT NULL default '',
  `lastname` varchar(30) NOT NULL default '',
  `mail` varchar(60) NOT NULL default '',
  `mail_notification` tinyint(1) NOT NULL default '1',
  `admin` tinyint(1) NOT NULL default '0',
  `status` int(11) NOT NULL default '1',
  `last_login_on` datetime default NULL,
  `language` varchar(5) default '',
  `auth_source_id` int(11) default NULL,
  `created_on` datetime default NULL,
  `updated_on` datetime default NULL,
  `type` varchar(255) default NULL,
  `identity_url` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_users_on_id_and_type` (`id`,`type`),
  KEY `index_users_on_auth_source_id` (`auth_source_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1$$

INSERT INTO `bitnami_redmine`.`users`
(`id`,
`login`,
`hashed_password`,
`firstname`,
`lastname`,
`mail`,
`mail_notification`,
`admin`,
`status`,
`last_login_on`,
`language`,
`auth_source_id`,
`created_on`,
`updated_on`,
`type`,
`identity_url`)
VALUES
(
{id: INT},
{login: VARCHAR},
{hashed_password: VARCHAR},
{firstname: VARCHAR},
{lastname: VARCHAR},
{mail: VARCHAR},
{mail_notification: TINYINT},
{admin: TINYINT},
{status: INT},
{last_login_on: DATETIME},
{language: VARCHAR},
{auth_source_id: INT},
{created_on: DATETIME},
{updated_on: DATETIME},
{type: VARCHAR},
{identity_url: VARCHAR}
);


*/
$ldap_url = '100.0.0.8';
$ldap_domain = 'samdom.example.com';
$ldap_dn = "dc=samdom,dc=example,dc=com";


$ds = ldap_connect( $ldap_url );
ldap_set_option($ds, LDAP_OPT_PROTOCOL_VERSION, 3);
ldap_set_option($ds, LDAP_OPT_REFERRALS, 0);

$username = "administrator";
$password = "p@55w0rd";

// now try a real login
$login = ldap_bind($ds,"$username@$ldap_domain", $password );

if($login){
   echo "- Logged In $ldap_url Successfully<br/><br/>";
    try{
          $attributes = array("displayname","samaccountname","sn","givenname");
          $filter = "(&(objectCategory=person)(sAMAccountName=*))";

          $result = ldap_search($ds, $ldap_dn, $filter, $attributes);

          $entries = ldap_get_entries($ds, $result);

          if($entries["count"] > 0){
              $ignore = array("administrator","administrador","dns","krbtgt","guest");
              $cant = $entries["count"] -1;
              
              for($i=0;$i<=$cant;$i++){
                $user = strtolower($entries[$i]['samaccountname'][0]);
                if(in_array($user,$ignore)) continue;  
                $pass = sha1($user);
                $gn = $entries[$i]['givenname'][0];
                $sn = $entries[$i]['sn'][0];
                $mail = $user.'@'.$ldap_domain;
            
$sql1 = <<<FIN
INSERT INTO `bitnami_redmine`.`users`
(`id`,
`login`,
`hashed_password`,
`firstname`,
`lastname`,
`mail`,
`mail_notification`,
`admin`,
`status`,
`last_login_on`,
`language`,
`auth_source_id`,
`created_on`,
`updated_on`,
`type`,
`identity_url`)
VALUES
(
NULL,
"$user",
"$pass",
"$gn",
"$sn",
"$mail",
"1",
"0",
"2",
NULL,
"es",
NULL,
NULL,
NULL,
"User",
NULL
);
FIN;

  echo $sql1 . '<br>' ;
              
            }
          }

    } catch(Exception $e) {
      ldap_unbind($ds);
      return;
    }
ldap_unbind($ds);
echo '<br/><br/>- Logged Out';
}
?>