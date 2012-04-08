# YinYang
# http://osscafe.github.com/yinyang/
#
# YinYang is a client side template and framework. It collates documents
# and templates as well as data retrieved by Ajax etc, and renders it as
# a single page via JavaScript.
#
# The MIT License
# Copyright © 2012, CogniTom Academic Design & Tsutomu Kawamura.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the “Software”), to deal in 
# the Software without restriction, including without limitation the rights to use, 
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
# Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class YinYang
	@version: '0.2.2'
	@plugins: {}
	@filters: {}
	@templates: {}
	@createFilter: (str) ->
		args = str.split ':'
		filter_name = args.shift()
		args =
			for arg in args
				if arg.match /^[1-9][0-9]*$/ then (Number) arg else arg.replace /^\s*('|")|("|')\s*$/g, ''
		if YinYang.filters[filter_name]? then new YinYang.filters[filter_name] args else new YinYang.filter args #thru
	@getTemplate: (url) -> if YinYang.templates[url]? then YinYang.templates[url] else null
	@createTemplate: (url, html) ->
		tdir = url.replace /[^\/]+$/, ''
		html = html.replace /(href|src)="((?![a-z]+:\/\/|\.\/|\/|\#).*?)"/g, () -> """#{arguments[1]}="#{tdir}#{arguments[2]}" """
		@templates[url] = new YinYang.Template html
	@guid: ->
		'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
			r = Math.random() * 16 | 0
			v = if c is 'x' then r else r & 3 | 8
			v.toString 16
		.toUpperCase()
	
	template: null
	document_meta: {}
	selfload: false
	constructor: () -> @setup()
	setup: ->
		for meta in $('meta') when $(meta).attr('content')?
			name = $(meta).attr('name') or $(meta).attr('property')
			if name == 'yinyang:selfload' && $(meta).attr('content') == 'true'
				@selfload = true
			else
				name = name.replace /[^a-zA-Z0-9_]/g, '_'
				@document_meta[name] = $(meta).attr('content')
	fetch: (url) ->
		if @selfload
			html = $('html').html()
			html = html.replace /#%7B(.*?)%7D/gm, '#{$1}' # fix FireFox issue
			html = html.replace /<script.*?>.*?<\/script>/gim, '' # avoid loading scripts twice
			@redrawAll @build location.href, html
		if url then $.ajax url: url, success: (html) => @redrawAll @build url, html
	build: (url, html) =>
		@template = YinYang.createTemplate url, html
		@template.display @
	redrawAll: (html) ->
		$('body').html (html.split /<body.*?>|<\/body>/ig)[1]
		$('head').html (html.split /<head.*?>|<\/head>/ig)[1]
		for attr in $((html.match /<body.*?>/i)[0].replace /^\<body/i, '<div')[0].attributes
			if attr.name == 'class'
				$('body').addClass attr.value
			else if attr.value && attr.value != 'null'
				$('body').attr attr.name, attr.value

class YinYang.filter
	constructor: (@args) ->
	_process: (val) ->
		switch @args.length
			when 0 then @process val
			when 1 then @process val, @args[0]
			when 2 then @process val, @args[0], @args[1]
			else @process val, @args[0], @args[1], @args[2]
	process: (val) -> val

# Setup
$('head').append '<style>body {background:#FFF} body * {display:none}</style>' # Loading Style Sheet
$ () ->
	href = $('link[rel=template]').attr('href')
	yy = new YinYang
	yy.fetch href # fetch template from url