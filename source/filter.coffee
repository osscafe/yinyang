# [Filters]

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