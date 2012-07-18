# [Template Classes]

# Template Controler
class YinYang.Template
	values:
		meta: {} # META tag properties of the original document
		ajax: {} # Data requested via Ajax 
		hsql: {} # Data requested via hSQL
	placeholders: {}
	datasource: {}
	root: null
	constructor: (html) ->
		plugin_names = (name for name, plugin of YinYang.plugins).join '|'
		for meta in (html.match new RegExp """<meta.*? name="(#{plugin_names})\\.[a-z][a-zA-Z0-9_\\.]+".*?>""", 'gim') or []
			var_name = $(meta).attr 'name'
			plugin_name = var_name.split('.')[0]
			content = $(meta).attr 'content'
			@datasource[var_name] = new YinYang.plugins[plugin_name] this, var_name, content
		t = @root = new YinYang.TemplateRoot @
		t = t.add flagment for flagment in html.split /(<!--\{.+?\}-->|\#\{.+?\})/gim when flagment?
	display: (doc) ->
		@values.meta = doc.document_meta # copy from document_meta
		@root.display()	
	setValue: (combinedKey, val) ->
		attrs = combinedKey.split '.'
		lastattr = attrs.pop()
		tv = @values
		tv = tv[attr] ? '' while attr = attrs.shift()
		tv[lastattr] = val
	setValues: (vals) -> @values[key] = val for own key, val of vals
	getValue: (combinedKey, tv = @values) ->
		attrs = combinedKey.split '.'
		tv = tv[attr] ? '' while attr = attrs.shift()
		tv
	valueExists: (combinedKey, tv = @values) ->
		attrs = combinedKey.split '.'
		tv = tv[attr] ? null while tv? and attr = attrs.shift()
		tv?
	addPlaceholder: (uid, name, callback) ->
		@placeholders[uid] = 
			name: name
			callback: callback
	processPlaceholder: (name, data) ->
		for uid, placeholder of @placeholders when placeholder.name.match new RegExp "^#{name}($|\\.|\\[)"
			placeholder.callback data
			#console?.log "@placeholders['#{uid}'] processed"
			delete @placeholders[uid]
		true

# Root Node
class YinYang.TemplateRoot
	constructor: (@template, @parent = null, @value = '', @ignore = false) ->
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
			if value.match re.pvar then @_add 'child', new YinYang.TemplateVar @template, @, value.replace(/<!--{|}-->/g, ''), true
			else if value.match re.ivar then @_add 'self', new YinYang.TemplateVar @template, @, value.replace /\#\{|\}/g, ''
			else if value.match re.loop then @_add 'child', new YinYang.TemplateLoop @template, @, value.replace /<!--{|}-->/g, ''
			else @_add 'self', new YinYang.TemplateText @template, @, value
		else  @
	_add: (ret, t) ->
		@children.push t
		switch ret
			when 'child' then t
			when 'self' then @
	display: (localValues = {}) -> (child.display localValues for child in @children).join ''
	
# Loop Node
class YinYang.TemplateLoop extends YinYang.TemplateRoot
	display: (localValues) ->
		@placeholder_id = YinYang.guid()
		[elName, arrName] = @value.split /\s+in\s+/
		if @template.valueExists arrName, localValues
			#console?.log "localValue:#{@value}"
			#console?.log localValues
			@displayLoop localValues, elName, (@template.getValue arrName, localValues)
		else if @template.valueExists arrName
			#console?.log "templateValue:#{@value}"
			@displayLoop localValues, elName, (@template.getValue arrName)
		else if arrName.match /^(ajax|hsql)\./
			#console?.log "placeholder:#{@value}"
			@diaplayPlaceholder localValues, elName, arrName
		else
			console?.log "not found:#{@value}"
			console?.log localValues
			''
	displayLoop: (localValues, elName, loopObj) ->
		(for el in loopObj
			(for child in @children
				lv = {}
				lv[key] = val for key, val of localValues
				lv[elName] = el
				child.display lv
			).join ''
		).join ''
	diaplayPlaceholder: (localValues, elName, arrName) ->
		@template.addPlaceholder @placeholder_id, arrName, (data) =>
			html = @displayLoop localValues, elName, data
			$("##{@placeholder_id}").before(html).remove()
		"""<span class="loading" id="#{@placeholder_id}"></span>"""
	
# Variable Node
class YinYang.TemplateVar extends YinYang.TemplateRoot
	constructor: (@template, @parent = null, @value = '', @ignore = false) ->
		fs = @value.split '|'
		@value = fs.shift()
		@filters = (YinYang.createFilter f for f in fs)
		@children = []
	display: (localValues) ->
		@localValues = localValues
		v = if @value.substring(0, 1) == '@' then @displayDom() else @displayVar()
		v = filter._process v for filter in @filters
		#console?.log @value + ':' + v #for debug
		v
	displayDom: -> $(@value.substring 1).html()
	displayVar: -> (@template.getValue @value, @localValues) or (@template.getValue @value)
	
# Text Node
class YinYang.TemplateText extends YinYang.TemplateRoot
	display: -> @value
