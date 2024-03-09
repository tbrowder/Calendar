unit module HowtoGFX;

use PDF::API6;
use PDF::Lite;
use PDF::Content::FontObj;
use PDF::Content::Page :PageSizes;
use PDF::Content::Color :ColorName, :rgb;

my \LLX = 0;
my \LLY = 1;
my \URX = 2;
my \URY = 3;

# Routines to create text and graphics blocks on
# a PDF::Content::Page.

# The page creation sub from where all other subs are called
# use: new-page :$page, :$landscape;
sub new-page(
    :$page!, # the fresh, landscape orientation
    Bool :$landscape = False,
    Bool :$inverted  is copy = False, # instead of "upside-down"
    :$media where { /:i [Letter|A4]/ } = "letter",
    :$font!,
    :$font-size is copy = 10,
    :$debug,
) is export {
    # get the media
    $page.media-box = get-media $media;

    my \g = $page.gfx;
    g.Save; # REQUIRED when using $page.gfx
    if $landscape {
        # move the origin to the lower-right corner of the page
        g.transform: :translate[$page.media-box[URX],
                                $page.media-box[LLY]];
        # rotate the x/y axes counter-clockwise
        # rotate: left (ccw) 90 degrees
        g.transform: :rotate(90 * pi/180);
    }
    #======== continue to mark the page as desired
    # subs should work here and respect the page orientation

    my $height = 1*72;
    my $width  = 1.5*72;
    my $x0     = 0.5*72;
    my $y0     = 7*72;

    # draw a border around the N cells first
    draw-box :$page, :inside(False), :llx($x0+$width), :lly($y0-$height),
    :width(3*$width), :$height;
    for 1..3 -> $i {
        my $x = $x0 + $i * $width;
        my $text = "Number $i";
        draw-box :$page, :llx($x), :lly($y0-$height), :$width, :$height;
        put-text :$text, :$page, :x-origin($x+0.5*$width),
        :y-origin($y0-0.5*$height), :$width, :$font,
        :align<center>, :valign<center>;
    }

    #======== finish the page
    g.Restore; # REQUIRED when using $page.gfx
}

sub get-media(
    $media is copy,
    :$debug,
    --> Array
) is export {
    my @arr = [0, 0, 612, 792]; # Letter
    with $media {
        when /:i letter/ {
            @arr = [0, 0, 612, 792];
        }
        when /:i a4/ {
            @arr = [0,0, 595, 842];
        }
        default {
            # Letter
            @arr = [0, 0, 612, 792];
        }
    }
    @arr
}

sub get-rgb(
    $color is copy,
    :$debug,
    --> Array
) is export {
    with $color {
        # See PDF::Content::Color for the 20 known colors
        # We can add more if need be
        when /:i (aqua    | black   |
                  blue    | fuschia |
                  gray    | green   |
                  lime    | maroon  |
                  navy    | olive   |
                  orange  | purple  |
                  red     | silver  |
                  teal    | white   |
                  yellow  | cyan    |
                  magenta | registration
                  ) / {
            $color = ~$0.tc;
        }
        default {
            $color = "Black";
        }
    }
    # $pdf.media-box = %(PageSizes.enums){$media};
    # Note we MUST coerce it to an Array
    @(%(ColorName.enums){$color});
}

# use: put-text :$text, :$page, :$x-origin, :$y-origin, :$font, :$font-size,
#               :$align, :$valign, :$font-color;
sub put-text(
    :$text = "",
    PDF::Content::Page :$page!,
    :$x-origin!, :$y-origin!,
    :$font!,
    :$font-size is copy = 10,
    :$width, :$height,
    :$align is copy = "left", :$valign is copy = "bottom",
    :$font-color is copy = "black",
    :$debug,
) is export {
    $align  = "center";
    $valign = "center";
    my ($w, $h) = $width, $height;
    my PDF::Content::Text::Box $text-box;
    my @b = $text-box .= new: :$text, :$font, :$font-size, :$align, :$valign;
    # ^^^ note use of :$height # restricts the size of the box

    my \g = $page.gfx;
    g.Save;
    g.SetStrokeRGB: get-rgb($font-color);
    g.transform: :translate($x-origin, $y-origin);
    # put a text box inside
    g.BeginText;
    #.text-position[$x-origin, $y-origin];
    g.text-position[0, 0];
    g.print: $text-box;
    g.EndText;
    g.Restore;

    @b
}

# use: draw-box :$page, :$llx, :$lly, :$width, :$height, :$border-width,
#               :$border-color, :$fill-color;
sub draw-box(
    PDF::Content::Page :$page!,
    :$llx!, :$lly!, :$width!, :$height!,
    Bool :$inside = True,
    :$border-width is copy = 1.5,
    :$border-color = "Black",
    :$fill-color = "White",
    :$debug,
) is export {

    my ($w, $h, $bw) = $width, $height, $border-width;

    my \g = $page.gfx;
    # Prepare the cell by filling with black then move inside
    # (or outside) by border width and fill with desired color
    g.Save;
    g.transform: :translate($llx, $lly); # lower-left corner

    # Fill cell with border color and clip to exclude color
    # outside (or inside) created by the borderwidth
    g.SetFillRGB: get-rgb($border-color); # Black
    # rectangles start at their lower-left corner
    if $inside {
        g.Rectangle: 0, 0, $w, $h;
    }
    else {
        g.Rectangle: 0-$bw, 0-$bw, $w+2*$bw, $h+2*$bw;;
    }
    g.ClosePath;
    g.Clip;
    g.Fill;

    # Fill cell with fill (background) color and clip it inside
    # (or outside) by the border width
    g.SetFillRGB: get-rgb($fill-color); # White
    if $inside {
        g.Rectangle: 0+$bw, 0+$bw, $w-2*$bw, $h-2*$bw;
    }
    else {
        g.Rectangle: 0, 0, $w, $h;
    }
    g.Clip;
    g.Fill;

    g.Restore;
}
