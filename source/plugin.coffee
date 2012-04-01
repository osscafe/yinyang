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