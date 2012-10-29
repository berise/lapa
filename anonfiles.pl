#!/usr/bin/perl

# running this script requires ssl libraries such as SSLeay, libssl, ...
 
use strict;
use warnings;
 
use Web::Scraper;
use WWW::Mechanize;
use WWW::Mechanize::GZip;
use Encode;
use File::Path;

 
#my $mech = WWW::Mechanize->new();
# anonfiles is gzipped
my $mech = WWW::Mechanize::GZip->new();
my $seq = 1;
my $sleep_time = 5 * 60;  # 5 min
 
# target pub archive
my $pub_archive = "https://anonfiles.com/en/archive";
my $local_dir = "pub/anonfiles";


#
# main entrance
init();
list();



#
#
# subroutines
sub list {
    print "Get a web archive listing page...\n";
    my $response = $mech->get($pub_archive);
     
    if ($response->is_success) {
        print "Receiving lists...\n";
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

            
            # extract filename and add prefix($local_dir)
            my $name_pattern = qw(<legend><b>(.*)</b>);
            if ($c->content() =~ /$name_pattern/g) {
                $filename = "$local_dir/$1";
            }

            # simple skip file that already exists
            if (-e $filename) {
                print "  $filename already exists.(skip!)";
                next;
            }

            my @links_2 = $mech->find_all_links(class_regex => qr/download_button/i);
            for my $link ( @links_2 ) {
                $url = $link->url_abs;

                print "  URL : $url\n";
                print "  filename : $filename";

                $mech->get($url, ':content_file' => $filename);
                print "(", -s $filename, ") bytes\n";
            }
        }
                 
        #if($encodingType == 1 ) { $HtmlData = encode("euc-kr", decode("utf-8", $HtmlData)) }
    }
    $seq = 1;
}


sub init {
    File::Path::make_path($local_dir);
}

sub pull {

}

# check file existence
# -f file

# directory management
