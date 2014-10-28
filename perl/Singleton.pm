package Singleton;

require Exporter;
@ISA =  qw(Exporter);

@EXPORT = @EXPORT_OK = qw(
    set_dbh get_dbh get_cache get_cgi start_transaction end_transaction
);

use strict;
use warnings;
use lib '..';

use DBI;
use Defs;
use MCache;
use CGI;
use Log;

my $dbh;
my $trans_dbh;
my $is_in_transaction = 0;
my $cache;
my $cgi;

sub start_transaction {
    $is_in_transaction = 1;
}

sub end_transaction {
    $is_in_transaction = 0;
}

sub connect_db {
    my ($option) = @_;
    my $dsn = ($option and $option eq 'reporting' and $Defs::DB_DSN_REPORTING)
        ? $Defs::DB_DSN_REPORTING
        : $Defs::DB_DSN;
        
    my $connection_option = {
        AutoCommit => !$is_in_transaction
    };

    DEBUG '[', caller, "] connect DB $dsn";
    # TODO: use connection pool to have better performance
    my $db = DBI->connect($dsn, $Defs::DB_USER, $Defs::DB_PASSWD, $connection_option);
    ERROR "DB Connection error" if (not $db);

    return (! defined $db) ? undef : $db;
}

sub disconnect_db {
    if($dbh) {
        $dbh->disconnect;
    }
    if($trans_dbh) {
        $trans_dbh->disconnect;
    }
}

sub reset_dbh {
    my ($option) = @_;
    $dbh = connect_db($option);
    return $dbh;
}

sub get_dbh {
    if ($is_in_transaction) {
        if (not $trans_dbh) {
            $trans_dbh = connect_db();
            DEBUG "create db transaction connection singleton";
        }
        return $trans_dbh;
    } else {
        if (not $dbh) {
            $dbh = connect_db();
            DEBUG "create db connection singleton";
        }
        return $dbh;
    }
}

sub get_cache {
    if (not $cache) {
        $cache = new MCache();
        DEBUG "create cache singleton";
    }
    return $cache;
}

sub get_cgi {
    if (not $cgi) {
        $cgi = new CGI();
        DEBUG "create cgi singleton";
    }
    return $cgi;
}

1;
