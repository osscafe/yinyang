# Cross-Browser Split 1.0.1 for CoffeeScript
# (c) Tsutomu Kawamura @OSSCafe; just converting to CoffeeScript
# (c) Steven Levithan <stevenlevithan.com>; MIT License
# An ECMA-compliant, uniform cross-browser split method */

if !cbSplit
	cbSplit = (str, separator, limit) ->
		# if `separator` is not a regex, use the native `split`
		return cbSplit._nativeSplit.call str, separator, limit if Object::toString.call(separator) isnt "[object RegExp]"
	
		output = []
		lastLastIndex = 0
		flags = (if separator.ignoreCase then "i" else "") + (if separator.multiline then "m" else "") + (if separator.sticky then "y" else "")
		separator = RegExp separator.source, flags + "g" # make `global` and avoid `lastIndex` issues by working with a copy
		str = str + "" # type conversion
		separator2 = RegExp "^" + separator.source + "$(?!\\s)", flags if !cbSplit._compliantExecNpcg # doesn't need /g or /y, but they don't hurt
	
		# behavior for `limit`: if it's...
		# - `undefined`: no limit.
		# - `NaN` or zero: return an empty array.
		# - a positive number: use `Math.floor(limit)`.
		# - a negative number: no limit.
		# - other: type-convert, then use the above rules.
		if !limit? || +limit < 0
			limit = Infinity
		else
			limit = Math.floor(+limit)
			return [] if !limit
	
		while match = separator.exec str
			lastIndex = match.index + match[0].length # `separator.lastIndex` is not reliable cross-browser
	
			if lastIndex > lastLastIndex
				output.push str.slice(lastLastIndex, match.index)
	
				# fix browsers whose `exec` methods don't consistently return `undefined` for nonparticipating capturing groups
				if !cbSplit._compliantExecNpcg && match.length > 1
					match[0].replace separator2, () ->
						match[i] = undefined for i in [1..(arguments.length-2)] when !arguments[i]?
	
				Array::push.apply output, match.slice(1) if match.length > 1 && match.index < str.length
	
				lastLength = match[0].length
				lastLastIndex = lastIndex
	
				break if output.length >= limit
	
			separator.lastIndex++ if separator.lastIndex == match.index # avoid an infinite loop
	
		if lastLastIndex == str.length
			output.push "" if lastLength || !separator.test ""
		else
			output.push str.slice(lastLastIndex)
	
		if output.length > limit then output.slice 0, limit else output
	
	cbSplit._compliantExecNpcg = /()??/.exec("")[1]? # NPCG: nonparticipating capturing group
	cbSplit._nativeSplit = String::split
	
# for convenience...
String::split = (separator, limit) -> cbSplit @, separator, limit