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

YinYang = 
	version: '0.2.0'
	plugins: {}
	filters: {}
	createFilter: (str) ->
		args = str.split ':'
		filter_name = args.shift()
		args = 
			for arg in args
				if arg.match /^[1-9][0-9]*$/
					(Number) arg
				else
					arg.replace /^\s*('|")|("|')\s*$/g, '' 
		if YinYang.filters[filter_name]? then new YinYang.filters[filter_name] args else new YinYang.filter args #thru
	guid: ->
		'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
			r = Math.random() * 16 | 0
			v = if c is 'x' then r else r & 3 | 8
			v.toString 16
		.toUpperCase()

# [Data Plugins]
# ajax plugin
# http://osscafe.github.com/yinyang/english/api.html#ajax
YinYang.plugins.ajax = (template, name, uri) ->
	console?.log "ajax request : #{uri}"
	$.getJSON(uri)
	.success (data) ->
		template.setValue name, data
		template.processPlaceholder name
	.error ->
		console?.log "ajax error"

# hsql plugin
# http://osscafe.github.com/yinyang/english/api.html#hsql
YinYang.plugins.hsql = (template, name, hsql) ->
	console?.log "hsql request : #{hsql}"
	$.getJSON("/hsql.php?q=#{hsql}")
	.success (data) ->
		#console?.log data
		template.setValue name, data
		template.processPlaceholder name
	.error ->
		console?.log "hsql error"

# [Filters]
# thru filter
class YinYang.filter
	constructor: (@args) ->
	_process: (val) ->
		switch @args.length
			when 0 then @process val
			when 1 then @process val, @args[0]
			when 2 then @process val, @args[0], @args[1]
			else @process val, @args[0], @args[1], @args[2]
	process: (val) -> val

# default filter
# http://osscafe.github.com/yinyang/english/api.html#filter|default
class YinYang.filters.default extends YinYang.filter
	process: (val, str = '') -> val || str

# nl2br filter
# http://osscafe.github.com/yinyang/english/api.html#filter|nl2br
class YinYang.filters.nl2br extends YinYang.filter
	process: (val) -> val.replace /\r\n|\n|\r/gim, '<br />'

# truncate filter
# http://osscafe.github.com/yinyang/english/api.html#filter|truncate
class YinYang.filters.truncate extends YinYang.filter
	process: (val, max = 80, txt = '...') -> if val.length > max then val.substring(0, max - txt.length) + txt else val

# date_format filter
# http://osscafe.github.com/yinyang/english/api.html#filter|date_format
#class YinYang.filters.date_format extends YinYang.filter
#	process: (val, format) -> strftime format, val

# [Template Classes]
class Template
	@values:
		meta: {} # META tag properties of the original document
		ajax: {} # Data requested via Ajax 
		hsql: {} # Data requested via hSQL
		
	@placeholders: {}
		
	@setup: ->
		$('meta').each (index) ->
			if $(@).attr('name')?
				Template.values.meta[$(@).attr('name').replace /[^a-zA-Z0-9_]/g, '_'] = $(@).attr('content')
			else if $(@).attr('property')?
				Template.values.meta[$(@).attr('property').replace /[^a-zA-Z0-9_]/g, '_'] = $(@).attr('content')
			#console?.log Template.values
	
	@fetch: (html) ->
		plugin_names = (name for name, plugin of YinYang.plugins).join '|'
		for meta in html.match new RegExp """<meta.*? name="(#{plugin_names})\\.[a-z][a-zA-Z0-9_\\.]+".*?>""", 'gim'
			var_name = $(meta).attr 'name'
			plugin_name = var_name.split('.')[0]
			content = $(meta).attr 'content'
			YinYang.plugins[plugin_name] this, var_name, content
	
		t = template = new Template
		t = t.add flagment for flagment in html.split /(<!--\{.+?\}-->|\#\{.+?\})/gim when flagment?
		#console?.log template
		template.display()
		
	@valueExists: (combinedKey) ->
		attrs = combinedKey.split '.'
		tv = Template.values
		tv = tv[attr] ? null while tv? and attr = attrs.shift()
		tv?
		
	@setValue: (combinedKey, val) ->
		attrs = combinedKey.split '.'
		lastattr = attrs.pop()
		tv = Template.values
		tv = tv[attr] ? '' while attr = attrs.shift()
		tv[lastattr] = val

	@setValues: (vals) -> Template.values[key] = val for own key, val of vals
		
	@getValue: (combinedKey) ->
		attrs = combinedKey.split '.'
		tv = Template.values
		tv = tv[attr] ? '' while attr = attrs.shift()
		tv
		
	@addPlaceholder: (name, callback) ->
		@placeholders[name] = callback
		
	@processPlaceholder: (name) ->
		if @placeholders[name]?
			@placeholders[name]()
			delete @placeholders[name]

	constructor: (@parent = null, @value = '', @ignore = false) ->
		@children = []
		
	add: (value) ->
		re = 
			pend: /<!--\{end\}-->/
			more: /<!--\{more\}-->/
			pvar: /<!--\{(@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9_\.]*)(\|.*?)*\}-->/
			ivar: /\#\{(@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9_\.]*)(\|.*?)*\}/
			loop: /<!--\{[a-zA-Z][a-zA-Z0-9_\.]* in (@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9_\.]*)\}-->/
		if value.match re.pend then @ignore = false; @parent
		else if value.match re.more then @ignore = true; @
		else unless @ignore
			if value.match re.pvar then @_add 'child', new TemplateVar @, value.replace(/<!--{|}-->/g, ''), true
			else if value.match re.ivar then @_add 'self', new TemplateVar @, value.replace /\#\{|\}/g, ''
			else if value.match re.loop then @_add 'child', new TemplateLoop @, value.replace /<!--{|}-->/g, ''
			else @_add 'self', new TemplateText @, value
		else  @
	_add: (ret, t) ->
		@children.push t
		switch ret
			when 'child' then t
			when 'self' then @
	display: (localValues = {}) -> (child.display localValues for child in @children).join ''
	
class TemplateLoop extends Template
	display: (localValues) ->
		@placeholder_id = YinYang.guid()
		[elName, arrName] = @value.split /\s+in\s+/
		if Template.valueExists arrName
			@displayLoop localValues, elName, arrName
		else if arrName.match /^(ajax|hsql)\./
			@diaplayPlaceholder localValues, elName, arrName
		else
			console?.log 'Template value not found.'
			''
	displayLoop: (localValues, elName, arrName) ->
		(for el in Template.getValue arrName
			(for child in @children
				lv = {}
				lv[key] = val for key, val of localValues
				lv[elName] = el
				child.display lv
			).join ''
		).join ''
	diaplayPlaceholder: (localValues,　elName, arrName) ->
		Template.addPlaceholder arrName, =>
			html = @displayLoop localValues, elName, arrName
			$("##{@placeholder_id}").before(html).remove()
		"""<span class="loading" id="#{@placeholder_id}"></span>"""
	
class TemplateVar extends Template
	constructor: (@parent = null, @value = '', @ignore = false) ->
		fs = @value.split '|'
		@value = fs.shift()
		@filters = (YinYang.createFilter f for f in fs)
		@children = []
	display: (localValues) ->
		@localValues = localValues
		v = if @value.substring(0, 1) == '@' then @displayDom() else @displayVar()
		v = filter._process v for filter in @filters
		v
	displayDom: -> $(@value.substring 1).html()
	displayVar: -> (@getLocalValue @value) or Template.getValue @value
	getLocalValue: (combinedKey) ->
		attrs = combinedKey.split '.'
		tv = @localValues
		tv = tv[attr] ? '' while attr = attrs.shift()
		tv
	
class TemplateText extends Template
	display: -> @value
		
# Loading Style Sheet
$('head').append('<style>body {background:#FFF} body * {display:none}</style>')

# Setup
$ () ->
	Template.setup()
	href = $('link[rel=template]').attr('href')
	$.ajax
		url: href,
		success: (html)->
			tdir = href.replace /[^\/]+$/, ''
			html = html.replace /(href|src)="((?![a-z]+:\/\/|\.\/|\/|\#).*?)"/g, () -> """#{arguments[1]}="#{tdir}#{arguments[2]}" """
			html = Template.fetch html
			#if !$.browser.msie
			#	$('html').html (html.split /(<html.*?>|<\/html>)/ig)[2]
			#	return
			$('body').html (html.split /<body.*?>|<\/body>/ig)[1]
			$('head').html (html.split /<head.*?>|<\/head>/ig)[1]
			for attr in $((html.match /<body.*?>/)[0].replace /^\<body/, '<div')[0].attributes
				if attr.name == 'class'
					$('body').addClass attr.value
				else if attr.value && attr.value != 'null'
					$('body').attr attr.name, attr.value