#!/usr/bin/perl

use Thread;
my @threads = (1, 2, 3, 4);

foreach my $i(@threads){
    next unless defined $mho;
    print "Start on thread!";
    $threads[$tmpcount]=Thread -> create(\&start_thread, $mho);
    $tempcount++;
}


foreach my $thread(@threads){
    $thread->join();
}

sub start_thread{
    my($infomho)=@_;
    print "in thread $infomho";
    sleep 20;
}



