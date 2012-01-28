(function() {
  var Template, TemplateLoop, TemplateText, TemplateVar, href,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Template = (function() {

    Template.values = {
      meta: {}
    };

    Template.setup = function() {
      $('meta').each(function(index) {
        return Template.values.meta[$(this).attr('name')] = $(this).attr('content');
      });
      return Template.values;
    };

    Template.create = function(html) {
      var flagment, t, template, _i, _len, _ref;
      t = template = new Template;
      _ref = html.split(/(<!--\{.+?\}-->|\#\{.+?\})/gim);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        flagment = _ref[_i];
        if (flagment != null) t = t.add(flagment);
      }
      console.log(template);
      return template;
    };

    Template.setValue = function(key, val) {
      return Template.values[key] = val;
    };

    Template.setValues = function(vals) {
      var key, val, _results;
      _results = [];
      for (key in vals) {
        if (!__hasProp.call(vals, key)) continue;
        val = vals[key];
        _results.push(Template.values[key] = val);
      }
      return _results;
    };

    Template.getValue = function(combinedKey) {
      var attr, attrs, tv, _ref;
      attrs = combinedKey.split('.');
      tv = Template.values;
      while (attr = attrs.shift()) {
        tv = (_ref = tv[attr]) != null ? _ref : '';
      }
      return tv;
    };

    function Template(parent, value, ignore) {
      this.parent = parent != null ? parent : null;
      this.value = value != null ? value : '';
      this.ignore = ignore != null ? ignore : false;
      this.children = [];
    }

    Template.prototype.add = function(value) {
      var re;
      re = {
        pend: /<!--\{end\}-->/,
        more: /<!--\{more\}-->/,
        pvar: /<!--\{(@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9\.]*)\}-->/,
        ivar: /\#\{(@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9\.]*)\}/,
        loop: /<!--\{[a-zA-Z][a-zA-Z0-9\.]* in (@[a-zA-Z0-9_\.\#>=\[\]]+|[a-zA-Z][a-zA-Z0-9\.]*)\}-->/
      };
      if (value.match(re.pend)) {
        this.ignore = false;
        return this.parent;
      } else if (value.match(re.more)) {
        this.ignore = true;
        return this;
      } else if (!this.ignore) {
        if (value.match(re.pvar)) {
          return this._add('child', new TemplateVar(this, value.replace(/<!--{|}-->/g, ''), true));
        } else if (value.match(re.ivar)) {
          return this._add('self', new TemplateVar(this, value.replace(/\#\{|\}/g, '')));
        } else if (value.match(re.loop)) {
          return this._add('child', new TemplateLoop(this, value.replace(/<!--{|}-->/g, '')));
        } else {
          return this._add('self', new TemplateText(this, value));
        }
      } else {
        return this;
      }
    };

    Template.prototype._add = function(ret, t) {
      this.children.push(t);
      switch (ret) {
        case 'child':
          return t;
        case 'self':
          return this;
      }
    };

    Template.prototype.display = function(localValues) {
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

    return Template;

  })();

  TemplateLoop = (function(_super) {

    __extends(TemplateLoop, _super);

    function TemplateLoop() {
      TemplateLoop.__super__.constructor.apply(this, arguments);
    }

    TemplateLoop.prototype.display = function(localValues) {
      var arrName, child, el, elName, key, lv, val, _ref;
      _ref = this.value.split(/\s+in\s+/), elName = _ref[0], arrName = _ref[1];
      return ((function() {
        var _i, _len, _ref2, _results;
        _ref2 = Template.getValue(arrName);
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          el = _ref2[_i];
          _results.push(((function() {
            var _j, _len2, _ref3, _results2;
            _ref3 = this.children;
            _results2 = [];
            for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
              child = _ref3[_j];
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

    return TemplateLoop;

  })(Template);

  TemplateVar = (function(_super) {

    __extends(TemplateVar, _super);

    function TemplateVar() {
      TemplateVar.__super__.constructor.apply(this, arguments);
    }

    TemplateVar.prototype.display = function(localValues) {
      this.localValues = localValues;
      if (this.value[0] === '@') {
        return this.displayDom();
      } else {
        return this.displayVar();
      }
    };

    TemplateVar.prototype.displayDom = function() {
      return $(this.value.substring(1)).html();
    };

    TemplateVar.prototype.displayVar = function() {
      return (this.getLocalValue(this.value)) || Template.getValue(this.value);
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

  })(Template);

  TemplateText = (function(_super) {

    __extends(TemplateText, _super);

    function TemplateText() {
      TemplateText.__super__.constructor.apply(this, arguments);
    }

    TemplateText.prototype.display = function() {
      return this.value;
    };

    return TemplateText;

  })(Template);

  Template.setup();

  Template.setValues({
    links: [
      {
        title: 'Home',
        url: '/'
      }, {
        title: 'About',
        url: '/about.html'
      }, {
        title: 'Documents',
        url: '/docs.html'
      }
    ],
    posts: [
      {
        title: 'Blog 1',
        lead: 'Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Maecenas faucibus mollis interdum.'
      }, {
        title: 'Blog 2',
        lead: 'Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Maecenas faucibus mollis interdum.'
      }, {
        title: 'Blog 3',
        lead: 'Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Maecenas faucibus mollis interdum.'
      }
    ]
  });

  href = $('link[rel=template]').attr('href');

  $.ajax({
    url: href,
    success: function(html) {
      var template;
      template = Template.create(html);
      html = template.display();
      return $('html').html((html.split(/(<html.*?>|<\/html>)/ig))[2]);
    }
  });

}).call(this);
