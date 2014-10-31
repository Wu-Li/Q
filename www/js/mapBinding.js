function buildMap(container,mapId,mapJSON) {
    
    var idea = MAPJS.content(mapJSON),
        mapModel = new MAPJS.MapModel(MAPJS.DOMRender.layoutCalculator, []),
        imageInsertController = new MAPJS.ImageInsertController("http://localhost:4999?u=");
    
    mapModel.id = mapId;
        
    container.domMapWidget(console, mapModel, false, imageInsertController);
    $('body').mapToolbarWidget(mapModel);
    $('body').attachmentEditorWidget(mapModel);
    
    $("[data-mm-action='export-image']").click(function () {
        MAPJS.pngExport(idea).then(function (url) {
            window.open(url, '_blank');
        });
    });
    mapModel.setIdea(idea);
    $('#linkEditWidget').linkEditWidget(mapModel);
    window.mapModel = mapModel;
    $('.arrow').click(function () {
        $(this).toggleClass('active');
    });
    imageInsertController.addEventListener('imageInsertError', function (reason) {
        console.log('image insert error', reason);
    });
    container.on('drop', function (e) {
        var dataTransfer = e.originalEvent.dataTransfer;
        e.stopPropagation();
        e.preventDefault();
        if (dataTransfer && dataTransfer.files && dataTransfer.files.length > 0) {
            var fileInfo = dataTransfer.files[0];
            if (/\.mup$/.test(fileInfo.name)) {
                var oFReader = new FileReader();
                oFReader.onload = function (oFREvent) {
                    mapModel.setIdea(MAPJS.content(JSON.parse(oFREvent.target.result)));
                };
                oFReader.readAsText(fileInfo, 'UTF-8');
            }
        }
    });
    container.on('active', function (e) {
        window.mapModel = models[this.id];
    })
    return mapModel;
};

function saveMap(container) { 
      var mapId = container.attr("id");
      var mapJSON = models[mapId].getIdea();
      var query = $("#query");
      query.val(JSON.stringify(mapJSON));
      query.trigger('change');
};

function loadMap(container,mapJSON) {
      var mapId = container.attr("id");
      container.text("");
      models[mapId] = buildMap(container,mapId,mapJSON);
};

var mapBinding = new Shiny.InputBinding();

$.extend(mapBinding, {
	find: function(scope) {
        return $(".qmap");
	},
	getValue: function(el) {
        if (models[el.id]) {
		    idea = models[el.id].getIdea();
        } else {idea = "";}
        return idea;
	},
	setValue: function(el, value) {
		loadMap(el, value);
	},
	subscribe: function(el, callback){
		$(el).on("change.mapBinding", function(e){
				callback();
		});
	},
	unsubscribe: function(el) {
		$(el).off(".mapBinding");
	}
});

Shiny.inputBindings.register(mapBinding);