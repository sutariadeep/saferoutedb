#!/usr/bin/perl -w 

# Using the standard perl libraries 
use strict;
use Data::Dumper;
use DBI;

# Opeing either of the files (here .csv) to put to the mysql system
#open(FH, '/root/nathan_scripts/excel/example.csv');
open(FH, '/root/nathan_scripts/excel/test.csv');

# Defining and creating the data structure as per appropriate condition in %stat 
my $stat = {};
my ($line, $year, $state_name, $district_name, $rape, $kidnap, $assault, @crime_stats);
while($line = <FH>){
	if($line =~ m/^DISTRICT-WISE IPC-CRIMES AGAINST WOMEN DURING (\d+)\S+/){
		$year = $1;
		if (not defined $stat->{$year}){
		$stat->{$year} = {};
		}
		next;
	}
	elsif ($line =~ m/^State:,(\w&\w\s\w+),/){
		$state_name = $1;
	        $stat->{$year}->{$state_name} = {};
	}
	elsif ($line =~ m/^State:,(\w+),/){
		$state_name = $1;
	    	$stat->{$year}->{$state_name} = {};
	}
	elsif ($line =~ m/^State:,(\w+\s&\s\w+),/){
		$state_name = $1;
		$stat->{$year}->{$state_name} = {};	    
	}
	elsif ($line =~ m/^State:,(\w+\s\w+),/){
		$state_name = $1;
		$stat->{$year}->{$state_name} = {};
	}
	elsif ($line =~ m/^([A-Z]{2,}),(\d*),(\d*),(\d*)/){
		$district_name = $1;
		if($line =~ m/^TOTAL,/){
                        next;
                }
		$rape = $2;
		$kidnap = $3;
		$assault = $4;
		push @{$stat->{$year}->{$state_name}->{$district_name} },
                {
                        rape => $rape,
                        kinapping => $kidnap,
                        assault => $assault
                };
	}
	elsif ($line =~ m/^([A-Z]{2,}\s[A-Z]{2,}),(\d*)(\d*),(\d*)/){
		$district_name = $1;
		if($line =~ m/^TOTAL,/){
			next;
		}
		$district_name = $1;
		$rape = $2;
		$kidnap = $3;
		$assault = $4;
	        push @{$stat->{$year}->{$state_name}->{$district_name} },
		{
			rape => $rape,
			kinapping => $kidnap,
			assault => $assault 
		};
	}
	elsif ($line =~ m/^([A-Z]{1}.[A-Z]{1}[A-Z]{1}),(\d*)(\d*),(\d*)/){
                $district_name = $1;
                if($line =~ m/^TOTAL,/){
                        next;
                }
                $district_name = $1;
                $rape = $2;
                $kidnap = $3;
                $assault = $4;
                push @{$stat->{$year}->{$state_name}->{$district_name} },
                {
                        rape => $rape,
                        kinapping => $kidnap,
                        assault => $assault
                };
	}
	elsif ($line =~ m/^([A-Z]{1}\/[A-Z]{2,}),(\d*)(\d*),(\d*)/){
                $district_name = $1;
                if($line =~ m/^TOTAL,/){
                        next;
                }
                $district_name = $1;
                $rape = $2;
                $kidnap = $3;
                $assault = $4;
                push @{$stat->{$year}->{$state_name}->{$district_name} },
                {
                        rape => $rape,
                        kinapping => $kidnap,
                        assault => $assault
                };
	}
	elsif ($line =~ m/^([A-Z]{1}.[A-Z]{1}.[A-Z]{2,}.),(\d*)(\d*),(\d*)/){
                $district_name = $1;
                if($line =~ m/^TOTAL,/){
                        next;
                }
                $district_name = $1;
                $rape = $2;
                $kidnap = $3;
                $assault = $4;
                push @{$stat->{$year}->{$state_name}->{$district_name} },
                {
                        rape => $rape,
                        kinapping => $kidnap,
                        assault => $assault
                };
	}
}
#print (Dumper(\$stat));
close FH;	
#exit;

#The database saferoute needs to be created along with the DLL with respective tables(EVENTS and LOCATION) in mysql.It then inserts the data to respective tables (LOCATIOn in this case) 
my $dsn = "DBI:mysql:saferoute";
my $username = "root";
my $password = "";

my %attr = (PrintError=>0,RaiseError=>1);
my $dbh = DBI->connect($dsn,$username,$password,\%attr);
 
while (my ($year, $year_ref) = each(%$stat) ){
	while (my ($state, $state_ref) = each(%$year_ref) ){
		while (my ($city, $city_ref) = each(%$state_ref) ){
			#foreach my $crime_ref (@$city_ref){
			#	while (my ($crime, $crime_stat) = each (%$crime_ref) ){
					my $sql = qq|INSERT INTO LOCATION (COUNTRY, STATE, DISTRICT, CITY, LOCALITY_NAME, PIN_CODE, SAFETY_RANKING) VALUES ('INDIA', '$state', '$city', '$city', 'city', '11111', 1)|;
					$dbh->do($sql);
#					my $scan = qq|SELECT * FROM LOCATION WHERE CITY='$city'|;
#					my $sth = $dbh->prepare($scan);
#					$sth->execute();
#					my @row = $sth->fetchrow_array();
#					print "Row: @row\n";
#					print "Number of rows found:" + $dbh->rows;
			#	}
		#	}
		}
	}
}

$dbh->disconnect();

# Lastly diconnect from the database
#Thank you.
