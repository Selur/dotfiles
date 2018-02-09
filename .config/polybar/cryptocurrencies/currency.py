#!/bin/env python

"""
This module convert from one currency to another, result will be saved in cache file
for later use. if result get from cache is older than 30 minutes request API again to
get the new value

API info:
	What it does: convert one currency to others
	Site: https://free.currencyconverterapi.com
	Call limit: 100 times per hour
	API currency values updated every 30 minutes
"""

import time

import requests

import cache
from data import _currencies, _suffix, _no_space

ccache = {} if cache.read('currency_cache') is None else cache.read('currency_cache')

def validate_currency(*currencies):
	""" some validation checks before doing anything """
	validated_currency = []
	if not currencies:
		raise ValueError('My function need something to run, duh')
	for currency in currencies:
		currency = currency.upper()
		if not isinstance(currency, str):
			raise TypeError('Currency code should be a string: ' + repr(currency))
		if currency not in _currencies:
			raise NameError('Currency code not found: ' + repr(currency))
		validated_currency.append(currency)
	return validated_currency[0] if len(validated_currency) == 1 else validated_currency

def validate_price(price):
	""" validation checks for price argument """
	if isinstance(price, str):
		try:
			price = int(price)
		except ValueError: # fallback if convert to int failed
			price = float(price)
	if not isinstance(price, (int, float)):
		raise TypeError('Price should be a number: ' + repr(price))
	return price

def info(currency):
	""" return all info about currency """
	currency = validate_currency(currency)
	return _currencies[currency]

def code(currency):
	""" return symbol of currency """
	currency = validate_currency(currency)
	return _currencies[currency]['code']

def name(currency, *, plural=False):
	""" return name of currency """
	currency = validate_currency(currency)
	if plural:
		return _currencies[currency]['name_plural']
	return _currencies[currency]['name']

def symbol(currency, *, native=True):
	""" return symbol of currency """
	currency = validate_currency(currency)
	if native:
		return _currencies[currency]['symbol_native']
	return _currencies[currency]['symbol']

def decimals(currency):
	""" return maximum decimal digits of currency """
	currency = validate_currency(currency)
	return _currencies[currency]['decimal_digits']

def roundto(currency):
	""" return currency increment used for rounding """
	currency = validate_currency(currency)
	return _currencies[currency]['rounding']

def rounding(price, currency):
	""" rounding currency value based on its max decimal digits """
	currency = validate_currency(currency)
	price = validate_price(price)
	if decimals(currency) == 0:
		return round(int(price), decimals(currency))
	return round(price, decimals(currency))

def issuffix(currency):
	""" check if currency symbol is after price number unlike the majority """
	return currency in _suffix

def nospace(currency):
	""" check if currency do not need a space between symbol and price number """
	return currency in _no_space

def pretty(price, currency, *, abbrev=True):
	""" return format price with symbol. Example format(100, 'USD') return $100 """
	currency = validate_currency(currency)
	price = validate_price(price)
	space = '' if nospace(currency) else ' '
	fmtstr = ''
	if isinstance(price, int):
		fmtstr = '{:0,d}'.format(price)
	else: # float
		fmtstr = '{:0,.2f}'.format(price)
	if abbrev: # use currency symbol
		if issuffix(currency):
			return fmtstr + space + symbol(currency)
		return symbol(currency) + space + fmtstr
	return fmtstr + ' ' + code(currency) # use currency code

def check_update(from_currency, to_currency):
	""" check if last update is over 30 mins ago. if so return True to update, else False """
	# if currency never get converted before
	if from_currency not in ccache:
		ccache[from_currency] = {}
	if ccache[from_currency].get(to_currency) is None:
		ccache[from_currency][to_currency] = {'last_update': 0}
	last_update = float(ccache[from_currency][to_currency]['last_update'])
	if time.time() - last_update >= 30 * 60: # if last update is more than 30 min ago
		return True
	return False

def update_cache(from_currency, to_currency):
	""" update from_currency to_currency pair in cache if
	last update for that pair is over 30 minutes ago by request API info """
	if check_update(from_currency, to_currency) is True:
		ccache[from_currency][to_currency]['value'] = convert_using_api(from_currency, to_currency)
		ccache[from_currency][to_currency]['last_update'] = time.time()
		cache.write(ccache, 'currency_cache')

def convert_using_api(from_currency, to_currency):
	""" convert from from_currency to to_currency by requesting API """
	convert_str = from_currency + '_' + to_currency
	options = {'compact': 'ultra', 'q': convert_str}
	api_url = 'https://free.currencyconverterapi.com/api/v5/convert'
	result = requests.get(api_url, params=options).json()
	return result[convert_str]

def convert(from_currency, to_currency, from_currency_price=1):
	""" convert from from_currency to to_currency using cached info """
	from_currency, to_currency = validate_currency(from_currency, to_currency)
	update_cache(from_currency, to_currency)
	return ccache[from_currency][to_currency]['value'] * from_currency_price

def main():
	fr = 'USD'
	to = 'VND'
	# print('WARNING: API limit 100 calls per hour')
	# print('1 {} worths {} {}'.format(fr, convert(fr, to), to))

if __name__ == '__main__':
	main()

# vim: nofoldenable
