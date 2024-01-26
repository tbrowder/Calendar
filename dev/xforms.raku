#!/bin/env raku

use v6;
use PDF::API6;
use PDF::Page;
use PDF::XObject::Form;
use PDF::Content::Color :rgb; #:ColorName, :color;

my PDF::API6 $pdf .= new;
my PDF::Page $page = $pdf.add-page;
$page.media-box = [0, 0, 8.5*72, 11*72];

my $ofile = "xforms.pdf";

# create a new XObject form of size 120 x 50
my @BBox = [0, 0, 100, 50];
my PDF::XObject::Form $form = $page.xobject-form: :@BBox;

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
        .text-position = 50, 25;
        .print: "White", :align<center>, :valign<center>;
    }
    .Restore;
}

# display the form a couple of times
$page.graphics: {
    .Save;
    .transform: :translate(300, 300);
    .do($form);
    .Restore;
    .Save;
    .transform: :translate(200, 300);
    .do($form);
    .Restore;
}

$pdf.save-as: $ofile;
say "see output file: $ofile";
