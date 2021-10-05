package Plugins::RFIDPlay::Plugin;

# Copyright (c) 2021 Erland Isaksson (erland_i@hotmail.com)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#

use strict;

use base qw(Slim::Plugin::Base);
use Slim::Utils::Prefs;
use Plugins::RFIDPlay::Settings;

my $log = Slim::Utils::Log->addLogCategory(
	{
		'category' => 'plugin.rfidplay',
		'defaultLevel' => 'WARN',
		'description' => getDisplayName()
	}
);
my $prefs = preferences('plugin.rfidplay');

sub initPlugin {
	my $class = shift;
	$class->SUPER::initPlugin(@_);
	Plugins::RFIDPlay::Settings->new();
	return;
}

sub webPages {
	my $class = shift;
	Slim::Web::Pages->addRawFunction('RFIDPlay/play/', \&handlePlayRequest);
	Slim::Web::Pages->addRawFunction('RFIDPlay/volume/', \&handleVolumeRequest);
	Slim::Web::Pages->addRawFunction('RFIDPlay/playlist/', \&handlePlaylistRequest);
}

sub handlePlayRequest {
	my ($httpClient, $httpResponse) = @_;

	my $req = $httpResponse->request;

	# Extract RFID identity
	my $rfidIdentity = $req->uri->path;
	$rfidIdentity =~ s/^\/plugins\/RFIDPlay\/play\///;

	if($rfidIdentity) {
		$log->warn("Searching for $rfidIdentity");
		my $cards = $prefs->get('cards');
		if($cards->{$rfidIdentity}) {
			$log->warn("Found entry for $rfidIdentity");
			my $entry = $cards->{$rfidIdentity};
			if($entry->{'playlist'}) {
				$log->warn("Entry contains playlist: ".$entry->{'playlist'});
				my $playerId = $prefs->get('player');
				if($playerId) {
					$log->warn("Searching for player: $playerId");
					my $player = Slim::Player::Client::getClient($playerId);
					if(defined($player)) {
						$log->warn("Trying to play ".$entry->{'playlist'}." on ".$playerId);
						my $request = $player->execute(['playlist', 'play', $entry->{'playlist'}]);
					}
				}
			}
		}else {
			$cards->{$rfidIdentity} = {'players' => undef, 'playlist' => undef};
			$prefs->set('cards', $cards);
		}
	}
	my $body = "";
	$httpResponse->code(200);
	$httpResponse->header( 'Content-Type' => 'application/json' );
	$httpResponse->header( 'Content-Length', length $body );
	Slim::Web::HTTP::addHTTPResponse( $httpClient, $httpResponse, \$body);
	return;
}

sub handleVolumeRequest {
        my ($httpClient, $httpResponse) = @_;

        my $req = $httpResponse->request;

        # Extract volume command
        my $volumeChange = $req->uri->path;
        $volumeChange =~ s/^\/plugins\/RFIDPlay\/volume\///;

	my $playerId = $prefs->get('player');
        if($playerId) {
		$log->warn("Searching for player: $playerId");
                my $player = Slim::Player::Client::getClient($playerId);
                if(defined($player)) {
                        $log->warn("Trying to change volume ".$volumeChange." on ".$playerId);
                        my $request = $player->execute(['mixer', 'volume', $volumeChange]);
                }
        }

	my $body = "";
        $httpResponse->code(200);
        $httpResponse->header( 'Content-Type' => 'application/json' );
        $httpResponse->header( 'Content-Length', length $body );
        Slim::Web::HTTP::addHTTPResponse( $httpClient, $httpResponse, \$body);
        return;
}

sub handlePlaylistRequest {
        my ($httpClient, $httpResponse) = @_;

        my $req = $httpResponse->request;

        # Extract volume command
        my $playlistMove = $req->uri->path;
        $playlistMove =~ s/^\/plugins\/RFIDPlay\/playlist\///;

        my $playerId = $prefs->get('player');
        if($playerId) {
                $log->warn("Searching for player: $playerId");
                my $player = Slim::Player::Client::getClient($playerId);
                if(defined($player)) {
                        $log->warn("Trying to move to other song ".$playlistMove." on ".$playerId);
                        my $request = $player->execute(['playlist', 'index', $playlistMove]);
                }
        }

        my $body = "";
        $httpResponse->code(200);
        $httpResponse->header( 'Content-Type' => 'application/json' );
        $httpResponse->header( 'Content-Length', length $body );
        Slim::Web::HTTP::addHTTPResponse( $httpClient, $httpResponse, \$body);
        return;
}

sub getDisplayName {
	return 'PLUGIN_RFIDPLAY';
}

1;
