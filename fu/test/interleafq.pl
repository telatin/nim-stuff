#!/usr/bin/env perl
# ABSTRACT - interleave and deinterleave FASTQ paired reads

use 5.012;
use warnings;
use Getopt::Long;
use Pod::Usage;
use File::Basename;
use FindBin qw($RealBin);
use lib "$RealBin/lib";
use FASTX::Reader;
use Term::ANSIColor qw(:constants);
use IO::Compress::Gzip qw(gzip $GzipError);

my $VERSION = '1.1.0';
my $AUTHOR  = 'Andrea Telatin';
my $PROGRAM = basename($0);

my ($opt_help, $opt_version, $opt_verbose, $opt_dont_check, $opt_strip_comments, $opt_force_interleave, $opt_gzip);
my ($opt_outbase, $opt_out1, $opt_out2);


my $_opt = GetOptions(
    'h|help'                => \$opt_help,
    'version'               => \$opt_version,
    'i|force-interleave'    => \$opt_force_interleave,
    'v|verbose'             => \$opt_verbose,
    'o|output-basename=s'   => \$opt_outbase,
    '1|first-pair=s'        => \$opt_out1,
    '2|second-pair=s'       => \$opt_out2,
    'r|relaxed'             => \$opt_dont_check,
    's|strip-comments'      => \$opt_strip_comments,
    'z|gzip-output'         => \$opt_gzip,
);

sub vprint($);
my ($file1, $file2) = @ARGV;

$opt_version && version();

if ($opt_force_interleave and defined $file1) {
    $file2 = $file1;
    $file2 =~s/_R1/_R2/;
    if ($file1 eq $file2) {
        $file2 =~s/_1\./_2\./;
    }
    if ($file1 eq $file2) {
        die " FATAL ERROR:\n Unable to identify second pair-end file for <$file1>.\n";
    } else {
        vprint("Force interleave: assuming R2 is <$file2>.");
    }

}


my $c = 0;
if (defined $file1 and not defined $file2) {
    # deinterleave
    if (not -e "$file1") {
        die " FATAL ERROR:\n Interleaved file <$file1> was not found.\n";
    }
    if ( (not defined $opt_outbase) and ( (not defined $opt_out1) or (not defined $opt_out2))) {
        die " FATAL ERROR:\n When deinterleaving, specify either [-o] or [-1 and -2]. See --help.\n";
    } elsif (defined $opt_out1 and ($opt_out1 eq $opt_out2)) {
        die " FATAL ERROR:\n Same output specified for -1 and -2.";
    } elsif (defined $opt_outbase) {
        $opt_out1 = "${opt_outbase}_R1.fastq";
        $opt_out2 = "${opt_outbase}_R2.fastq";
        if ($opt_gzip) {
            $opt_out1 .= '.gz';
            $opt_out2 .= '.gz';
        }
        vprint("Output files: $opt_out1, $opt_out2");
    }


    if ($opt_out1 =~/\.gz$/ or $opt_out2 =~/\.gz$/) {
        if ($opt_out1 =~/\.gz$/ and $opt_out2 =~/\.gz$/) {
            $opt_gzip = 1;
        } else {
            die "FATAL ERROR:\n Please request gzipped output for BOTH files: $opt_out1, $opt_out2\n";
        }
    }

    my ($O1, $O2);

    if ($opt_gzip) {
        $O1 = new IO::Compress::Gzip "$opt_out1" or die "FATAL ERROR:\ngzip failed for $opt_out1: $GzipError\n";
        $O2 = new IO::Compress::Gzip "$opt_out2" or die "FATAL ERROR:\ngzip failed for $opt_out2: $GzipError\n";
    } else {
        open ($O1, '>', "$opt_out1") || die " FATAL ERROR:\n Unable to write R1 to <$opt_out1>.\n";
        open ($O2, '>', "$opt_out2") || die " FATAL ERROR:\n Unable to write R2 to <$opt_out2>.\n";
    }

    my $FQ = FASTX::Reader->new({ filename => "$file1" });
    while (my $R1 = $FQ->getFastqRead() ) {
        my $R2 = $FQ->getFastqRead() || die "Missing R2 read: expecting even sequences\n";
        $c++;
        if (not defined $opt_dont_check) {
            my ($prefix_1) = split '/', $R1->{name};
            my ($prefix_2) = split '/', $R2->{name};
            die " FATAL ERROR:\n R1 name is <$R1->{name}> while R2 <$R2->{name}> at read $c. Try disabling check with --relaxed.\n"
                if ($prefix_1 ne $prefix_2);

            die " FATAL ERROR:\n Quality/Sequence length mismatch at read R1 $c ($R1->{name})\n"
                if (length($R1->{seq}) ne length($R1->{qual}));

            die " FATAL ERROR:\n Quality/Sequence length mismatch at read R2 $c ($R2->{name})\n"
                if (length($R2->{seq}) ne length($R2->{qual}));
        }


        my $c1 = '';
        my $c2 = '';
        if (not defined $opt_strip_comments) {
            $c1 = ' ' . $R1->{comment} if (defined $R1->{comment});
            $c2 = ' ' . $R2->{comment} if (defined $R2->{comment});;
        }

        print {$O1} '@', $R1->{name}, $c1, "\n",
            $R1->{seq}, "\n+\n",
            $R1->{qual}, "\n";

        print {$O2} '@', $R2->{name}, $c2, "\n",
            $R2->{seq}, "\n+\n",
            $R2->{qual},"\n";
    }

    if ($opt_gzip) {
        $O1->close();
        $O2->close();
    }



} elsif (defined $file2) {
    #interleave

    if ($opt_gzip) {
        say STDERR "WARNING: -z is unsupported while interleaving (pipe to gzip -c)";
        $opt_gzip = 0;
    }

    if (not -e "$file1") {
        die " FATAL ERROR:\n R1 file <$file1> was not found.\n";
    }
    if (not -e "$file2") {
        die " FATAL ERROR:\n R2 file <$file2> was not found.\n";
    }
    my $F1 = FASTX::Reader->new({ filename => "$file1" });
    my $F2 = FASTX::Reader->new({ filename => "$file2" });


    while (my $R1 = $F1->getFastqRead() ) {
        my $R2 = $F2->getFastqRead() || die "FATAL ERROR:\n Second file ended unexpectedly at $c reads\n";
        $c++;
        if (not defined $opt_dont_check) {
            my ($prefix_1) = split '/', $R1->{name};
            my ($prefix_2) = split '/', $R2->{name};
            die " FATAL ERROR:\n R1 name is <$R1->{name}> while R2 <$R2->{name}> at read $c. Try disabling check with --relaxed.\n"
                if ($prefix_1 ne $prefix_2);
            die " FATAL ERROR:\n Quality/Sequence length mismatch at read R1 $c ($R1->{name})\n"
                if (length($R1->{seq}) ne length($R1->{qual}));

            die " FATAL ERROR:\n Quality/Sequence length mismatch at read R2 $c ($R2->{name})\n"
                if (length($R2->{seq}) ne length($R2->{qual}));
        }

        my $c1 = '';
        my $c2 = '';
        if (not defined $opt_strip_comments) {
            $c1 = ' ' . $R1->{comment} if (defined $R1->{comment});
            $c2 = ' ' . $R2->{comment} if (defined $R2->{comment});;
        }

        print '@', $R1->{name}, $c1, "\n",
            $R1->{seq}, "\n+\n", $R1->{qual} , "\n",
            '@', $R2->{name}, $c2, "\n",
            $R2->{seq}, "\n+\n", $R2->{qual} , "\n";
    }
} else {
   pod2usage({-exitval => 0, -verbose => 2}) if $opt_help;
    die usage() unless ($file1);
}

vprint("$c sequences parsed");
sub version {
    # Display version if needed
    say STDERR BOLD, $PROGRAM, RESET, " $VERSION ($AUTHOR)";
    say STDERR GREEN, "[using FASTX::Reader ", $FASTX::Reader::VERSION ,"]", RESET;
    exit 0;
}

sub usage {
    # Short usage string in case of errors
    die
"USAGE
To interleave:
  $PROGRAM file_R1.fq file_R2.fq > interleaved_file.fq

To deinterleave:
  $PROGRAM -o output_basename file.fq

--help for more help\n";
}

sub vprint($) {
    return 0 if not defined $opt_verbose;
    say STDERR "$_[0]";
}
__END__

=head1 NAME

B<interleafq> - interleave and deinterleave FASTQ paired reads.

=head1 SYNOPSIS

To interleave

  interleafq reads_R1.fq reads_R2.fq > reads_interleaved.fq

To deinterleave:

  interleafq -o prefix reads_interleaved.fq

=head1 DESCRIPTION

B<interleafq> can read FASTQ file, gzipped or not, and interleave or deinterleave them.
When receiving two files, it will I<interleave> them, if receiving a single file it will I<deinterleave> it.
It is designed to perform some internal checks to minimize the occurrences of malformed output, if compared with popular Bash alternatives
(like L<https://gist.github.com/nathanhaigh/3521724>).

=head1 PARAMETERS

=over 4

=item B<-o>, B<--output-prefix> STRING

Basename for the output file when deinterleaving. Will produce by default C<{prefix}_R1.fastq> and C<{prefix}_R2.fastq>.

=item B<-1>, B<--first-pair> FILE

Filename for the first pair produced when deinterleaving.
Alternative to C<-o>, if the specified output filename ends with '.gz' will print a compressed file.

=item B<-2>, B<--second-pair> FILE

Filename for the second pair produced when deinterleaving.
Alternative to C<-o>, if the specified output filename ends with '.gz' will print a compressed file.

=item B<-s>, B<--strip-comments>

Will remove comments from the sequence headers (I<i. e.> any string after the first space character in the read name line).

=item B<-r>, B<--relaxed>

Will B<not> check for inconsistencies in read names and sequence/quality length. The read names should be equal until the first '/'.

=item B<-i>, B<--force-interleave>

When supplying only the first pair-end file it will set interleave mode, looking for a second pair-end file (replacing _R1 with _R2)

=item B<--version>

Display version number and exit.

=item B<-v>, B<--verbose>

Display additional information (total printed sequences at the end, useful for truncated files).

=item B<-h>, B<--help>

Display this help message.


=back

=head1 BUGS

Please open an issue in GitHub L<https://github.com/quadram-institute-bioscience/interleafq>.

The software is not actively maintained, but being open source it's possible to contribute to it.

=head1 AUTHOR

Andrea Telatin <andrea@telatin.com>

=head1 COPYRIGHT

Copyright (C) 2020 Andrea Telatin

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
