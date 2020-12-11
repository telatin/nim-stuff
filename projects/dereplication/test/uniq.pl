#!/usr/bin/env perl

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;
use BioX::Seq::Stream;
use Data::Dumper;
use Digest::MD5 qw( md5_hex );

my $EXE = basename($0);
my $VERSION = '1.0.0';
my $AUTHOR = 'Andrea Telatin';
my $DESC = 'Print unique sequence with USEARCH labels';

my $opt_def_qual;
my $opt_line_length = $ENV{'FU_LINE_LENGTH'} // 80;
my( @Options,
  $opt_sep_size, 			# Print cluster size as a comment and not in the sequence name (;size=NN;)
	$opt_min_size, 			# Print only clusters of size >= N
	$opt_no_label,			# Do not print cluster size
  $opt_keep_name, 		# Use the name of the first sequence as cluster Name
	$opt_prefix, 				# Default cluster name (prefix, separator, progressiveID)
	$opt_separator,			# Default cluster name separator (default: ".")
	$opt_fasta, 				# IGNORED
	$opt_fastq, 				# IGNORED
	$opt_strip_comm, 		# IGNORED
	$opt_upper, 				# DEFAULT
	$opt_revcompl,			# IGNORED
	$opt_quiet, 				# IGNORED
	$opt_debug, 				
	$opt_citation,
	$outdir,
	$force,
);
setOptions();

my $optional_spacer = $opt_sep_size ? "\t" : ";";




my %counter = ();
my %labels  = ();
foreach my $file (@ARGV) {
	debug("Reading $file");
	$file = undef if ($file eq '-');
	my $parser;
  eval {
	  $parser = BioX::Seq::Stream->new( $file );
	};
  if ($@) {
    say STDERR " * Skipping '$file': $@";
    next;
  }

  while (my $seq = $parser->next_seq) {


			my $size = $seq->id =~/size=(\d+)/ ?  $1  : 1;

			$counter{uc( $seq->seq )} += $size;
			next unless ($opt_keep_name);

			$labels{uc( $seq->seq )}  = $seq->id;
	}

}

my $counter = 0;
for my $seq (sort { $counter{$b} <=> $counter{$a} } keys %counter ) {
	$counter++;
	my $name;
	if ($opt_keep_name) {

		$name = $labels{$seq};
	} else {
		$name = $opt_prefix . $opt_separator . $counter;
	}
  last if ($counter{$seq} < $opt_min_size);
	my $size_string = $opt_no_label ? '' : $optional_spacer . 'size='.$counter{$seq} . ";";
	print '>' , $name, $size_string, "\n", $seq, "\n";
}

sub ver {
 say "$EXE $VERSION";
 exit;
}

sub setOptions {
  use Getopt::Long;

  @Options = (
     'Options:',
		{OPT=>"k|keepname!",      VAR=>\$opt_keep_name ,                 DESC=>"Use first sequence name as cluster name"},
		{OPT=>"p|prefix=s",      VAR=>\$opt_prefix,  DEFAULT=>'seq',   DESC=>"Sequence prefix"},
		{OPT=>"s|separator=s",   VAR=>\$opt_separator,  DEFAULT=>'.',  DESC=>"Prefix and counter separator"},
		{OPT=>"m|min-size=i",    VAR=>\$opt_min_size,   DEFAULT=>0,    DESC=>"Print only sequences found at least N times"},
		{OPT=>'size-as-comment!' ,VAR=>\$opt_sep_size,   DEFAULT=>0,    DESC=>"Add size as comment, not as part of sequence name" },
    'General:',
    {OPT=>"help",      VAR=>\&usage ,                DESC=>"This help"},
    {OPT=>"version",   VAR=>\&ver,                   DESC=>"Print version and exit"},
    {OPT=>"citation",  VAR=>\&show_citation,         DESC=>"Print citation for seqfu"},
    {OPT=>"quiet!",    VAR=>\$opt_quiet, DEFAULT=>0, DESC=>"No screen output"},
    {OPT=>"debug!",    VAR=>\$opt_debug, DEFAULT=>0, DESC=>"Debug mode: keep all temporary files"},
     'Common seqfu options:',
    {OPT=>"w|line-width=i",  VAR=>\$opt_line_length, DEFAULT=>80, DESC=>"FASTA line size (0 for unlimited)"},
    {OPT=>"strip",           VAR=>\$opt_strip_comm,               DESC=>"Strip comments"},
    {OPT=>"fasta",           VAR=>\$opt_fasta,                    DESC=>"Force FASTA output"},
    {OPT=>"fastq",           VAR=>\$opt_fastq,                    DESC=>"Force FASTQ output"},
    {OPT=>"rc",              VAR=>\$opt_revcompl,                 DESC=>"Print reverse complementary"},
    {OPT=>'q|qual=f',        VAR=>\$opt_def_qual, DEFAULT=>32,    DESC=>"Default quality for FASTQ files"},
    {OPT=>'upper',           VAR=>\$opt_upper,                    DESC=>"Convert sequence to uppercase"},


  );

  (!@ARGV) && (usage(1));

  &GetOptions(map {$_->{OPT}, $_->{VAR}} grep { ref } @Options) || usage(1);
  # Check bad parameters
  if ($opt_fasta and $opt_fastq) { die "ERROR: Please specify either --fasta or --fastq.\n"; }
  if ($opt_line_length < 1) { $opt_line_length = 1_000_000_000_000_000 }

  # Now setup default values.
  foreach (@Options) {
    if (ref $_ && defined($_->{DEFAULT}) && !defined(${$_->{VAR}})) {
      ${$_->{VAR}} = $_->{DEFAULT};
    }
  }

}


sub debug {
	say STDERR '#' , $_[0] if ($opt_debug);
}
sub usage {
  my($exitcode) = @_;
  $exitcode ||= 0;
  $exitcode = 0 if $exitcode eq 'help';  # what gets passed by getopt func ref
  select STDERR if $exitcode;            # write to STDERR if exitcode is error

  print
    "Name:\n  ", ucfirst($EXE), " $VERSION by $AUTHOR\n",
    "Synopsis:\n  $DESC\n",
    "Usage:\n  $EXE [options] filename (or '-' for STDIN)\n";
  foreach (@Options) {
    if (ref) {
      my $def = defined($_->{DEFAULT}) ? " (default '$_->{DEFAULT}')" : "";
      $def = ($def ? ' (default OFF)' : '(default ON)') if $_->{OPT} =~ m/!$/;
      my $opt = $_->{OPT};
      $opt =~ s/!$//;
      $opt =~ s/=s$/ [X]/;
      $opt =~ s/=i$/ [N]/;
      $opt =~ s/=f$/ [n.n]/;
      printf STDERR "  --%-16s %s%s\n", $opt, $_->{DESC}, $def;
    }
    else {
      print "$_\n"; # Subheadings in the help output
    }
  }
  exit($exitcode);
}
