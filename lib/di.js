(function() {
  var Container, EventEmitter;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  EventEmitter = (require('events')).EventEmitter;
  Container = (function() {
    __extends(Container, EventEmitter);
    function Container(config) {
      if (config == null) {
        config = {};
      }
      this.config = this.parseConfig(config);
      this.resolving = {};
      this.resolved = {};
      this.required = {};
      void 0;
    }
    Container.prototype.loadConfig = function(file) {
      return this.addConfig(require(file));
    };
    Container.prototype.addConfig = function(config) {
      var key, parsedConfig, val, _results;
      parsedConfig = this.parseConfig(config);
      _results = [];
      for (key in parsedConfig) {
        val = parsedConfig[key];
        if (this.config[key] != null) {
          throw new Error("" + key + " already exists");
        }
        _results.push(this.config[key] = val);
      }
      return _results;
    };
    Container.prototype.parseConfig = function(config) {
      var key, result, val, _fn;
      result = {};
      _fn = __bind(function(key, val) {
        return result[key] = this.parseConfigItem(val);
      }, this);
      for (key in config) {
        val = config[key];
        _fn(key, val);
      }
      return result;
    };
    Container.prototype.parseConfigItem = function(item) {
      var child, name, _ref;
      if (item.loadConfig) {
        item = require(item.loadConfig);
      }
      if (item.children != null) {
        _ref = item.children;
        for (name in _ref) {
          child = _ref[name];
          if (typeof child === 'string') {
            continue;
          }
          item.children[name] = this.parseConfigItem(child);
        }
      }
      return item;
    };
    Container.prototype.get = function(id, callback) {
      var diConfig;
      if (this.resolved[id] != null) {
        callback(this.resolved[id]);
      }
      diConfig = this.getDiConfig(id);
      if (!(diConfig != null)) {
        throw new Error("Can not resolve " + id);
      }
      this.getWithStack(id, [], __bind(function(resolved) {
        if (!(diConfig.store != null) || diConfig.store) {
          this.resolved[id] = resolved;
        }
        return callback(resolved);
      }, this));
      return;
    };
    Container.prototype.getWithStack = function(id, stack, callback) {
      var diConfig, key, required, resolvedAsParam, service;
      if (((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = stack.length; _i < _len; _i++) {
          service = stack[_i];
          if (service === id) {
            _results.push(service);
          }
        }
        return _results;
      })()).length > 0) {
        throw new Error("Circular dependency for " + id);
      }
      stack.push(id);
      resolvedAsParam = this.resolveParam(id);
      if (resolvedAsParam != null) {
        return callback(resolvedAsParam);
      }
      diConfig = this.getDiConfig(id);
      if (diConfig.injectCallback != null) {
        return this.getServiceThroughCallbackInjection(id, stack, callback);
      }
      required = this.require(id);
      if (((function() {
        var _results;
        _results = [];
        for (key in diConfig) {
          if (key === 'call' || key === 'instantiate' || key === 'inject' || key === 'callback') {
            _results.push(key);
          }
        }
        return _results;
      })()).length === 0) {
        return callback(required);
      }
      if (this.isResolving(id)) {
        return this.on("async." + id, function(service) {
          return callback(service);
        });
      } else {
        this.setResolving(id);
        if (!(diConfig.inject != null)) {
          return this.handleAsync(id, this.instantiate(required, diConfig), diConfig, callback);
        }
        this.resolveInjection(diConfig.inject, stack, __bind(function() {
          var services;
          services = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return this.handleAsync(id, this.instantiate.apply(this, [required, diConfig].concat(__slice.call(services))), diConfig, callback);
        }, this));
        return;
      }
    };
    Container.prototype.resolveInjection = function(items, stack, parentCallback) {
      var next, resolved;
      resolved = [];
      next = __bind(function() {
        var nextService;
        nextService = items.shift();
        if (!(nextService != null)) {
          return parentCallback.apply(null, resolved);
        }
        return this.getWithStack(nextService, stack, __bind(function(resolvedService) {
          var service, _i, _len;
          for (_i = 0, _len = stack.length; _i < _len; _i++) {
            service = stack[_i];
            if (service === !nextService) {
              stack = service;
            }
          }
          resolved.push(resolvedService);
          return next();
        }, this));
      }, this);
      next();
      return;
    };
    Container.prototype.getServiceThroughCallbackInjection = function(id, stack, parentCallback) {
      var diConfig;
      this.setResolving(id);
      diConfig = this.getDiConfig(id);
      return this.resolveInjection(diConfig.injectCallback, stack, __bind(function() {
        var services;
        services = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return diConfig.callback.apply(diConfig, __slice.call(services).concat([__bind(function(service) {
          this.setResolved(id, service);
          return parentCallback(service);
        }, this)]));
      }, this));
    };
    Container.prototype.instantiate = function() {
      var diConfig, resolvedServices, what;
      what = arguments[0], diConfig = arguments[1], resolvedServices = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (typeof diConfig.instantiate === 'string') {
        return (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return typeof result == "object" ? result : child;
        })(what[diConfig.instantiate], resolvedServices, function() {});
      }
      if (diConfig.call) {
        return what[diConfig.call].apply(what, resolvedServices);
      }
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result == "object" ? result : child;
      })(what, resolvedServices, function() {});
    };
    Container.prototype.setResolving = function(id) {
      return this.resolving[id] = true;
    };
    Container.prototype.isResolving = function(id) {
      return this.resolving[id] != null;
    };
    Container.prototype.setResolved = function(id, service) {
      this.emit("async." + id, service);
      this.removeAllListeners("async." + id);
      return delete this.resolving[id];
    };
    Container.prototype.handleAsync = function(id, service, diConfig, parentCallback) {
      var complete;
      complete = __bind(function(service) {
        this.setResolved(id, service);
        return parentCallback(service);
      }, this);
      if (!(diConfig.callback != null)) {
        return complete(service);
      }
      return diConfig.callback(service, function(service) {
        return complete(service);
      });
    };
    Container.prototype.getDiConfig = function(id) {
      var part, parts, result, _i, _len, _ref, _ref2;
      parts = id.split('.');
      result = (_ref = this.config) != null ? _ref[parts.shift()] : void 0;
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        result = result != null ? (_ref2 = result.children) != null ? _ref2[part] : void 0 : void 0;
      }
      if (!(result != null)) {
        throw "Can not find configuration for " + id;
      }
      return result;
    };
    Container.prototype.resolveParam = function(id) {
      var item, paramName, parts, _ref;
      parts = id.split('.');
      if (parts.length < 2) {
        return;
      }
      paramName = parts.pop();
      item = this.getDiConfig(parts.join('.'));
      return item != null ? (_ref = item.params) != null ? _ref[paramName] : void 0 : void 0;
    };
    Container.prototype.require = function(id) {
      var diConfig, required;
      diConfig = this.getDiConfig(id);
      if (!(diConfig.require != null) && typeof diConfig !== 'string') {
        throw new Error("Can not instantiate " + id + ", missing require statement");
      }
      if (this.required[id] != null) {
        required = this.required[id];
      } else {
        required = require((typeof diConfig === 'string' ? diConfig : diConfig.require));
      }
      if (!(diConfig.storeRequire != null) || diConfig.storeRequire) {
        return this.required[id] = required;
      }
    };
    return Container;
  })();
  module.exports = {
    Container: Container
  };
}).call(this);
