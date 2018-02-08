#!/usr/bin/env python3

"""
Update crypto statistics to cache file using coinmarketcap API
Use currency.converter() if currency to convert to not supported,
"""

import requests

import currency
import config
import cache

config = config.read()

def process_meta_info(meta):
	""" pretty price number in meta """
	volume_24h = int(meta['total_24h_volume_usd'])
	market_cap = int(meta['total_market_cap_usd'])
	meta['total_24h_volume_usd'] = currency.pretty(volume_24h, 'USD')
	meta['total_market_cap_usd'] = currency.pretty(market_cap, 'USD')
	return meta

def process_crypto_info(crypto):
	""" convert to local currency if specified in config file
	trim long decimals and format price number. then save into cache file """

	base_currency = config['global']['base_currency'].lower()
	local_price_str = 'price_' + base_currency

	price_btc = float(crypto['price_btc'])
	price_usd = float(crypto['price_usd'])
	if local_price_str not in crypto: # API failed to convert to local price
		local_price = float(currency.convert('USD', base_currency, price_usd))
	else:
		local_price = float(crypto[local_price_str])
	# dont have bitcoin icon yet :(
	crypto['price_btc'] = currency.pretty(price_btc, 'BTC', abbrev=False)
	crypto['price_usd'] = currency.pretty(price_usd, 'USD')
	crypto[local_price_str] = currency.pretty(local_price, base_currency)
	return crypto

def request_info():
	""" request coinmarketcap API for cryptocurrencies and global market statistics
	return a tuple of meta and cryptos info """

	base_currency = config['global']['base_currency']
	convert_option = {'convert': base_currency}

	api_url = 'https://api.coinmarketcap.com/v1/ticker/'
	api_meta_url = 'https://api.coinmarketcap.com/v1/global/'
	cryptocurrencies = requests.get(api_url, params=convert_option).json()
	meta_info = requests.get(api_meta_url).json()

	return (meta_info, cryptocurrencies)

def update_cache(tracked_coins):
	""" get coin info on the internet, format some values and write it to cache
	for later retrieval """
	meta, cryptocurrencies = request_info()
	crypto_info = {}
	for crypto in cryptocurrencies:
		if crypto['id'] in tracked_coins:
			coinname = crypto['id']
			crypto_info[coinname] = process_crypto_info(crypto)
	data = {'GLOBAL': process_meta_info(meta), 'ticker': crypto_info}
	cache.write(data, 'cache.json')

def main():
	coinnames = [x for x in config.sections() if x != 'global']
	update_cache(coinnames)

if __name__ == '__main__':
	main()

# vim: nofoldenable