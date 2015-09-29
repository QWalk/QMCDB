#! /usr/bin/perl -p
#
if (/#!\s*\/bin\/bash\b/)  { 
    s/\/bash/\/csh -f/; 
}

# this is a custom conversion that properly captures the intent of the 
# openrc script
if (/\[\s+\-z\s+"\$([A-Z0-9_]+)"\s+]; then unset/) {
    $_ = 'if ( "$' . $1 . '" == "" ) unsentenv ' . $1
}

if (/if \[ /, /fi/) {
    s/\[\s*\-z \"\$(\w+)" \]/[ ! \$\?\1 ]/;
    s/\[\s*\-n \"\$(\w+)" \]/[ \$\?\1 ]/;
    s/\;?elfi \[ /else if \(/;
    s/if \[ /if \(/; 
    s/\ ]/\)/;
    if (/;\s*fi\b/) {
        s/;\s*then\b//;
        s/;\s*fi\b//;
    }
    else {
        s/\; then?(\s*\\)?/ then/;
    }
}

s/\bfi\b/endif/;

if (/export\b/) { 
    s/export\b/setenv/;
    s/=/ /;
}

if (/\w+=\S/) {
    s/(\w+)=(\S)/set \1 = \2/;
}

s/unset ([A-Z0-9_]+)/unsetenv \1/;

s/^/# / if (/password/i);

