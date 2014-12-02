var jsBinding = new Shiny.InputBinding();
$.extend(jsBinding, {
  find: function(scope) { return $(".jsInput"); },
  getValue: function(el) {
    var val = $(el).val();
    if (val == '') {
      return null;
    }
    var v = Number(val);
    if (isNaN(v)) { 
      return val;  
    } else {
      return v;
    }
  },
  receiveMessage: function(el, value){
    try {
      $.globalEval("var v = " + value);
      if ( typeof(v) == 'object' ) { v = JSON.stringify(v); }
      $(el).val(v);
      $(el).trigger('change');
    } catch(e) { 
      $('#jserr').val(e);
      $('#jserr').trigger('change');
    }
  },
  subscribe: function(el, callback){
    $(el).on('change', function(e){ callback(true);});
  },
  unsubscribe: function(el) {
    $(el).off('change');
  }
});
Shiny.inputBindings.register(jsBinding);