# STMVALIDATOR
# Author: Jon Fiscus, Jerome Ajot
#
# This software was developed at the National Institute of Standards and Technology by 
# employees of the Federal Government in the course of their official duties. Pursuant
# to title 17 Section 105 of the United States Code this software is not subject to
# copyright protection and is in the public domain. RTTMVALIDATOR is an experimental system.
# NIST assumes no responsibility whatsoever for its use by other parties, and makes no
# guarantees, expressed or implied, about its quality, reliability, or any other
# characteristic. We would appreciate acknowledgement if the software is used.
#
# THIS SOFTWARE IS PROVIDED "AS IS."  With regard to this software, NIST MAKES NO EXPRESS
# OR IMPLIED WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING MERCHANTABILITY,
# OR FITNESS FOR A PARTICULAR PURPOSE.

package STMList;
use strict;
use STMRecord;
 
sub new {
    my $class = shift;
    my $file = shift;
    my $self = { FILE => $file,
		 DATA => {},
		 CATEGORY => {},
		 LABEL => {},		 
		 };
    bless $self;
    $self->loadFile($file);
    return $self;
}

sub dump{
    my ($self) = @_;
    my ($key);

    print "Dump of STM File\n";
    print "   File: $self->{FILE}\n";
    print "   Categories:\n";
    foreach my $cat(sort (keys %{ $self->{CATEGORY} })){
	print "      $cat ->";
	foreach $key(sort(keys %{ $self->{CATEGORY}{$cat} })){
	    print " $key='$self->{CATEGORY}{$cat}{$key}'";
	}
	print "\n";
    }
    print "   Labels:\n";
    foreach my $cat(sort (keys %{ $self->{LABEL} })){
	print "      $cat ->";
	foreach $key(sort(keys %{ $self->{LABEL}{$cat} })){
	    print " $key='$self->{LABEL}{$cat}{$key}'";
	}	
	print "\n";
    }
    print "   Records:\n";
    foreach my $file(sort keys  %{ $self->{DATA} }){
	foreach my $chan(sort keys  %{ $self->{DATA}{$file} }){
	    for (my $i=0; $i<@{ $self->{DATA}{$file}{$chan} }; $i++){
		print "      $file $chan $i ";
		print $self->{DATA}{$file}{$chan}[$i]->toString();
		print "\n";
	    }
	}
    }
}

sub validateEnglishText{
    my ($self, $text, $verbosity) = @_;
    my $err = 0;
    foreach my $token (split(/\s+/, $text)){
	if ($token =~ /^ignore_time_segment_in_scoring$/i){
	    ;
	} elsif ($token =~ /^([a-z]*-)*[a-z]+$/i){  ## hyphenated words and non-hyphenated words
	    ;
	} elsif ($token =~ /^\(([a-z]*-)*[a-z]+\)$/i){  ## optioanlly deletable hyphenated words and non-hyphenated words
	    ;
	} elsif ($token =~ /^[a-z]+\.('s|s)*$/i){       ## Acronyms, plural and posessives
	    ;
	} elsif ($token =~ /^\([a-z]+\.('s|s)*\)$/i){       ## optDel Acronyms, plural and posessives
	    ;
	} elsif ($token =~ /^\([a-z]+-\)$/i){           ## optDel fragments
	    ;
	} elsif ($token =~ /^([a-z]*-)*[a-z]+('(d|s|t|re|ll|m|ve|))*$/i){  ## contractions
	    ;
	} elsif ($token =~ /^o'\S+$/i){               ## Special contractions
	    ;
	} elsif ($token =~ /^\(%hesitation\)$/i){              ## hesitations
	    ;
	} else {
	    print "   Unrecognized token English -$token-\n" if ($verbosity > 1);
	    $err ++;
	}
    }
    ($err == 0);
}

sub validateNonEnglishText{
    my ($self, $text, $language, $verbosity) = @_;
    my $err = 0;
    my $punct = "\!\@\#\$\%\^\&\*\(\)\`\~\_\+\=\{\[\}\]\|\\\<\,\>\.\?\/\-";
    foreach my $token (split(/\s+/, $text)){
	foreach $token (split()){
	    if ($token =~ /^ignore_time_segment_in_scoring$/i){
		;
	    } elsif ($token =~ /^[^$punct]+$/i){  ## words
		;
	    } elsif ($token =~ /^\([^$punct]+\)$/i){  ## words
		;
	    } elsif ($token =~ /^\(%hesitation\)$/i){              ## hesitations
		;
	    } else {
		print "   Unrecognized token $language -$token-\n" if ($verbosity > 1);
		$err ++;
	    }
	}
    }
    ($err == 0);
}

sub validate{
    my ($self, $language, $verbosity) = @_;

    print "Validating STM file ".$self->{FILE}."\n" if ($verbosity > 1);
    $language = lc($language);
    my $ret = 1;
    my $r;
    foreach my $file(sort keys  %{ $self->{DATA} }){
	foreach my $chan(sort keys  %{ $self->{DATA}{$file} }){
	    for (my $i=0; $i<@{ $self->{DATA}{$file}{$chan} }; $i++){
		if ($language eq "english"){
		    $r = $self->validateEnglishText(
			    $self->{DATA}{$file}{$chan}[$i]->getText(),
						      $verbosity);
		} else {
		    $r = 
			$self->validateNonEnglishText($self->{DATA}{$file}{$chan}[$i]->getText(),
						      $language,
						      $verbosity);
		}
		$ret = $r if (! $r);
	    }
	}
    }
    $ret;
}

sub passFailValidate{
    my ($file, $language, $verbosity) = @_;
    my $stm = new STMList($file);
    if ($stm->validate($language, $verbosity)){
	print "Validated\n" if ($verbosity > 0);
	exit 0;
    } else {
	print "Failed Validation\n" if ($verbosity > 0);
	exit 1;
    }
}

sub loadFile{
    my ($self) = @_;
    open (STM, $self->{FILE}) || die "Unable to open for read STM file '$self->{FILE}'";
    while (<STM>){
#	print;
	chomp;
	
	if ($_ =~ /;;\s+CATEGORY\s+\"([^"]*)\"\s+\"([^"]*)\"\s+\"([^"]*)\"/){
	    my $ht = { ID => $1,
		       COLUMN => $2,
		       DESC => $3
		       };
	    $self->{CATEGORY}{$1} = $ht;
	} elsif ($_ =~ /;;\s+LABEL\s+\"([^"]*)\"\s+\"([^"]*)\"\s+\"([^"]*)\"/){
	    my $ht = { ID => $1,
		       COLUMN => $2,
		       DESC => $3
		       };
	    $self->{LABEL}{$1} = $ht;
	} else {
	    s/;;.*$//;
	    s/^\s*//;
	    next if ($_ =~ /^$/);
	    my ($file, $chan, $spk, $bt, $et, $labels, $text) = split(/\s+/,$_,7);
	    if ($labels !~ /^<.*>$/){
		$text = "$labels $text";
		$labels = "";
	    }
	    $text = "" if (! defined($text));
	    push (@{ $self->{DATA}{$file}{$chan} }, 
		  new STMRecord($file, $chan, $spk, $bt, $et, $labels, $text));
	}	
    }   
}
1;