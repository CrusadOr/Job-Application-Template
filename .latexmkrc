# Build every source in its own auxiliary directory, then publish the finished
# PDF under the document type's stable name beside the source. Private CV
# variants therefore replace MyCVs/CV.pdf, while cover-letter variants replace
# MyCVs/CoverLetter.pdf.
use File::Copy qw(copy);

$pdf_mode = 1;
$go_mode = 1;
@default_files = ('CV.tex');

my $application_source = 'CV.tex';
for my $argument (@ARGV) {
    my $candidate = $argument;
    $candidate =~ s{\\}{/}g;
    if (($candidate !~ /^-/) && ($candidate =~ /\.tex$/i)) {
        $application_source = $candidate;
    }
}

my $application_source_dir = '.';
my $application_source_name = $application_source;
$application_source_name =~ s{^.*/}{};
$application_source_name =~ s{\.tex$}{}i;

if ($application_source =~ m{/}) {
    $application_source_dir = $application_source;
    $application_source_dir =~ s{/[^/]+$}{};
}

my $is_cover_letter = ($application_source_name =~ /^CoverLetter(?:[-_ ].*)?$/i);
if (open my $source_handle, '<', $application_source) {
    while (my $line = <$source_handle>) {
        if ($line =~ /^\s*%\s*!CV\s+document\s*=\s*cover-letter\s*$/i) {
            $is_cover_letter = 1;
            last;
        }
    }
    close $source_handle;
}

my $published_name = $is_cover_letter ? 'CoverLetter.pdf' : 'CV.pdf';
our $application_publish_path =
    $application_source_dir eq '.'
        ? $published_name
        : "$application_source_dir/$published_name";

$out_dir = "$application_source_dir/.cv-build/$application_source_name";
$aux_dir = $out_dir;

sub publish_application_pdf {
    my ($built_pdf) = @_;

    if (!-f $built_pdf) {
        warn "Cannot publish missing PDF '$built_pdf'.\n";
        return 1;
    }

    if (!copy($built_pdf, $application_publish_path)) {
        warn "Cannot publish '$built_pdf' as '$application_publish_path': $!\n";
        return 1;
    }

    print "Published $application_publish_path\n";
    return 0;
}

$success_cmd = 'internal publish_application_pdf %D';
