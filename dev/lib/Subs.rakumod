unit module PDF::Subs;

use Pod::To::PDF::Lite;
use PDF::Lite;
use Text::Utils :strip-comment;

sub make-cover-page(PDF::Lite::Page $page, $debug) is export {
}

sub select-font() {
}

sub read-pdf-list($fnam, :$debug --> List) is export {
    my @list;
    for $fnam.IO.lines -> $line is copy {
        $line = strip-comment $line;
        next if $line !~~ /\S/;
        $line .= trim;
        @list.push: $line;
    }
    @list;
}

# from github/pod-to-pdf/Pod-To-PDF-Lite-raku/
# method !paginate($pdf) {
sub paginate($pdf, 
    :$margin!,
    :$number-first-page = False,
    :$count-first-page  = False,
    ) is export {

    my $page-count = $pdf.Pages.page-count;
    my $font = $pdf.core-font: "Helvetica";
    my $font-size := 9;
    my $align := 'right';
    my $page-num = 0;
    # modify page-count? 
    if not $count-first-page { # not usual in my book
        --$page-count;
        $number-first-page = False;
    }

    for $pdf.pages.iterate-pages -> $page {
        my $first-page = True;
        if $first-page {
            $first-page = False;
            next unless $count-first-page;
            if not $number-first-page {
                ++$page-num;
                next;
            }
        }
        ++$page-num;

        my PDF::Content $gfx = $page.gfx;
        # need some vertical whitespace here
        my $vspace = 0.4 * $font-size;
        #my @position = $gfx.width - $margin, $margin - $font-size;
        my @position = $gfx.width - $margin, $margin - $font-size - $vspace;

        #my $text = "Page {++$page-num} of $page-count";
        my $text = "Page $page-num of $page-count";
        $gfx.print: $text, :@position, :$font, :$font-size, :$align;
        $page.finish;
    }
}
