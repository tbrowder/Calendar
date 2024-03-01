unit module PDF-Subs;

use PDF::Content::FontObj;
use PDF::Content::Page :PageSizes;
use PDF::Content::Color :ColorName, :rgb;

# Routines to create text and graphics blocks on
# a PDF::Content::Page.
sub get-rgb(
    $color is copy,
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

# use: start-page :$page, :orient<landscape>, :media<Letter>;
sub start-page(
    PDF::Content::Page :$page!,
    Bool :$landscape = False,
    :$media where { /:i [Letter|A4]/ } = "letter",
) is export {

    # For this document, always use internal landscape, "right-side up"
    # i.e, NOT upside-down

    # Set the media here
    with $media {
        when /:i letter/ {
            $page.media-box = Letter;
        }
        when /:i a4/ {
            $page.media-box = A4;
        }
    }

    $page.graphics: {
        # always save the CTM
        # BUT DON'T FORGET sub finish-page!
        .Save;
        #===================================
        my ($w, $h);

        # Set the landscape if needed
        if $landscape {
            #    if not $upside-down {
            # Normal landscape
            # translate from: lower-left corner to: lower-right corner
            # LLX, LLY -> URX, LLY
            .transform: :translate($page.media-box[2], $page.media-box[1]);
            # rotate: left (ccw) 90 degrees
            .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
            #    for upside-down:
            #        MAKE ONE MORE TRANSLATION IN Y=0 AT TOP OF PAPER
            #        THEN Y DIMENS ARE NEGATIVE AFTER THAT
            #        LLX, LLY -> LLX, URY
            #    }
            .transform: :translate(0, $page.media-box[2]);
        }

        $w = $page.media-box[3] - $page.media-box[1];
        $h = $page.media-box[2] - $page.media-box[0];
    }
}

sub finish-page(
    PDF::Content::Page :$page!,
) is export {
    $page.graphics: {
        .Restore;
    }
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
) is export {
    $align  = "center";
    $valign = "center";
    my ($w, $h) = $width, $height;
    my PDF::Content::Text::Box $text-box;
    my @b = $text-box .= new: :$text, :$font, :$font-size, :$align, :$valign;
    # ^^^ note use of :$height # restricts the size of the box

    $page.graphics: {
        .Save;
        .SetStrokeRGB: get-rgb($font-color);
        .transform: :translate($x-origin, $y-origin);
        # put a text box inside
        .BeginText;
        .text-position[$x-origin, $y-origin];
        .print: $text-box;
        .EndText;
        .Restore;
    }
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
) is export {

   my ($w, $h, $bw) = $width, $height, $border-width;

    $page.graphics: {
        # Prepare the cell by filling with black then move inside
        # (or outside) by border width and fill with desired color
        .Save;
        .transform: :translate($llx, $lly); # lower-left corner

        # Fill cell with border color and clip to exclude color
        # outside (or inside) created by the borderwidth
        .SetFillRGB: get-rgb($border-color); # Black
         # rectangles start at their lower-left corner
         if $inside {
            .Rectangle: 0, 0, $w, $h;
         }
         else {
            .Rectangle: 0-$bw, 0-$bw, $w+2*$bw, $h+2*$bw;;
         }
        .ClosePath;
        .Clip;
        .Fill;

        # Fill cell with fill (background) color and clip it inside
        # (or outside) by the border width
        .SetFillRGB:  get-rgb($fill-color); # White
        if $inside {
           .Rectangle: 0+$bw, 0+$bw, $w-2*$bw, $h-2*$bw;
        }
        else {
           .Rectangle: 0, 0, $w, $h;
        }
        .Clip;
        .Fill;

        .Restore;
    }
}
