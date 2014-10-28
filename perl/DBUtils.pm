package DBUtils;

require Exporter;
@ISA =  qw(Exporter);

@EXPORT = @EXPORT_OK = qw(
    prepare_stat 
    exec_sql 
    exec_stat 
    query_data
    query_stat
    query_one 
    query_value 
    query_json_data
    db_save_data
);

use strict;
use lib "..", "../..";
use Defs;
use DBI;
use Devel::StackTrace;

use Singleton;
use Data::Dumper;
use Log;
use Log::Log4perl;
Log::Log4perl->wrapper_register(__PACKAGE__);

sub clean_sql {
    my ( $sql ) = @_;
    (WARN "empty SQL: $sql" and return '') if (not $sql or $sql =~ /^\s*$/ );
    $sql =~ s/^\s+//;
    $sql =~ s/\s+$//;
    $sql =~ s/\t/    /g;
    return "\n\n$sql\n";
}

sub prepare_stat {
    shift if (@_ > 0 and ref($_[0]));
    my ( $sql ) = @_;
    DEBUG '[', caller, "] prepare SQL: $sql";
    return get_dbh()->prepare($sql);
}

# sample: exec_sql(qq[INSERT/UPDATE...], 1, 2, 3)
# return: dbi statement
sub exec_sql {
    shift if (@_ > 0 and ref($_[0]));
    my ( $sql, @data ) = @_;
    my @sql_list = split(';', $sql);
    my $sth;

    for my $sql (@sql_list) {
        $sql ||= '';
        $sql = clean_sql($sql);
        next if $sql eq '';

        DEBUG '[', caller, "] SQL $sql \nwith data: ", list_to_str(\@data);
        $sth = get_dbh()->prepare($sql);
        my $result = $sth->execute(@data);

        if ($result) {
            DEBUG "last inserted id: ", $sth->{mysql_insertid} if $sql =~ /insert /i;
        }
        DEBUG "-"x60;
    }

    return $sth;
}

# sample: $sth=prepare_stat(SQL); exec_stat($sth, 1, 2, 3)
# return: dbi statement
sub exec_stat {
    my ( $sth, @data ) = @_;

    DEBUG '[', caller, "] SQL with data: ", list_to_str(\@data);
    my $result = $sth->execute(@data);

    if ($result) {
        DEBUG "last inserted id: ", $sth->{mysql_insertid};
    }
    else {
        ERROR "execute statement error: ", $sth->errstr;
    }
    DEBUG "-"x60;
    return $sth;
}

# sample: $sth=prepare_stat(SQL); $rows=$query_stat($sth, 1, 2, 3);
# return: multiple rows of query result, list reference of hashrefs
sub query_stat {
    shift if (@_ > 0 and ref($_[0]));
    my ( $sql, @data ) = @_;

    $sql = clean_sql($sql);
    return undef if $sql eq '';

    DEBUG '[', caller, "] SQL $sql \nwith data: ", list_to_str(\@data);
    my $sth = get_dbh()->prepare($sql);
    $sth->execute(@data) or ERROR "execute SQL: $sql, error: ", $sth->errstr;

    DEBUG "last inserted id: ", $sth->{mysql_insertid} if ( $sql =~ /INSERT/i );
    DEBUG "result count: ", $sth->rows;
    DEBUG "-"x60;
    return $sth;
}

# sample: $rows = query_data(SQL, 1, 2, 3);
# return: multiple rows of query result, list reference of hashrefs
sub query_data {
    shift if (@_ > 0 and ref($_[0]));
    my ( $sql, @data ) = @_;

    $sql = clean_sql($sql);
    return [] if $sql eq '';

    DEBUG '[', caller, "] SQL $sql \nwith data: ", list_to_str(\@data);
    my $sth = get_dbh()->prepare($sql);
    $sth->execute(@data) or ERROR "execute SQL: $sql, error: ", $sth->errstr;

    my @result = ();
    while ( my $row = $sth->fetchrow_hashref() ) {
        push @result, $row;
    }

    DEBUG "result count: ", scalar @result;
    DEBUG "-"x60;
    return \@result;
}

# sample: $row = query_one(SQL, 1, 2, 3);
# return: first row of query result, a hashref
sub query_one {
    shift if (@_ > 0 and ref($_[0]));
    my ( $sql, @data ) = @_;

    $sql = clean_sql($sql);
    return {} if $sql eq '';

    DEBUG '[', caller, "] SQL $sql \nwith data: ", list_to_str(\@data);
    my $sth = get_dbh()->prepare($sql);
    $sth->execute(@data) or ERROR "execute SQL: $sql, error: ", $sth->errstr;

    my $result = $sth->fetchrow_hashref();
    #DEBUG "result: ", Dumper($result);
    DEBUG "-"x60;
    return $result;
}

# sample: $row = query_value(SQL, 1, 2, 3);
# return: first field of first row of query result, a scalar value
sub query_value {
    shift if (@_ > 0 and ref($_[0]));
    my ( $sql, @data ) = @_;

    $sql = clean_sql($sql);
    return undef if $sql eq '';

    DEBUG '[', caller, "] SQL $sql \nwith data: ", list_to_str(\@data);
    my $sth = get_dbh()->prepare($sql);
    $sth->execute(@data) or ERROR "execute SQL: $sql, error: ", $sth->errstr;

    my @ary = $sth->fetchrow_array;
    my $result = (scalar @ary > 0) ? $ary[0] : undef;

    DEBUG "Result: $result "."-"x40;
    return $result;
}

# sample: $json = query_json_data(SQL, 1, 2, 3)
# return: json format of query_data result
sub query_json_data {
    shift if (@_ > 0 and ref($_[0]));
    my ( $sql, @data ) = @_;
    my $result = query_data( $sql, @data );

    return JSON::to_json( $result );
}

sub print_stack_trace {
    my $trace = Devel::StackTrace->new;
    return $trace->as_string; # like carp
}

# a generic method to save a hashref record to database
# and return key field
#
# input: a data row in hashref, save it to db
# if key_field has value, then use update, otherwise use insert
#
# options: the key_field must be an auto-increasement field
#
# sample;
#   # insert a new data
#   my $row = {};
#   $row->{'strName'} = 'abc';
#   $row->{'strValue'} = 123;
#   my $id = db_save_data('a_table', $row, id=>{'intID'});

#   $row = query_one(SQL, $id);
#
#   # clone this row
#   $row->{"intID"} = undef; 
#   db_save_data("a_table", $row, {id=>"intID"});
#
#   # update this row
#   $row->{"some_field"} = 123; 
#   db_save_data("a_table", $row, {id=>"intID"});
#
sub db_save_data {
    my ($tablename, $data, $extra) = @_;
    my $key_field  = $extra->{'key'} || '';

    my @fields = keys %$data;
    # filter out the key field from field list
    if ($key_field) {
        @fields = grep { $_ ne $key_field } @fields;
    }

    # bind params for SQL
    my @values = @$data{@fields};

    if ($key_field and $data->{$key_field}) {
        # update data
        my $field_placeholders = join(', ', map {"$_ = ?"} @fields);

        my $SQL = qq[
        UPDATE $tablename
        SET $field_placeholders
        WHERE $key_field = ?
        ];

        push @values, $data->{$key_field};

        DEBUG '[', caller, "] saving data", Dumper($data), "\nby $SQL \nwith data: ", list_to_str(\@values);
        if ($extra->{'sql_only'}) {
            return get_plain_sql($SQL, @values) . ";\n";
        }
        else {
            my $sth = get_dbh()->prepare($SQL);
            $sth->execute(@values) or ERROR $sth->errstr;
            return $key_field ? $data->{$key_field} : 0;
        }
    }
    else {
        # insert data

        my $field_list = join(', ', @fields);
        my $value_placeholders = '?,'x@values;
        chop($value_placeholders);
        my $SQL = qq[
            INSERT INTO $tablename ( $field_list ) 
            VALUES ( $value_placeholders )
        ];

        DEBUG '[', caller, "] saving data", Dumper($data), "\nby $SQL \nwith data: ", list_to_str(\@values);

        if ($extra->{'sql_only'}) {
            return get_plain_sql($SQL, @values) . ";\n";
        }
            else {
            my $sth = get_dbh()->prepare($SQL);
            $sth->execute(@values) or ERROR $sth->errstr;

            my $new_id = $sth->{mysql_insertid};
            return $new_id;
        }
    }
}

sub get_plain_sql {
    my ($sql, @params) = @_;

    my @qmarks = $sql =~ /(\?)/g;
    if (scalar @qmarks != scalar @params) {
        ERROR "numbers of question marks and params are inconsequent"; 
        return undef;
    }
    else {
        for my $p (@params) {
            $p =~ s/'/\\'/g;
            $p =~ s/\?/ /g;
            $sql =~ s/\?/'$p'/;
        }
        return $sql;
    }
}

sub list_to_str {
    my ($data) = @_;
    no warnings 'uninitialized';
    my $result = join(', ', map { qq['$_'] } @$data);
    return "($result)";
}

1;
# vim: set et sw=4 ts=4:
