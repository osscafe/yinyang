class Template
	@values:
		meta: {}
		
	@setup: ->
		$('meta').each (index) -> Template.values.meta[$(@).attr('name')] = $(@).attr('content')
		Template.values
	
	@create: (html) ->
		t = template = new Template
		t = t.add flagment for flagment in html.split /(<!--\{.+?\}-->|\#\{.+?\})/gim when flagment?
		console.log template
		template
		
	@setValue: (key, val) -> Template.values[key] = val

	@setValues: (vals) -> Template.values[key] = val for own key, val of vals
		
	@getValue: (combinedKey) ->
		attrs = combinedKey.split '.'
		tv = Template.values
		tv = tv[attr] ? '' while attr = attrs.shift()
		tv

	constructor: (@parent = null, @value = '', @ignore = false) ->
		@children = []
		
	add: (value) ->
		re = 
			pend: /<!--\{end\}-->/
			more: /<!--\{more\}-->/
			pvar: /<!--\{(@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9\.]*)\}-->/
			ivar: /\#\{(@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9\.]*)\}/
			loop: /<!--\{[a-zA-Z][a-zA-Z0-9\.]* in (@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9\.]*)\}-->/
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
		[elName, arrName] = @value.split /\s+in\s+/
		(for el in Template.getValue arrName
			(for child in @children
				lv = {}
				lv[key] = val for key, val of localValues
				lv[elName] = el
				child.display lv
			).join ''
		).join ''
	
class TemplateVar extends Template
	display: (localValues) ->
		@localValues = localValues
		if @value[0] == '@' then @displayDom() else @displayVar()
	displayDom: -> $(@value.substring 1).html()
	displayVar: -> (@getLocalValue @value) or Template.getValue @value
	getLocalValue: (combinedKey) ->
		attrs = combinedKey.split '.'
		tv = @localValues
		tv = tv[attr] ? '' while attr = attrs.shift()
		tv
	
class TemplateText extends Template
	display: -> @value
		

Template.setup()

Template.setValues
	links: [
		title:'Home'
		url:'/'
	,
		title:'About'
		url:'/about.html'
	,
		title:'Documents'
		url:'/docs.html'
	]
	posts: [
		title:'Blog 1'
		lead:'Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Maecenas faucibus mollis interdum.'
	,
		title:'Blog 2'
		lead:'Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Maecenas faucibus mollis interdum.'
	,
		title:'Blog 3'
		lead:'Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Maecenas faucibus mollis interdum.'
	]	
	
href = $('link[rel=template]').attr('href')
$.ajax
	url: href,
	success: (html)->
		template = Template.create html
		html = template.display()
		$('html').html (html.split /(<html.*?>|<\/html>)/ig)[2]