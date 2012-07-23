#!/usr/bin/perl

# running this script requires ssl libraries such as SSLeay, libssl, ...
 
use strict;
use warnings;
 
use Web::Scraper;
use WWW::Mechanize;
use WWW::Mechanize::GZip;
use Encode;
 
#my $mech = WWW::Mechanize->new();
# anonfiles is gzipped
my $mech = WWW::Mechanize::GZip->new();
my $seq = 1;
my $sleep_time = 5 * 60;  # 5 min
 
# target pub archive
my $pub_archive = "https://anonfiles.com/en/archive";


#
# main entrance
list();



#
#
# subroutines
sub list {
    my $response = $mech->get($pub_archive);
     
    if ($response->is_success) {
        my $HtmlData = $response->content();
        my $encodingType = 0;
     
        #my @links = $mech->find_all_links(tag=>"a", text_regex => qr/title/i);
        my @links = $mech->find_all_links(url_regex => qr/\/file\//i);
        #my @links = $mech->links();
        for my $link ( @links ) {
            my $url = $link->url_abs;
            my $filename = ""; #$url;

            print "Pub Archive : $url\n";
            my $c = $mech->get($url);

            
            # extract filename
            my $name_pattern = qw(<legend><b>(.*)</b>);
            if ($c->content() =~ /$name_pattern/g) {
                $filename = $1;
            }

            print "filename : $filename\n";

            my @links_2 = $mech->find_all_links(class_regex => qr/download_button/i);
            for my $link ( @links_2 ) {
                $url = $link->url_abs;

                print "Mechanize $url to $filename\n";
                $mech->get($url, ':content_file' => $filename);
            }

            print "   ", -s $filename, " bytes\n";
        }
                 
        #if($encodingType == 1 ) { $HtmlData = encode("euc-kr", decode("utf-8", $HtmlData)) }
    }
    $seq = 1;
}

sub pull {

}

# check file existence
# -f file

# directory management