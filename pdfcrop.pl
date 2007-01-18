eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}' && eval 'exec perl -S $0 $argv:q'
  if 0;
use strict;
$^W=1; # turn warning on
#
# pdfcrop.pl
#
# Copyright (C) 2002, 2004 Heiko Oberdiek.
#
# This program may be distributed and/or modified under the
# conditions of the LaTeX Project Public License, either version 1.2
# of this license or (at your option) any later version.
# The latest version of this license is in
#   http://www.latex-project.org/lppl.txt
# and version 1.2 or later is part of all distributions of LaTeX
# version 1999/12/01 or later.
#
# See file "readme.txt" for a list of files that belong to this project.
#
# This file "pdfcrop.pl" may be renamed to "pdfcrop"
# for installation purposes.
#
my $file        = "pdfcrop.pl";
my $program     = uc($&) if $file =~ /^\w+/;
my $version     = "1.5";
my $date        = "2004/06/24";
my $author      = "Heiko Oberdiek";
my $copyright   = "Copyright (c) 2002, 2004 by $author.";
#
# Reqirements: Perl5, Ghostscript
# History:
#   2002/10/30 v1.0: First release.
#   2002/10/30 v1.1: Option --hires added.
#   2002/11/04 v1.2: "nul" instead of "/dev/null" for windows.
#   2002/11/23 v1.3: Use of File::Spec module's "devnull" call.
#   2002/11/29 v1.4: Option --papersize added.
#   2004/06/24 v1.5: Clear map file entries so that pdfTeX
#                    does not touch the fonts.
#

### program identification
my $title = "$program $version, $date - $copyright\n";

### error strings
my $Error = "!!! Error:"; # error prefix

### string constants for Ghostscript run
# get Ghostscript command name
my $GS = "gs";
$GS = "gs386"    if $^O =~ /dos/i;
$GS = "gsos2"    if $^O =~ /os2/i;
$GS = "gswin32c" if $^O =~ /mswin32/i;
$GS = "gswin32c" if $^O =~ /cygwin/i;

# Windows detection (no SIGHUP)
my $Win = 0;
$Win = 1 if $^O =~ /mswin32/i;
$Win = 1 if $^O =~ /cygwin/i;

# "null" device
use File::Spec::Functions qw(devnull);
my $null = devnull();

### variables
my $inputfile   = "";
my $outputfile  = "";
my $tmp = "tmp-\L$program\E-$$";

### option variables
my @bool = ("false", "true");
my %unit = ( 'pt'=>1, 'in'=>0.0138, 'mm'=>0.3527, 'cm' =>0.03527, 'P'=>0.08333333 );
$::opt_help       = 0;
$::opt_debug      = 0;
$::opt_verbose    = 0;
$::opt_gscmd      = $GS;
$::opt_pdftexcmd  = "pdftex";
$::opt_pdfinfocmd = "pdfinfo";
$::opt_margins    = "0 0 0 0";
$::opt_clip       = 0;
$::opt_hires      = 0;
$::opt_papersize  = "";
$::opt_unit = "pt";
$::opt_mode = "standard";

my $usage = <<"END_OF_USAGE";
${title}Syntax:   \L$program\E [options] <input[.pdf]> [output file]
Function: Margins are calculated and removed for each page in the file.
Options:                                                    (defaults:)
  --help              print usage
  --(no)verbose       verbose printing                      ($bool[$::opt_verbose])
  --(no)debug         debug informations                    ($bool[$::opt_debug])
  --gscmd <name>      call of ghostscript                   ($::opt_gscmd)
  --pdftexcmd <name>  call of pdfTeX                        ($::opt_pdftexcmd)
  --pdfinfocmd <name> call of pdfinfo			    ($::opt_pdfinfocmd)
  --margins "<left> <top> <right> <bottom>"                 ($::opt_margins)
                      add extra margins, unit is bp. If only one number is
                      given, then it is used for all margins, in the case
                      of two numbers they are also used for right and bottom.
  --(no)clip          clipping support, if margins are set, ignored when
		      in absolute mode  ($bool[$::opt_clip])
  --(no)hires         using `%%HiResBoundingBox'            ($bool[$::opt_hires])
                      instead of `%%BoundingBox'
  --papersize <foo>   parameter for gs's -sPAPERSIZE=<foo>,
                      use only with older gs versions <7.32 ($::opt_papersize)
  --unit <unitname>   set margins unit (pt, in, mm, cm, P) ($::opt_unit)
  --mode <standard | absolute | auto> ($::opt_mode)
		      pick crop mode :

		      standard - orginal pdfcrop working mode - each page is cropped
		      to individual size based od bbox size and taking margins into
		      account

		      absolute - clip size will be calculated based on pagesize returned
		      from pdfinfo command, not bbox. Thus, all pages will have
		      same size. Margin option set cropping box (i. e. how much to crop
                      from each side

  	              auth - clip size will be calculated based on maximum bbox size
		      from all pages. Thus, all pages will have same size, 
		      minimum required to fit all document elements 
  
Examples:
  \L$program\E --margins 10 input.pdf output.pdf
  \L$program\E --margins '5 10 5 20' --clip input.pdf output.pdf
  \L$program\E --auto input.pdf output.pdf
END_OF_USAGE

### process options
my @OrgArgv = @ARGV;
use Getopt::Long;
GetOptions(
  "help!",
  "debug!",
  "verbose!",
  "gscmd=s",
  "pdftexcmd=s",
  "pdfinfocmd=s",
  "margins=s",
  "clip!",
  "hires!",
  "papersize=s",
  "unit=s",
  "mode=s",
) or die $usage;
!$::opt_help or die $usage;

$::opt_verbose = 1 if $::opt_debug;

@ARGV >= 1 or die $usage;

print $title;

@ARGV <= 2 or die "$Error Too many files!\n";

### input file
$inputfile = shift @ARGV;

if (! -f $inputfile) {
    if (-f "$inputfile.pdf") {
        $inputfile .= ".pdf";
    }
    else {
        die "$Error Input file `$inputfile' not found!\n";
    }
}

print "* Input file: $inputfile\n" if $::opt_debug;

### output file
if (@ARGV) {
    $outputfile = shift @ARGV;
}
else {
    $outputfile = $inputfile;
    $outputfile =~ s/\.pdf$//i;
    $outputfile .= "-crop.pdf";
}

print "* Output file: $outputfile\n" if $::opt_debug;

### margins
my ($llx, $lly, $urx, $ury) = (0, 0, 0, 0);
if ($::opt_margins =~
        /^\s*([\-\.\d]+)\s+([\-\.\d]+)\s+([\-\.\d]+)\s+([\-\.\d]+)\s*$/) {
    ($llx, $lly, $urx, $ury) = ($1, $2, $3, $4);
}
else {
    if ($::opt_margins =~ /^\s*([\-\.\d]+)\s+([\-\.\d]+)\s*$/) {
        ($llx, $lly, $urx, $ury) = ($1, $2, $1, $2);
    }
    else {
        if ($::opt_margins =~ /^\s*([\-\.\d]+)\s*$/) {
            ($llx, $lly, $urx, $ury) = ($1, $1, $1, $1);
        }
        else {
            die "$Error Parse error (option --margins)!\n";
        }
    }
}

$llx = $llx / $unit{$::opt_unit};
$lly = $lly / $unit{$::opt_unit};
$urx = $urx / $unit{$::opt_unit};
$ury = $ury / $unit{$::opt_unit};

print "* Margins: $llx pt $lly pt $urx pt $ury pt\n" if $::opt_debug;


### cleanup system
my @unlink_files = ();
my $exit_code = 1;
sub clean {
    print "* Cleanup\n" if $::opt_debug;
    if ($::opt_debug) {
        print "* Temporary files: @unlink_files\n";
    }
    else {
        for (; @unlink_files>0; ) {
            unlink shift @unlink_files;
        }
    }
}
sub cleanup {
    clean();
    exit($exit_code);
}
$SIG{'INT'} = \&cleanup;
$SIG{'__DIE__'} = \&clean;

### Calculation of BoundingBoxes

my $cmdpipe="";
my $cmd = "";
if ( lc( $::opt_mode ) eq "absolute" ){
	$cmdpipe = "$::opt_pdfinfocmd $inputfile |";
} else {
	$cmd = "$::opt_gscmd -sDEVICE=bbox -dBATCH -dNOPAUSE ";
	$cmd .= "-sPAPERSIZE=$::opt_papersize " if $::opt_papersize;
	$cmd .= "-c save pop -f " . $inputfile;
	$cmdpipe = $cmd . " 2>&1 1>$null |";
}

my $tmpfile = "$tmp.tex";
push @unlink_files, $tmpfile;
open(TMP, ">$tmpfile") or
    die "$Error Cannot write tmp file `$tmpfile'!\n";
print TMP "\\def\\pdffile{$inputfile}\n";
print TMP <<'END_TMP_HEAD';
\csname pdfmapfile\endcsname{}
\def\page #1 [#2 #3 #4 #5]{%
  \count0=#1\relax
  \setbox0=\hbox{%
    \pdfximage page #1{\pdffile}%
    \pdfrefximage\pdflastximage
  }%
  \pdfhorigin=-#2bp\relax
  \pdfvorigin=#3bp\relax
  \pdfpagewidth=#4bp\relax
  \advance\pdfpagewidth by -#2bp\relax
  \pdfpageheight=#5bp\relax
  \advance\pdfpageheight by -#3bp\relax
  \ht0=\pdfpageheight
  \shipout\box0\relax
}
\def\pageclip #1 [#2 #3 #4 #5][#6 #7 #8 #9]{%
  \count0=#1\relax
  \dimen0=#4bp\relax \advance\dimen0 by -#2bp\relax
  \edef\imagewidth{\the\dimen0}%
  \dimen0=#5bp\relax \advance\dimen0 by -#3bp\relax
  \edef\imageheight{\the\dimen0}%
  \pdfximage page #1{\pdffile}%
  \setbox0=\hbox{%
    \kern -#2bp\relax
    \lower #3bp\hbox{\pdfrefximage\pdflastximage}%
  }%
  \wd0=\imagewidth\relax
  \ht0=\imageheight\relax
  \dp0=0pt\relax
  \pdfhorigin=#6pt\relax
  \pdfvorigin=#7bp\relax
  \pdfpagewidth=\imagewidth
  \advance\pdfpagewidth by #6bp\relax
  \advance\pdfpagewidth by #8bp\relax
  \pdfpageheight=\imageheight\relax
  \advance\pdfpageheight by #7bp\relax
  \advance\pdfpageheight by #9bp\relax
  \pdfxform0\relax
  \shipout\hbox{\pdfrefxform\pdflastxform}%
}%
END_TMP_HEAD

my $page = 0;
if ( lc ( $::opt_mode ) ne "absolute" ) {
print "* Running ghostscript for BoundingBox calculation ...\n"
    if $::opt_verbose;
print "* Ghostscript pipe: $cmdpipe\n" if $::opt_debug;

my $min_llx = 0;
my $min_lly = 0;
my $max_urx = 0;
my $max_ury = 0;

open(CMD, $cmdpipe) or
    die "$Error Cannot call ghostscript!\n";
while (<CMD>) {
    my $bb = ($::opt_hires) ? "%%HiResBoundingBox" : "%%BoundingBox";
    next unless
        /^$bb:\s*([\.\d]+) ([\.\d]+) ([\.\d]+) ([\.\d]+)/o;
    $page++;
    print "* Page $page: $1 $2 $3 $4\n" if $::opt_verbose;
    
    if ($min_llx > $1 or $page == 1 ) { $min_llx = $1; };
    if ($min_lly > $2 or $page == 1 ) { $min_lly = $2; };
    if ($max_urx < $3 or $page == 1 ) { $max_urx = $3; };
    if ($max_ury < $4 or $page == 1 ) { $max_ury = $4; };
 
    print "* Calculated clip dimensions $min_llx $min_lly $max_urx $max_ury\n" if $::opt_verbose and lc ($::opt_mode) eq "auto";

 if ( lc ($::opt_mode) eq "standard" ) {   
    if ($::opt_clip) {
        print TMP "\\pageclip $page [$1 $2 $3 $4][$llx $lly $urx $ury]\n";
    }
    else {
        my ($a, $b, $c, $d) = ($1 - $llx, $2 - $ury, $3 + $urx, $4 + $lly);
        print TMP "\\page $page [$a $b $c $d]\n";
    }
 }

}

 if ( lc ($::opt_mode) eq "auto" ) { 

   for(my $i=1;$i<=$page;$i++) {
     if ($::opt_clip) {
       print TMP "\\pageclip $i [$min_llx $min_lly $max_urx $max_ury][$llx $lly $urx $ury]\n";
      }
    else {
        my ($a, $b, $c, $d) = ($min_llx - $llx, $min_lly - $ury, $max_urx + $urx, $max_ury + $lly);
        print TMP "\\page $i [$a $b $c $d]\n";
    }

   }
 }
close(CMD);
}

if ( lc ($::opt_mode) eq "absolute") {
  open(CMD, $cmdpipe) or
     die "$Error Cannot call pdfinfo!\n";

  my $max_ury = 0;
  my $max_urx = 0;
  $page = 0;

  while (<CMD>) {
    if (/^Pages:\s*(\d+)/) {
        $page = $1;
    }
    if ( /^Page size:\s*([\.\d]+)\sx\s([\.\d]+)/ ) {

        $max_urx=$1;
        $max_ury=$2;
        print "Page dimensions $max_urx x $max_ury\n" if $::opt_verbose;
    }
  }

  close (CMD);

  for(my $i=1;$i<=$page;$i++) {
        my ($a, $b, $c, $d) = ($llx, $ury, $max_urx - $urx, $max_ury - $lly);
        print TMP "\\page $i [$a $b $c $d]\n";
  }

}
print TMP "\\csname \@\@end\\endcsname\n\\end\n";
close(TMP);

### Run pdfTeX

push @unlink_files, "$tmp.log";
if ($::opt_verbose) {
    $cmd = "$::opt_pdftexcmd -interaction=nonstopmode $tmp";
}
else {
    $cmd = "$::opt_pdftexcmd -interaction=batchmode $tmp";
}
print "* Running pdfTeX ...\n" if $::opt_verbose;
print "* pdfTeX call: $cmd\n" if $::opt_debug;
if ($::opt_verbose) {
    system($cmd);
}
else {
    `$cmd`;
}
if ($?) {
    die "$Error pdfTeX run failed!\n";
}

### Move temp file to output
rename "$tmp.pdf", $outputfile or
    die "$Error Cannot move `$tmp.pdf' to `$outputfile'!\n";

print "==> $page pages written on `$outputfile'.\n";

$exit_code = 0;
cleanup();

__END__
