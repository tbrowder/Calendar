unit module Calendar::Fonts;

use PDF::Font::Loader :load-font;
use PDF::Content;

use QueryOS;

my $os = OS.new;

# copy the OS paths here from FontFactory
my $Ld = "/usr/share/fonts/opentype/freefont";
my $Md = "/opt/homebrew/Caskroom/font-freefont/20120503/freefont-20120503";
my $Wd = "/usr/share/fonts/opentype/freefont";

sub get-loaded-fonts-hash(:$debug --> Hash) is export {
    my $fontdir;
    if $os.is-linux {
        $fontdir = $Ld;
    }
    elsif $os.is-macos {
        $fontdir = $Md;
    }
    elsif $os.is-windows {
        $fontdir = $Wd;
    }
    else {
        die "FATAL: Unable to determine your operating system (OS)";
    }

    # we're using a subset of the Free Font collection
    # fonts needed
    my $fft  = "$fontdir/FreeSerif.otf";
    my $fftb = "$fontdir/FreeSerifBold.otf";
    my $ffti = "$fontdir/FreeSerifItalic.otf";
    my $ffhb = "$fontdir/FreeSansBold.otf";
    my $ffh  = "$fontdir/FreeSans.otf";
 
    my %fonts;
    %fonts<t>  = load-font :file($fft);
    %fonts<tb> = load-font :file($fftb);
    %fonts<ti> = load-font :file($ffti);
    %fonts<hb> = load-font :file($ffhb);
    %fonts<h>  = load-font :file($ffh);
    %fonts;
}

