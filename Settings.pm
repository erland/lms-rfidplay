package Plugins::RFIDPlay::Settings;

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
use base qw(Slim::Web::Settings);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Player::Client;

my $prefs = preferences('plugin.rfidplay');
my $log   = logger('plugin.rfidplay');

sub name {
        return Slim::Web::HTTP::CSRF->protectName('PLUGIN_RFIDPLAY');
}

sub prefs {
        return ( $prefs, qw(player) );
}

sub page {
        return Slim::Web::HTTP::CSRF->protectURI('plugins/RFIDPlay/settings/cards.html');
}

sub handler {
	my ($class, $client, $params) = @_;

	if ($params->{'saveSettings'}) {
		my $cards = $prefs->get('cards');

		foreach my $cardId (keys %$cards) {
			if ( $params->{"delete$cardId"} ) {
				delete $cards->{$cardId};
				next;
			}

			if ( !defined($cards->{$cardId})) {
				$cards->{$cardId} = {};
			}
			foreach (qw(playlist)) {
				if ($params->{"$_$cardId"} ne '') {
					$cards->{$cardId}->{$_} = $params->{"$_$cardId"};
				}else {
					$cards->{$cardId}->{$_} = undef;
				}
			}
		}
		$prefs->set('cards', $cards);
	}
	$params->{'cards'} = $prefs->get('cards');
	my @players = ();
	foreach (Slim::Player::Client::clients()) {
		my $player = {
			id => $_->id,
			name => $_->name
		};
		push @players, $player;
	}
	$params->{'players'} = \@players;
	$class->SUPER::handler($client, $params);
}

1;

