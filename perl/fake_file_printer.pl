#!/usr/bin/perl
=head1 NAME

fake_file_printer - listen on LPD, Centronics or JetDirect ports.  Dump any files sent there.

=cut
=head1 SYNOPSYS

temp.pl

=cut
=head1 DESCRIPTION

 Title       : Fake file printer
 Project     : System Tools                                      
 Author      : waveclaw
 Program     : fake_file_printer
 File        : fake_file_printer.pl
 Created     : 29-APR-2003
 Description : based on http://aplawrence.com/MacOSX/macosxcupstofile.html

=cut
=head1 RELEASE LICENSE

This script is available under the GNU release license,         
else copyright  2001 waveclaw.
For internal use only, keep out of young children.                                                  
                                                                         
Copyrights to their respective owners.                           
                                                                         
=cut
=head1 CONTACTS 

waveclaw@waveclaw.net

=cut
=head1 RELEVANT DOCUMENTS
 
  Name                           Comment                              
  ---------------------------------------------------------------------
  man Perl                       primary Perl 5 reference             

=cut
=head1 KNOWN BUGS

Many

=cut
use IO::Socket::INET;
#my $jetdir=9001; 
#my $centronics=3001; 
#my $lpd=515;
my $myport=12000; 
my $mysocket=IO::Socket::INET->new(LocalPort => $myport,Type=>SOCK_STREAM,Reuse=>1,Listen=>1) or die "cannot Open socket at port $myport, error was $!\n";
my $ext="";
my $count = 0;
while ($INPUT=$mysocket->accept()) {
  my $file = "/var/tmp/printout.prn$ext";
  unlink($file);
  open(OUTPUT,">>$file") or print "Cannot write file $file, error was $!\n";
#  print J "New job...\n";
  while (<$INPUT>) {
        print OUTPUT "$_";
  }
  close OUTPUT;
  $ext = ".$count";
  $count += 1;
  close $INPUT;
}
