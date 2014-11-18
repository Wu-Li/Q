function buildMap(container,mapJSON) {
  
  var idea = MAPJS.content(mapJSON),
  mapModel = new MAPJS.MapModel(MAPJS.DOMRender.layoutCalculator, []),
  imageInsertController = new MAPJS.ImageInsertController("http://localhost:4999?u=");
  
  mapModel.id = container.attr('id');
  
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
    window.mapModel = Q.models[this.id];
  })
  return mapModel;
};

function saveMap(container) { 
  var mapId = container.attr("id");
  var mapJSON = Q.models[mapId].getIdea();
  var query = $("#query");
  query.val(JSON.stringify(mapJSON));
  query.trigger('change');
};

var mapBinding = new Shiny.InputBinding();
$.extend(mapBinding, {
  find: function(scope) { return $(".qmap"); },  
  getNode: function (el, qpid) {
    var mapIdea = Q.models[el.id].getIdea();
    var nodeIdea;
    if (qpid == 1) { nodeIdea = mapIdea; } 
    else { nodeIdea = mapIdea.findSubIdeaById(qpid); }
    if (nodeIdea) {
      var subIdeas = nodeIdea.sortedSubIdeas();
      if (subIdeas.length > 0) { 
          var node = {};
          var children = []; 
          subIdeas.forEach( function(idea) { 
            children.push(mapBinding.getNode(el,idea.id));
          });
          node[nodeIdea.title] = children;
      } else { var node = nodeIdea.title; }
      return node;
    } else {return null;}
  },
  getNodeValue: function(el, qpid) {
    var node = mapBinding.getNode(el, qpid);
    if (node) {
      return node.value;
    } else {return null;}
  },
  getChildren: function(el, qpid) {
    var node = mapBinding.getNode(el, qpid);
    if (node) {
      var children = [];
      node.kids.forEach(function (kid){
          children.push(mapBinding.getNode(el,kid));
      });
      return children;
    } else {return null;}
  },
  getMap: function(el, qpid) {
    var node = mapBinding.getNode(el, qpid);
    if (node) {
      var children = [];
      node.kids.forEach(function(kid){
          children.push(mapBinding.getMap(el, kid));
      });
      if (children.length > 0) { node.children = children; }
      return node;
    } else {return null;}
  },
  getValue: function(el) {
    if (Q.models[el.id]) {
      qmap = mapBinding.getNode(el,1);
      return JSON.stringify(qmap);
    } else { return null; }
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