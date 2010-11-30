# crunk_cf
I have a nasty legacy system I have to deal with where I need to switch a load of configuration files at once and potentially switch them back quickly.  It would be nice to use an existing, non-crunk configuration management tool like chef but I want to look at these fucking legacy boxes for a maximum of 5 seconds.  All this guy does is swap out files if named in the crunk_cf convention.

    USAGE: crunk_cf --action run --version version_name --base-dir base_directory

    EXAMPLE:  crunk_cf --action run --version 1 --base-dir /etc
              would find files named like:  /etc/apache2/httpd.conf.1.crunk_cf
              and copy them to:             /etc/apache2/httpd.conf 
              and, if /etc/apache2/httpd.conf exists, backup the original to something like:  /etc/apache2/httpd.conf.backup-789321321.crunk_cf
              if the --named-run-id is passed with a value, the originals will be backed up with a run-id of whatever you pass in.  
              For example, if the --named-run-id was "dogface", the backup files would be named like:  httpd.conf.dogface.crunk_cf, allowing you to rollback to the originals you just 
              replaced by doing:  crunk_cf --action run --version dogface --base-dir /etc 

This will probably not be particularly useful to anyone!  Bye :)
