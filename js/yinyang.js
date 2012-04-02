(function() {
  var YinYang, cbSplit,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  YinYang = (function() {

    YinYang.version = '0.2.2';

    YinYang.plugins = {};

    YinYang.filters = {};

    YinYang.templates = {};

    YinYang.createFilter = function(str) {
      var arg, args, filter_name;
      args = str.split(':');
      filter_name = args.shift();
      args = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = args.length; _i < _len; _i++) {
          arg = args[_i];
          if (arg.match(/^[1-9][0-9]*$/)) {
            _results.push(Number(arg));
          } else {
            _results.push(arg.replace(/^\s*('|")|("|')\s*$/g, ''));
          }
        }
        return _results;
      })();
      if (YinYang.filters[filter_name] != null) {
        return new YinYang.filters[filter_name](args);
      } else {
        return new YinYang.filter(args);
      }
    };

    YinYang.getTemplate = function(url) {
      if (YinYang.templates[url] != null) {
        return YinYang.templates[url];
      } else {
        return null;
      }
    };

    YinYang.createTemplate = function(url, html) {
      var tdir;
      tdir = url.replace(/[^\/]+$/, '');
      html = html.replace(/(href|src)="((?![a-z]+:\/\/|\.\/|\/|\#).*?)"/g, function() {
        return "" + arguments[1] + "=\"" + tdir + arguments[2] + "\" ";
      });
      return this.templates[url] = new YinYang.Template(html);
    };

    YinYang.guid = function() {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r, v;
        r = Math.random() * 16 | 0;
        v = c === 'x' ? r : r & 3 | 8;
        return v.toString(16);
      }).toUpperCase();
    };

    YinYang.prototype.template = null;

    YinYang.prototype.document_meta = {};

    YinYang.prototype.selfload = false;

    function YinYang() {
      this.build = __bind(this.build, this);      this.setup();
    }

    YinYang.prototype.setup = function() {
      var meta, name, _i, _len, _ref, _results;
      _ref = $('meta');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        meta = _ref[_i];
        if (!($(meta).attr('content') != null)) continue;
        name = $(meta).attr('name') || $(meta).attr('property');
        if (name === 'yinyang:selfload' && $(meta).attr('content') === 'true') {
          _results.push(this.selfload = true);
        } else {
          name = name.replace(/[^a-zA-Z0-9_]/g, '_');
          _results.push(this.document_meta[name] = $(meta).attr('content'));
        }
      }
      return _results;
    };

    YinYang.prototype.fetch = function(url) {
      var _this = this;
      if (this.selfload) {
        this.redrawAll(this.build(location.href, $('html').html()));
      }
      if (url) {
        return $.ajax({
          url: url,
          success: function(html) {
            return _this.redrawAll(_this.build(url, html));
          }
        });
      }
    };

    YinYang.prototype.build = function(url, html) {
      this.template = YinYang.createTemplate(url, html);
      return this.template.display(this);
    };

    YinYang.prototype.redrawAll = function(html) {
      var attr, _i, _len, _ref, _results;
      html = html.replace(/<script.*?src=".*?yinyang.js".*?><\/script>/gim, '');
      $('body').html((html.split(/<body.*?>|<\/body>/ig))[1]);
      $('head').html((html.split(/<head.*?>|<\/head>/ig))[1]);
      _ref = $((html.match(/<body.*?>/i))[0].replace(/^\<body/i, '<div'))[0].attributes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        if (attr.name === 'class') {
          _results.push($('body').addClass(attr.value));
        } else if (attr.value && attr.value !== 'null') {
          _results.push($('body').attr(attr.name, attr.value));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return YinYang;

  })();

  YinYang.filter = (function() {

    function filter(args) {
      this.args = args;
    }

    filter.prototype._process = function(val) {
      switch (this.args.length) {
        case 0:
          return this.process(val);
        case 1:
          return this.process(val, this.args[0]);
        case 2:
          return this.process(val, this.args[0], this.args[1]);
        default:
          return this.process(val, this.args[0], this.args[1], this.args[2]);
      }
    };

    filter.prototype.process = function(val) {
      return val;
    };

    return filter;

  })();

  $('head').append('<style>body {background:#FFF} body * {display:none}</style>');

  $(function() {
    var href, yy;
    href = $('link[rel=template]').attr('href');
    yy = new YinYang;
    return yy.fetch(href);
  });

  /* -------------------------------------------- 
       Begin split.coffee 
  --------------------------------------------
  */

  if (!cbSplit) {
    cbSplit = function(str, separator, limit) {
      var flags, lastIndex, lastLastIndex, lastLength, match, output, separator2;
      if (Object.prototype.toString.call(separator) !== "[object RegExp]") {
        return cbSplit._nativeSplit.call(str, separator, limit);
      }
      output = [];
      lastLastIndex = 0;
      flags = (separator.ignoreCase ? "i" : "") + (separator.multiline ? "m" : "") + (separator.sticky ? "y" : "");
      separator = RegExp(separator.source, flags + "g");
      str = str + "";
      if (!cbSplit._compliantExecNpcg) {
        separator2 = RegExp("^" + separator.source + "$(?!\\s)", flags);
      }
      if (!(limit != null) || +limit < 0) {
        limit = Infinity;
      } else {
        limit = Math.floor(+limit);
        if (!limit) return [];
      }
      while (match = separator.exec(str)) {
        lastIndex = match.index + match[0].length;
        if (lastIndex > lastLastIndex) {
          output.push(str.slice(lastLastIndex, match.index));
          if (!cbSplit._compliantExecNpcg && match.length > 1) {
            match[0].replace(separator2, function() {
              var i, _ref, _results;
              _results = [];
              for (i = 1, _ref = arguments.length - 2; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
                if (!(arguments[i] != null)) _results.push(match[i] = void 0);
              }
              return _results;
            });
          }
          if (match.length > 1 && match.index < str.length) {
            Array.prototype.push.apply(output, match.slice(1));
          }
          lastLength = match[0].length;
          lastLastIndex = lastIndex;
          if (output.length >= limit) break;
        }
        if (separator.lastIndex === match.index) separator.lastIndex++;
      }
      if (lastLastIndex === str.length) {
        if (lastLength || !separator.test("")) output.push("");
      } else {
        output.push(str.slice(lastLastIndex));
      }
      if (output.length > limit) {
        return output.slice(0, limit);
      } else {
        return output;
      }
    };
    cbSplit._compliantExecNpcg = /()??/.exec("")[1] != null;
    cbSplit._nativeSplit = String.prototype.split;
  }

  String.prototype.split = function(separator, limit) {
    return cbSplit(this, separator, limit);
  };

  /* -------------------------------------------- 
       Begin plugin.coffee 
  --------------------------------------------
  */

  YinYang.plugins.ajax = function(template, name, uri) {
    if (typeof console !== "undefined" && console !== null) {
      console.log("ajax request : " + uri);
    }
    return $.getJSON(uri).success(function(data) {
      template.setValue(name, data);
      return template.processPlaceholder(name);
    }).error(function() {
      return typeof console !== "undefined" && console !== null ? console.log("ajax error") : void 0;
    });
  };

  YinYang.plugins.hsql = function(template, name, hsql) {
    if (typeof console !== "undefined" && console !== null) {
      console.log("hsql request : " + hsql);
    }
    return $.getJSON("/hsql.php?q=" + hsql).success(function(data) {
      template.setValue(name, data);
      return template.processPlaceholder(name);
    }).error(function() {
      return typeof console !== "undefined" && console !== null ? console.log("hsql error") : void 0;
    });
  };

  /* -------------------------------------------- 
       Begin filter.coffee 
  --------------------------------------------
  */

  YinYang.filters["default"] = (function(_super) {

    __extends(_default, _super);

    function _default() {
      _default.__super__.constructor.apply(this, arguments);
    }

    _default.prototype.process = function(val, str) {
      if (str == null) str = '';
      return val || str;
    };

    return _default;

  })(YinYang.filter);

  YinYang.filters.nl2br = (function(_super) {

    __extends(nl2br, _super);

    function nl2br() {
      nl2br.__super__.constructor.apply(this, arguments);
    }

    nl2br.prototype.process = function(val) {
      return val.replace(/\r\n|\n|\r/gim, '<br />');
    };

    return nl2br;

  })(YinYang.filter);

  YinYang.filters.truncate = (function(_super) {

    __extends(truncate, _super);

    function truncate() {
      truncate.__super__.constructor.apply(this, arguments);
    }

    truncate.prototype.process = function(val, max, txt) {
      if (max == null) max = 80;
      if (txt == null) txt = '...';
      if (val.length > max) {
        return val.substring(0, max - txt.length) + txt;
      } else {
        return val;
      }
    };

    return truncate;

  })(YinYang.filter);

  /* -------------------------------------------- 
       Begin template.coffee 
  --------------------------------------------
  */

  YinYang.Template = (function() {

    Template.prototype.values = {
      meta: {},
      ajax: {},
      hsql: {}
    };

    Template.prototype.placeholders = {};

    Template.prototype.root = null;

    function Template(html) {
      var content, flagment, meta, name, plugin, plugin_name, plugin_names, t, var_name, _i, _j, _len, _len2, _ref, _ref2;
      plugin_names = ((function() {
        var _ref, _results;
        _ref = YinYang.plugins;
        _results = [];
        for (name in _ref) {
          plugin = _ref[name];
          _results.push(name);
        }
        return _results;
      })()).join('|');
      _ref = (html.match(new RegExp("<meta.*? name=\"(" + plugin_names + ")\\.[a-z][a-zA-Z0-9_\\.]+\".*?>", 'gim'))) || [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        meta = _ref[_i];
        var_name = $(meta).attr('name');
        plugin_name = var_name.split('.')[0];
        content = $(meta).attr('content');
        YinYang.plugins[plugin_name](this, var_name, content);
      }
      t = this.root = new YinYang.TemplateRoot(this);
      _ref2 = html.split(/(<!--\{.+?\}-->|\#\{.+?\})/gim);
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        flagment = _ref2[_j];
        if (flagment != null) t = t.add(flagment);
      }
    }

    Template.prototype.display = function(doc) {
      this.values.meta = doc.document_meta;
      return this.root.display();
    };

    Template.prototype.valueExists = function(combinedKey) {
      var attr, attrs, tv, _ref;
      attrs = combinedKey.split('.');
      tv = this.values;
      while ((tv != null) && (attr = attrs.shift())) {
        tv = (_ref = tv[attr]) != null ? _ref : null;
      }
      return tv != null;
    };

    Template.prototype.setValue = function(combinedKey, val) {
      var attr, attrs, lastattr, tv, _ref;
      attrs = combinedKey.split('.');
      lastattr = attrs.pop();
      tv = this.values;
      while (attr = attrs.shift()) {
        tv = (_ref = tv[attr]) != null ? _ref : '';
      }
      return tv[lastattr] = val;
    };

    Template.prototype.setValues = function(vals) {
      var key, val, _results;
      _results = [];
      for (key in vals) {
        if (!__hasProp.call(vals, key)) continue;
        val = vals[key];
        _results.push(this.values[key] = val);
      }
      return _results;
    };

    Template.prototype.getValue = function(combinedKey) {
      var attr, attrs, tv, _ref;
      attrs = combinedKey.split('.');
      tv = this.values;
      while (attr = attrs.shift()) {
        tv = (_ref = tv[attr]) != null ? _ref : '';
      }
      return tv;
    };

    Template.prototype.addPlaceholder = function(name, callback) {
      return this.placeholders[name] = callback;
    };

    Template.prototype.processPlaceholder = function(name) {
      if (this.placeholders[name] != null) {
        this.placeholders[name]();
        return delete this.placeholders[name];
      }
    };

    return Template;

  })();

  YinYang.TemplateRoot = (function() {

    function TemplateRoot(template, parent, value, ignore) {
      this.template = template;
      this.parent = parent != null ? parent : null;
      this.value = value != null ? value : '';
      this.ignore = ignore != null ? ignore : false;
      this.children = [];
    }

    TemplateRoot.prototype.add = function(value) {
      var re;
      re = {
        pend: /<!--\{end\}-->/,
        more: /<!--\{more\}-->/,
        pvar: /<!--\{(@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9_\.]*)(\|.*?)*\}-->/,
        ivar: /\#\{(@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9_\.]*)(\|.*?)*\}/,
        loop: /<!--\{[a-zA-Z][a-zA-Z0-9_\.]* in (@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9_\.]*)\}-->/
      };
      if (value.match(re.pend)) {
        this.ignore = false;
        return this.parent;
      } else if (value.match(re.more)) {
        this.ignore = true;
        return this;
      } else if (!this.ignore) {
        if (value.match(re.pvar)) {
          return this._add('child', new YinYang.TemplateVar(this.template, this, value.replace(/<!--{|}-->/g, ''), true));
        } else if (value.match(re.ivar)) {
          return this._add('self', new YinYang.TemplateVar(this.template, this, value.replace(/\#\{|\}/g, '')));
        } else if (value.match(re.loop)) {
          return this._add('child', new YinYang.TemplateLoop(this.template, this, value.replace(/<!--{|}-->/g, '')));
        } else {
          return this._add('self', new YinYang.TemplateText(this.template, this, value));
        }
      } else {
        return this;
      }
    };

    TemplateRoot.prototype._add = function(ret, t) {
      this.children.push(t);
      switch (ret) {
        case 'child':
          return t;
        case 'self':
          return this;
      }
    };

    TemplateRoot.prototype.display = function(localValues) {
      var child;
      if (localValues == null) localValues = {};
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = this.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(child.display(localValues));
        }
        return _results;
      }).call(this)).join('');
    };

    return TemplateRoot;

  })();

  YinYang.TemplateLoop = (function(_super) {

    __extends(TemplateLoop, _super);

    function TemplateLoop() {
      TemplateLoop.__super__.constructor.apply(this, arguments);
    }

    TemplateLoop.prototype.display = function(localValues) {
      var arrName, elName, _ref;
      this.placeholder_id = YinYang.guid();
      _ref = this.value.split(/\s+in\s+/), elName = _ref[0], arrName = _ref[1];
      if (this.template.valueExists(arrName)) {
        return this.displayLoop(localValues, elName, arrName);
      } else if (arrName.match(/^(ajax|hsql)\./)) {
        return this.diaplayPlaceholder(localValues, elName, arrName);
      } else {
        if (typeof console !== "undefined" && console !== null) {
          console.log('Template value not found.');
        }
        return '';
      }
    };

    TemplateLoop.prototype.displayLoop = function(localValues, elName, arrName) {
      var child, el, key, lv, val;
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = this.template.getValue(arrName);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          el = _ref[_i];
          _results.push(((function() {
            var _j, _len2, _ref2, _results2;
            _ref2 = this.children;
            _results2 = [];
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              child = _ref2[_j];
              lv = {};
              for (key in localValues) {
                val = localValues[key];
                lv[key] = val;
              }
              lv[elName] = el;
              _results2.push(child.display(lv));
            }
            return _results2;
          }).call(this)).join(''));
        }
        return _results;
      }).call(this)).join('');
    };

    TemplateLoop.prototype.diaplayPlaceholder = function(localValues, 　elName, arrName) {
      var _this = this;
      this.template.addPlaceholder(arrName, function() {
        var html;
        html = _this.displayLoop(localValues, elName, arrName);
        return $("#" + _this.placeholder_id).before(html).remove();
      });
      return "<span class=\"loading\" id=\"" + this.placeholder_id + "\"></span>";
    };

    return TemplateLoop;

  })(YinYang.TemplateRoot);

  YinYang.TemplateVar = (function(_super) {

    __extends(TemplateVar, _super);

    function TemplateVar(template, parent, value, ignore) {
      var f, fs;
      this.template = template;
      this.parent = parent != null ? parent : null;
      this.value = value != null ? value : '';
      this.ignore = ignore != null ? ignore : false;
      fs = this.value.split('|');
      this.value = fs.shift();
      this.filters = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = fs.length; _i < _len; _i++) {
          f = fs[_i];
          _results.push(YinYang.createFilter(f));
        }
        return _results;
      })();
      this.children = [];
    }

    TemplateVar.prototype.display = function(localValues) {
      var filter, v, _i, _len, _ref;
      this.localValues = localValues;
      v = this.value.substring(0, 1) === '@' ? this.displayDom() : this.displayVar();
      _ref = this.filters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        filter = _ref[_i];
        v = filter._process(v);
      }
      return v;
    };

    TemplateVar.prototype.displayDom = function() {
      return $(this.value.substring(1)).html();
    };

    TemplateVar.prototype.displayVar = function() {
      return (this.getLocalValue(this.value)) || this.template.getValue(this.value);
    };

    TemplateVar.prototype.getLocalValue = function(combinedKey) {
      var attr, attrs, tv, _ref;
      attrs = combinedKey.split('.');
      tv = this.localValues;
      while (attr = attrs.shift()) {
        tv = (_ref = tv[attr]) != null ? _ref : '';
      }
      return tv;
    };

    return TemplateVar;

  })(YinYang.TemplateRoot);

  YinYang.TemplateText = (function(_super) {

    __extends(TemplateText, _super);

    function TemplateText() {
      TemplateText.__super__.constructor.apply(this, arguments);
    }

    TemplateText.prototype.display = function() {
      return this.value;
    };

    return TemplateText;

  })(YinYang.TemplateRoot);

}).call(this);
