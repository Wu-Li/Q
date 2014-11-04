var jsonBinding = new Shiny.InputBinding();

$.extend(jsonBinding, {
	find: function(scope) {
		return $(scope).find(".json");
	},
	getValue: function(el) {
		return $(el).val();
	},
	setValue: function(el, value) {
		$(el).val(JSON.stringify(value));
	},
	subscribe: function(el, callback){
        var subscribe = function(e) { callback(); }
		el.addEventListener("change", subscribe)
	},
	unsubscribe: function(el) {
		el.removeEventListener("change", subscribe);
	}
});

Shiny.inputBindings.register(jsonBinding);