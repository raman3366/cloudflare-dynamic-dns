# cloudflare-dynamic-dns
This script will auto update ip address of all domains in Cloudfare that are hosted in Linux web servers.

Make sure you use proper API credentials from Cloudflare

Also the site-enabled directory under Apache2 or Nginx should have all conf files of hosted websites and the file name should be like the following:

www.website1.com.conf
www.website2.org.conf
subdomain.website3.conf

This script will only evaluate top level domains, i.e., only conf files of top level "www" domains will be stripped into naked domain names and the A records of naked domains will be updated.
