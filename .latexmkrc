# Give every CV source the same final PDF name while keeping its auxiliary
# files separate.  The source directory is derived from latexmk's command line,
# so CV.tex publishes CV.pdf beside itself and MyCVs/*.tex publishes
# MyCVs/CV.pdf.
$pdf_mode = 1;
$jobname = 'CV';
$go_mode = 1;

my $cv_source = '';
for my $argument (@ARGV) {
    my $candidate = $argument;
    $candidate =~ s{\\}{/}g;
    if (($candidate !~ /^-/) && ($candidate =~ /\.tex$/i)) {
        $cv_source = $candidate;
    }
}

my $cv_source_dir = '.';
my $cv_source_name = 'CV';
if ($cv_source ne '') {
    $cv_source_dir = $cv_source;
    if ($cv_source_dir =~ m{/}) {
        $cv_source_dir =~ s{/[^/]+$}{};
    }
    else {
        $cv_source_dir = '.';
    }

    $cv_source_name = $cv_source;
    $cv_source_name =~ s{^.*/}{};
    $cv_source_name =~ s{\.tex$}{}i;
}

$out_dir = "$cv_source_dir/.cv-build/$cv_source_name";
$aux_dir = $out_dir;
$out2_dir = $cv_source_dir;
@out2_exts = ('pdf');
