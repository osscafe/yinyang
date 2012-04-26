# [Data Plugins]	

# ajax plugin
# http://osscafe.github.com/yinyang/english/api.html#ajax
class YinYang.plugins.ajax extends YinYang.plugin
	process: ->
		$.getJSON(@arg)
		.success (data) => 
			@setValue data
		.error =>
			console?.log "ajax error"

# hsql plugin
# http://osscafe.github.com/yinyang/english/api.html#hsql
class YinYang.plugins.hsql extends YinYang.plugin
	process: ->
		$.getJSON("/hsql.php?q=#{hsql}")
		.success (data) => 
			@setValue data
		.error =>
			console?.log "hsql error"