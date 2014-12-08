function buildMap(container,mapJSON) {
  var idea = MAPJS.content(mapJSON),
      mapModel = new MAPJS.MapModel(MAPJS.DOMRender.layoutCalculator, []),
      imageInsertController = new MAPJS.ImageInsertController("http://localhost:4999?u=");
  
  mapModel.id = container.attr('id');
  
  container.domMapWidget(console, mapModel, false, imageInsertController);
  container.mapToolbarWidget(mapModel);
  container.attachmentEditorWidget(mapModel);
  
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
    window.mapModel = Q.models[this.id];
  })
  return mapModel;
};

var mapBinding = new Shiny.InputBinding();
$.extend(mapBinding, {
  find: function(scope) { return $(".qmap"); },
  hasGrandChildren: function(idea) {
    var subIdeas = idea.sortedSubIdeas();
    var gc = false;
    subIdeas.forEach(function(childIdea) {
      if(childIdea.sortedSubIdeas().length > 0) {
        gc = true;
      }
    });
    return gc;
  },
  getNode: function (idea) {
    var subIdeas = idea.sortedSubIdeas();
    if (subIdeas.length == 0) { 
        var node = idea.title;
    } else if (subIdeas.length == 1) {
        var node = {};
        subIdeas.forEach(function(childIdea) {
          node[idea.title] = mapBinding.getNode(childIdea);
        });
    } else if (!(mapBinding.hasGrandChildren(idea))) {
        var node = {};
        node[idea.title] = [];
        subIdeas.forEach(function(childIdea) {
          node[idea.title].push(mapBinding.getNode(childIdea));
        });
    } else {
        var node = {};
        var values = [];
        node[idea.title] = {};
        subIdeas.forEach(function(childIdea) {
            var childNode = mapBinding.getNode(childIdea);
            if (typeof(childNode) == 'string') {
              values.push(childNode);
            } else {
              var gcNames = Object.getOwnPropertyNames(childNode);
              gcNames.forEach(function(name) {
                node[idea.title][name] = childNode[name];
              });
            }
            if (values.length > 0) {
              var i = 1;
              values.forEach(function(value){
                node[idea.title][i] = value;
                i++;
              });
            }
        });
    } 
    return node;
  },
  getValue: function(el) {
    if (Q.models[el.id]){ 
      var idea = Q.models[el.id].getIdea();
      var node = mapBinding.getNode(idea);
      return node;
    } else { return 'Map not found.'; }
  },
  setValue: function(el, value) {
    el.text("");
    Q.models[el.attr('id')] = buildMap(el,value);
  },
  subscribe: function(el, callback){
    var subscribe = function(e) { callback(); }
    Q.models[el.id].addEventListener('layoutChangeComplete', subscribe);
  },
  unsubscribe: function(el) {
    Q.models[el.id].removeEventListener('layoutChangeComplete', subscribe);
  }
});
Shiny.inputBindings.register(mapBinding);