#!/usr/bin/env bash
set -uo pipefail

service=org.freedesktop.network1
manager=/org/freedesktop/network1
interface=org.freedesktop.network1.Manager

fallback() {
	printf '{"text":"down","name":"","address":"","state":"offline","online":false,"wireless":false}\n'
}

manager_state() {
	busctl --system --json=short get-property "$service" "$manager" "$interface" OnlineState 2>/dev/null \
		| jq -r '.data // "unknown"'
}

links_json=$(busctl --system --json=short call "$service" "$manager" "$interface" ListLinks 2>/dev/null) || {
	fallback
	exit 0
}

descriptions=$(
	jq -r '.data[0][] | @tsv' <<<"$links_json" | while IFS=$'\t' read -r _index _name path; do
		busctl --system --json=short call "$service" "$path" org.freedesktop.network1.Link Describe 2>/dev/null \
			| jq -r '.data[0] | fromjson | @json' 2>/dev/null
	done
)

if [[ -z "$descriptions" ]]; then
	fallback
	exit 0
fi

online_state=$(manager_state)

jq -cs --arg online_state "$online_state" '
	def primary_address:
		([.Addresses[]? | select(.Family == 2 and .ScopeString == "global") | .AddressString][0]
		// [.Addresses[]? | select(.Family == 10 and .ScopeString != "link") | .AddressString][0]
		// "");

	def has_default_route:
		any(.Routes[]?; .DestinationPrefixLength == 0 and (.Table == 254 or .TableString == "main"));

	def rank:
		if has_default_route then 0
		elif .OperationalState == "routable" then 1
		elif .OnlineState == "online" then 2
		elif .CarrierState == "carrier" then 3
		else 4
		end;

	[
		.[] |
		select(.Name != "lo") |
		select((.Type // "") | test("^(veth|bridge|tun|tap)$") | not) |
		select(.OperationalState != "off" and .OperationalState != "missing")
	] as $links |
	($links | sort_by(rank, .Name) | .[0]) as $link |
	if $link == null then
		{
			text: $online_state,
			name: "",
			address: "",
			state: $online_state,
			online: ($online_state == "online"),
			wireless: false
		}
	else
		($link | primary_address) as $address |
		($link.OperationalState // $link.OnlineState // $online_state) as $state |
		{
			text: ($link.Name + (if $address == "" then "" else " " + $address end)),
			name: $link.Name,
			address: $address,
			state: $state,
			online: ($link.OnlineState == "online" or $online_state == "online"),
			wireless: (($link.Type // "") == "wlan")
		}
	end
' <<<"$descriptions"
