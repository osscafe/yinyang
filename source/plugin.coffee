# [Data Plugins]	

# ajax plugin
# http://osscafe.github.com/yinyang/english/api.html#ajax
class YinYang.plugins.ajax extends YinYang.plugin
	process: ->
		$.getJSON(@arg)
		.success (data) =>
			console?.log "ajax success: #{@var_name}"
			@setValue data
		.error =>
			console?.log "ajax error: #{@var_name}"

# hsql plugin
# http://osscafe.github.com/yinyang/english/api.html#hsql
class YinYang.plugins.hsql extends YinYang.plugin
	process: ->
		$.getJSON("/hsql.php?q=#{@arg}")
		.success (data) => 
			console?.log "hsql success: #{@var_name}"
			@setValue data
		.error =>
			console?.log "hsql error: #{@var_name}"