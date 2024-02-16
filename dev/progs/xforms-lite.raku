#!/bin/env raku

use v6;
use PDF::API6;
use PDF::Lite;
use PDF::XObject::Form;
use PDF::Content::Color :rgb; #:ColorName, :color;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates use of an XForm object on a page
      but defined in a sub.
    HERE
    exit
}

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
$page.media-box = [0, 0, 8.5*72, 11*72];
my $form = xform :$page;
my $ofile = "xforms-lite.pdf";
# display the form a couple of times
$page.graphics: {
   .do: $form, :position[300, 300], :align<center>, :valign<center>;
}

$pdf.save-as: $ofile;
say "See output file: ", $ofile;

#==== subroutines
sub xform($text = "<text>", :$page!) is export {
    # create a new XObject form of size 120 x 50
    my @BBox = [0, 0, 100, 50];
    my $form = $page.xobject-form: :@BBox;

    $form.graphics: {
        .Save;
        # color the entire form
        .FillColor = rgb(0, 0, 0); #color Black;
        .Rectangle: |@BBox;
        .paint: :fill, :stroke;
        .FillColor = rgb(1, 1, 1); #color White;
        # add some sample text
        .text: {
            .font = .core-font('Helvetica'), 14;
            .print: "White", :position[50, 25-0.5*14], :align<center>, :valign<center>;
        }
        .Restore;
    }
    $form
}
