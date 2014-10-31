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
		$(el).on("change.jsonBinding", function(e){
				callback();
		})
	},
	unsubscribe: function(el) {
		$(el).off(".jsonBinding");
	}
});

Shiny.inputBindings.register(jsonBinding);